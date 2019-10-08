//
//  EMKDataSyncManager.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDataSyncManager.h"

@import CoreData;

#import "EMKConstans.h"
#import "AppDelegate.h"

#import "EMKApiManager.h"

#import "Office+CoreDataClass.h"
#import "Office+CoreDataProperties.h"

NSString *const kEMKDataSyncManagerProgressNotificationName = @"EMKDataSyncManagerProgressNotificationName";

NSString *kOfficesRetrieveQueue = @"aero.skyisthelimit.EMKOfficesSyncQueue";

@interface EMKDataSyncManager ()

@property (nonatomic, strong) EMKApiManager *apiManager;
@property (nonatomic, strong) NSOperationQueue *syncOfficesQueue;

//these two properties are to be used for visual progress calculation only. They are not ccurate to use them for app logic.
@property (nonatomic, assign) double progress;
@property (nonatomic, assign) double imagesToDownload;
@property (nonatomic, assign) int imagesDownloaded;

@end

@implementation EMKDataSyncManager

-(instancetype)init {
	self = [super init];
	if(self) {

		self.syncOfficesQueue = [NSOperationQueue new];
		self.syncOfficesQueue.name = kOfficesRetrieveQueue;

		_apiManager = [[EMKApiManager alloc] initWithQueue:self.syncOfficesQueue];
	}
	return self;
}

-(void)syncWithCompletionHandler:(void (^)(bool))completion {

	self.progress = 0.0;
	self.imagesToDownload = 0;
	self.imagesDownloaded = 0;

	if(!self.apiManager.isServerReachable) {
		NSLog(@"Sync server is offline");
		[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
			@"status": @"Offline. Sync skipped.",
			@"progress": @(self.progress)
		}];
		completion(NO);
		return;
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
		@"status": @"Syncing with server...",
		@"progress": @(self.progress)
	}];

	__block EMKCoreDataHelper *cdh;
	dispatch_sync(dispatch_get_main_queue(), ^{
		cdh = ((AppDelegate*)[UIApplication sharedApplication].delegate).coreDataHelper;
	});

	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

	__weak typeof(self) weakSelf = self;
	[self.apiManager retrieveListOfOfficesWithCompletionHandler:^(NSString * _Nonnull Etag, NSArray * _Nonnull offices) {

		typeof(self) strongSelf = weakSelf;

		if([cdh.lastSyncEtag isEqualToString:Etag]) {
			NSLog(@"Syncing skipped. Etag is the same.");
			[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
				@"status": @"Database is up to date."
			}];

			completion(YES);
			return;
		} else {
			[strongSelf syncWithDatabase:offices etag: Etag];
			dispatch_semaphore_signal(semaphore);
		}
	} error:^(NSError * _Nonnull error) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
			@"status": error.localizedFailureReason,
			@"progress": @(self.progress)
		}];

		completion(NO);
		return;
	}];

	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

	//Waits until all images are downloaded.
	[self.syncOfficesQueue waitUntilAllOperationsAreFinished];

	[cdh backgroundSaveContext];

	[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
		@"status": @"Update completed.",
		@"progress": @(1.0)
	}];

	completion(YES);
}

-(bool)syncWithDatabase:(NSArray*)offices etag:(NSString*)etag {
	NSLog(@"QUEUE: %@", [NSOperationQueue currentQueue]);
	NSLog(@"Etag: %@", etag);

	__block EMKCoreDataHelper *cdh;
	dispatch_sync(dispatch_get_main_queue(), ^{
		cdh = ((AppDelegate*)[UIApplication sharedApplication].delegate).coreDataHelper;
	});


	self.progress = 0.25;
	[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
		@"status": @"Updating database...",
		@"progress": @(self.progress)
	}];

	__weak typeof(self) weakSelf = self;
	NSUInteger numberOfOffices = [offices count];
	NSUInteger currentObject = 0;
	self.imagesToDownload = numberOfOffices;
	for (NSDictionary *officeProperties in offices) {
		[cdh.importContext performBlockAndWait:^{
			typeof(self) strongSelf = weakSelf;

			Office *office = (Office*)[strongSelf insertUniqueObjectInTargetEntity:@"Office" uniqueAttributeKey:@"identifier" uniqueAttributeValue:officeProperties[@"DisKz"] inContext:cdh.importContext];

			[office setValuesForKeysWithDictionary:officeProperties];

			[strongSelf saveContext:cdh.importContext];

			[strongSelf downloadPhotoDataForOfficeWithId:office.objectID andURL:office.photoUrl inContext:cdh.importContext];
		}];

		currentObject++;

		self.progress += (0.25 * (double)currentObject / (double)numberOfOffices);// It is assumed that downloading data from server takes quarter of the time, and processing db update takes another half.

		//Updating UI after each DB entry is not necessary.
		if(currentObject % 10 == 0) {

			[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
				@"status": @"Updating database...",
				@"progress": @(self.progress)
			}];
		}

	}

	//TODO Save context to persistent storage synchronously and update etag when saving success.
	[cdh saveLastSyncEtag:etag];

	return YES;
}

-(void)downloadPhotoDataForOfficeWithId:(NSManagedObjectID*)objectId andURL:(NSURL*)url inContext:(NSManagedObjectContext*)context {

	__weak typeof(self) weakSelf = self;

	[self.apiManager retrieveDataFromURL:url completionHandler:^(NSData * _Nonnull imgData) {
		typeof(self) strongSelf = weakSelf;

		[strongSelf updatePhotoData:imgData forObjectWithId:objectId inContext:context];

		strongSelf.imagesDownloaded += 1;
		strongSelf.progress += (0.5 * 1/strongSelf.imagesToDownload);
		if(strongSelf.imagesDownloaded % 10 == 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
				@"status": @"Updating database...",
				@"progress": @(strongSelf.progress)
			}];
		}


	} error:^(NSError * _Nonnull error) {
		NSLog(@"Img cannot be retrieved: %@", error);
	}];
}

#pragma mark - CoreData methods

-(NSManagedObject*)existingObjectInContext:(NSManagedObjectContext*)context forEntiry:(NSString*)entity withUniqueAttributeKey:(NSString*)uniqueAttributeKey andValue:(NSString*)uniqueAttributeValue {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K==%@", uniqueAttributeKey, uniqueAttributeValue];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    fetchRequest.predicate = predicate;
    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSArray *fetchRequestResults = [context executeFetchRequest:fetchRequest error:&error];

    if(!fetchRequestResults) {
        NSLog(@"Error: %@", error.localizedDescription);
    }

    if(fetchRequestResults.count == 0) {
        return nil;
    }

    return fetchRequestResults.lastObject;
}

-(NSManagedObject*)insertUniqueObjectInTargetEntity:(NSString *)entity uniqueAttributeKey:(NSString *)uniqueAttributeKey uniqueAttributeValue:(NSString *)uniqueAttributeValue inContext:(NSManagedObjectContext *)context {

    if(uniqueAttributeValue.length > 0) {
        NSManagedObject *existingObject = [self existingObjectInContext:context
                                                              forEntiry:entity
                                               withUniqueAttributeKey:uniqueAttributeKey
                                               andValue: uniqueAttributeValue];

        if(existingObject) {
            return existingObject;
        } else {
            NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
            return newObject;
        }
    } else {
        NSLog(@"Skipped %@ object creation: unique attribute value is 0 length", entity);
        return nil;
    }
}

-(void)updatePhotoData:(NSData*)data forObjectWithId:(NSManagedObjectID*)objectId inContext:(NSManagedObjectContext*)context {

	__weak typeof(self) weakSelf = self;

	[context performBlockAndWait:^{
		typeof(self) strongSelf = weakSelf;

		Office *office = [context objectWithID:objectId];

		if(office) {
			office.photoData = data;
			[strongSelf saveContext:context];
		}
	}];

}

-(void)saveContext:(NSManagedObjectContext*)context {

    [context performBlockAndWait:^{
        if(context.hasChanges) {
            NSError *error = nil;

            if([context save:&error]) {
                NSLog(@"CoreDataImporter SAVED changes from import context to parent context");
            } else {
                NSLog(@"CoreDataImporter FAILED to save changes from import context to parent context: %@", error);
            }
        } else {
            NSLog(@"CoreDataImporter SKIPPED saving context as there are no changes");
        }
    }];
}

@end

//
//  EMKDataSyncManager.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDataSyncManager.h"

@import Reachability;
@import CoreData;

#import "EMKConstans.h"
#import "AppDelegate.h"

#import "Office+CoreDataClass.h"
#import "Office+CoreDataProperties.h"

NSString *const kEMKDataSyncManagerProgressNotificationName = @"EMKDataSyncManagerProgressNotificationName";

NSString *kOfficesRetrieveQueue = @"aero.skyisthelimit.EMKOfficesRetrieveQueue";

NSString *kOfficesEndpoint = @"Finanzamtsliste.json";

@interface EMKDataSyncManager ()<NSURLSessionDelegate>

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSOperationQueue *syncOfficesQueue;
@property (nonatomic, strong) NSURLSession *urlSession;

//these two properties are to be used for visual progress calculation only. They are not ccurate to use them for app logic.
@property (nonatomic, assign) double progress;
@property (nonatomic, assign) double imagesToDownload;
@property (nonatomic, assign) int imagesDownloaded;

@end

@implementation EMKDataSyncManager

-(instancetype)init {
	self = [super init];
	if(self) {
		self.reachability = [Reachability reachabilityWithHostName:kEMKAPIdomain];
		[self.reachability startNotifier];

		self.syncOfficesQueue = [NSOperationQueue new];
		self.syncOfficesQueue.name = kOfficesRetrieveQueue;

		self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.syncOfficesQueue];
	}
	return self;
}

-(void)dealloc {
	[self.reachability stopNotifier];
}

-(void)syncWithCompletionHandler:(void (^)(bool))completion {

	self.progress = 0.0;
	self.imagesToDownload = 0;
	self.imagesDownloaded = 0;

	if(!self.reachability.isReachable) {
		NSLog(@"Sync server is offline");
		[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
			@"status": @"Offline. Sync skipped.",
			@"progress": @(self.progress)
		}];
		return;
	}

	NSURL *endpointUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kEMKApiProtocol, kEMKAPIdomain]];
	endpointUrl = [endpointUrl URLByAppendingPathComponent:kOfficesEndpoint];

	__weak typeof(self) weakSelf = self;
	NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithURL:endpointUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		typeof(self) strongSelf = weakSelf;

		NSString *etag = ((NSHTTPURLResponse*)response).allHeaderFields[@"Etag"];

		//TODO This is inefficient workaround which is forced by server which does not return valid UTF-8 encoded data. The server should return valid UTF-8 encoded data or header containing content encoding. The workaround may stop working properly if server encoding changes!!!!!
		NSString *latin1String = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
		NSData *utf8Data = [latin1String dataUsingEncoding:NSUTF8StringEncoding];

		[strongSelf syncWithDatabase:utf8Data etag: etag];
//TODO Add error handling

	}];

	[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
		@"status": @"Syncing with server...",
		@"progress": @(self.progress)
	}];

	[dataTask resume];

	//Waits until all images are downloaded.
	[self.syncOfficesQueue waitUntilAllOperationsAreFinished];

	__block EMKCoreDataHelper *cdh;
	dispatch_sync(dispatch_get_main_queue(), ^{
		cdh = ((AppDelegate*)[UIApplication sharedApplication].delegate).coreDataHelper;
	});

	[cdh backgroundSaveContext];

	[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
		@"status": @"Update completed.",
		@"progress": @(1.0)
	}];

	completion(YES);
}

-(bool)syncWithDatabase:(NSData*)data etag:(NSString*)etag {
	NSLog(@"QUEUE: %@", [NSOperationQueue currentQueue]);
	NSLog(@"Etag: %@", etag);

	__block EMKCoreDataHelper *cdh;
	dispatch_sync(dispatch_get_main_queue(), ^{
		cdh = ((AppDelegate*)[UIApplication sharedApplication].delegate).coreDataHelper;
	});

	if([cdh.lastSyncEtag isEqualToString:etag]) {
		NSLog(@"Syncing skipped. Etag is the same.");
		[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
			@"status": @"Database is up to date.",
			@"progress": @(1.0)
		}];

		return YES;
	}

	NSError *deserializationError;

	id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&deserializationError];
	if(!jsonObj) {
		NSLog(@"JSON error: %@", deserializationError);
		//TODO handle error

		[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
			@"status": @"Invalid server response.",
			@"progress": @(self.progress)
		}];

		return NO;
	}

	if(![jsonObj isKindOfClass:[NSArray class]]) {
		NSLog(@"JSON Root is not a type of list");
		//TODO handle error

		[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
			@"status": @"Invalid server response.",
			@"progress": @(self.progress)
		}];

		return NO;
	}

	self.progress = 0.25;
	[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
		@"status": @"Updating database...",
		@"progress": @(self.progress)
	}];

	__weak typeof(self) weakSelf = self;
	NSUInteger numberOfOffices = [jsonObj count];
	NSUInteger currentObject = 0;
	for (NSDictionary *officeProperties in jsonObj) {
		[cdh.importContext performBlockAndWait:^{
			typeof(self) strongSelf = weakSelf;

			Office *office = (Office*)[strongSelf insertUniqueObjectInTargetEntity:@"Office" uniqueAttributeKey:@"identifier" uniqueAttributeValue:officeProperties[@"DisKz"] inContext:cdh.importContext];

			[office setValuesForKeysWithDictionary:officeProperties];

			[strongSelf saveContext:cdh.importContext];

			[strongSelf downloadPhotoDataForOfficeWithId:office.objectID andURL:office.photoUrl inContext:cdh.importContext];
		}];

		currentObject++;

		self.progress += 0.25 * (double)currentObject / (double)numberOfOffices;// It is assumed that downloading data from server takes quarter of the time, and processing db update takes another half.

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

	NSURLSessionDataTask *downloadTask = [self.urlSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

		typeof(self) strongSelf = weakSelf;

		if(((NSHTTPURLResponse*)response).statusCode == 200) {
			[strongSelf updatePhotoData:data forObjectWithId:objectId inContext:context];
		}

		self.imagesDownloaded += 1;
		self.progress = 0.5 * 1/self.imagesToDownload;
		if(strongSelf.imagesDownloaded % 10 == 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:kEMKDataSyncManagerProgressNotificationName object:nil userInfo:@{
				@"status": @"Updating database...",
				@"progress": @(self.progress)
			}];
		}

	}];
	[downloadTask resume];
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

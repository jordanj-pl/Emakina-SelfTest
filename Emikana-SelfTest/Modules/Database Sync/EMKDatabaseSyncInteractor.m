//
//  EMKDataSyncManager.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDatabaseSyncInteractor.h"

@import CoreData;

#import "EMKConstans.h"
#import "AppDelegate.h"

#import "EMKApiManager.h"
#import "EMKDatabaseManager.h"

#import "Office+CoreDataClass.h"
#import "Office+CoreDataProperties.h"

NSString *const kOfficesRetrieveQueue = @"aero.skyisthelimit.EMKOfficesSyncQueue";

@interface EMKDatabaseSyncInteractor ()

@property (nonatomic, strong, readonly) EMKDatabaseManager *dbManager;
@property (nonatomic, strong, readonly) EMKApiManager *apiManager;
@property (nonatomic, strong, readonly) NSOperationQueue *syncOfficesQueue;

//these two properties are to be used for visual progress calculation only. They are not ccurate to use them for app logic.
@property (nonatomic, assign) double progress;
@property (nonatomic, assign) double imagesToDownload;
@property (nonatomic, assign) int imagesDownloaded;

@end

@implementation EMKDatabaseSyncInteractor

-(instancetype)initWithDatabaseManager:(EMKDatabaseManager*)dbManager {
	self = [super init];
	if(!self) {
		return nil;
	}

	_dbManager = dbManager;

	_syncOfficesQueue = [NSOperationQueue new];
	_syncOfficesQueue.name = kOfficesRetrieveQueue;

	_apiManager = [[EMKApiManager alloc] initWithQueue:self.syncOfficesQueue];

	return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
-(instancetype)init {
	@throw [NSException exceptionWithName:@"Designated initializer required" reason:@"Use initWithDatabaseManager: instead." userInfo:nil];
	return nil;
}
#pragma clang diagnostic pop

-(void)sync {

	self.progress = 0.0;
	self.imagesToDownload = 0;
	self.imagesDownloaded = 0;

	if(!self.apiManager.isServerReachable) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.output receiveStatus:@"Offline. Sync skipped."];
			[self.output didCompleteWithSuccess:NO];
		});
		return;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		[self.output receiveStatus:@"Looking for updates..."];
	});

	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	__block BOOL dataNeedsReload = YES;

	__weak typeof(self) weakSelf = self;
	[self.apiManager retrieveListOfOfficesWithCompletionHandler:^(NSString * _Nonnull Etag, NSArray * _Nonnull offices) {

		typeof(self) strongSelf = weakSelf;

		if([strongSelf.dbManager.lastSyncEtag isEqualToString:Etag]) {
			dataNeedsReload = NO;
		} else {
			[strongSelf syncWithDatabase:offices etag: Etag];
		}

		dispatch_semaphore_signal(semaphore);

	} error:^(NSError * _Nonnull error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.output receiveStatus: error.localizedFailureReason];
			[self.output receiveProgress: self.progress];
			[self.output didCompleteWithSuccess: NO];
		});

		return;
	}];

	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

	if(!dataNeedsReload) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.output receiveStatus:@"Database is up to date."];
			[self.output didCompleteWithSuccess:YES];
		});
		return;
	}

	//Waits until all images are downloaded.
	[self.syncOfficesQueue waitUntilAllOperationsAreFinished];

	[self.dbManager saveToPersistentStore];

	dispatch_async(dispatch_get_main_queue(), ^{
		[self.output receiveStatus: @"Update completed."];
		[self.output receiveProgress: 1.0];
		[self.output didCompleteWithSuccess: YES];
	});
}

-(bool)syncWithDatabase:(NSArray*)offices etag:(NSString*)etag {
	NSLog(@"QUEUE: %@", [NSOperationQueue currentQueue]);
	NSLog(@"Etag: %@", etag);

	self.progress = 0.25;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.output receiveStatus: @"Updating database..."];
		[self.output receiveProgress: self.progress];
	});

	//Reference sync date does not need to reflect accurate current date and time.
	NSDate *referenceSyncDate = [NSDate date];

	NSUInteger numberOfOffices = [offices count];
	NSUInteger currentObject = 0;
	self.imagesToDownload = numberOfOffices;
	for (NSDictionary *officeProperties in offices) {

		Office *office = (Office*)[self.dbManager insertUniqueObjectInTargetEntity:@"Office" uniqueAttributeKey:@"identifier" uniqueAttributeValue:officeProperties[@"DisKz"] properties: officeProperties syncDate:referenceSyncDate];

		[self downloadPhotoDataForOfficeWithId:office.objectID andURL:office.photoUrl];

		currentObject++;

		self.progress += (0.25 * (double)currentObject / (double)numberOfOffices);// It is assumed that downloading data from server takes quarter of the time, and processing db update takes another half.

		//Updating UI after each DB entry is not necessary.
		if(currentObject % 10 == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.output receiveStatus: @"Updating database..."];
				[self.output receiveProgress: self.progress];
			});
		}

	}

	[self.dbManager deleteObjectsOlderThan:referenceSyncDate];

	//TODO Save context to persistent storage synchronously and update etag when saving success.
	[self.dbManager saveLastSyncEtag:etag];

	return YES;
}

-(void)downloadPhotoDataForOfficeWithId:(NSManagedObjectID*)objectId andURL:(NSURL*)url {

	__weak typeof(self) weakSelf = self;

	[self.apiManager retrieveDataFromURL:url completionHandler:^(NSData * _Nonnull imgData) {
		typeof(self) strongSelf = weakSelf;

		[strongSelf.dbManager updatePhotoData:imgData forObjectWithId:objectId];

		strongSelf.imagesDownloaded += 1;
		strongSelf.progress += (0.5 * 1/strongSelf.imagesToDownload);
		if(strongSelf.imagesDownloaded % 10 == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[strongSelf.output receiveStatus: @"Updating database..."];
				[strongSelf.output receiveProgress: strongSelf.progress];
			});
		}

	} error:^(NSError * _Nonnull error) {
		NSLog(@"Img cannot be retrieved: %@", error);
	}];
}

@end

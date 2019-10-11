//
//  EMKDatabaseManager.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 09/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDatabaseManager.h"

#import "EMKCoreDataHelper.h"

@interface EMKDatabaseManager ()

@property (nonatomic, strong, readonly) EMKCoreDataHelper *cdh;

@end

@implementation EMKDatabaseManager

-(instancetype)init {
	self = [super init];
	if(self) {
		_cdh = [[EMKCoreDataHelper alloc] initWithStoreURL:self.storeURL];
	}
	return self;
}

-(void)loadDatabase {
	[self.cdh loadDatabase];
}

-(BOOL)isMigrationNeeded {
	return [self.cdh isMigrationNecessary];
}

-(void)migrateDatabaseWithCompletion:(void (^)(BOOL))completionHandler progressHandler:(void (^)(float))progressHanlder {

	[self.cdh migrateStoreWithCompletion:completionHandler progressHandler:progressHanlder];
}

#pragma mark - select

-(NSFetchedResultsController*)allOffices {
	NSFetchRequest *request = [self.cdh.model fetchRequestTemplateForName:@"AllOffices"].copy;
	request.sortDescriptors = [NSArray arrayWithObjects:
	                               [NSSortDescriptor sortDescriptorWithKey:@"zip" ascending:YES],nil];

	return [[NSFetchedResultsController alloc] initWithFetchRequest:request
	                                        managedObjectContext:self.cdh.context
	                                          sectionNameKeyPath:nil
	                                                   cacheName:nil];
}

-(Office*)officeByManagedObjectId:(NSManagedObjectID *)objectId {
	return (Office*)[self.cdh.context existingObjectWithID:objectId error:nil];
}

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

#pragma mark update

-(void)updatePhotoData:(NSData*)data forObjectWithId:(NSManagedObjectID*)objectId {

	__weak typeof(self) weakSelf = self;

	[self.cdh.importContext performBlockAndWait:^{
		typeof(self) strongSelf = weakSelf;

		Office *office = [strongSelf.cdh.importContext objectWithID:objectId];

		if(office) {
			office.photoData = data;
		}
	}];

	[self saveContext:self.cdh.importContext];
}

#pragma mark insert

-(NSManagedObject*)insertUniqueObjectInTargetEntity:(NSString *)entity uniqueAttributeKey:(NSString *)uniqueAttributeKey uniqueAttributeValue:(NSString *)uniqueAttributeValue properties:(NSDictionary*)properties syncDate:(nonnull NSDate *)syncDate {

	if(uniqueAttributeValue.length == 0) {
		return nil;
	}

	__block NSManagedObject *insertedObject;

	[self.cdh.importContext performBlockAndWait:^{
		NSManagedObject *existingObject = [self existingObjectInContext:self.cdh.importContext
														  forEntiry:entity
										   withUniqueAttributeKey:uniqueAttributeKey
										   andValue: uniqueAttributeValue];

		if(existingObject) {
			insertedObject = existingObject;
		} else {
			insertedObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:self.cdh.importContext];
		}

		[insertedObject setValuesForKeysWithDictionary:properties];
		((Office*)insertedObject).lastUpdated = syncDate;
	}];

	[self saveContext:self.cdh.importContext];

	return insertedObject;
}

#pragma mark delete

-(void)deleteObjectsOlderThan:(NSDate*)lastSyncDate {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastUpdated < %@", lastSyncDate];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Office"];
    fetchRequest.predicate = predicate;

    NSError *error = nil;
    NSArray *fetchRequestResults = [self.cdh.importContext executeFetchRequest:fetchRequest error:&error];


	[self.cdh.importContext performBlockAndWait:^{
		for (NSManagedObject *object in fetchRequestResults) {
			[self.cdh.importContext deleteObject:object];
		}
	}];

	[self saveContext:self.cdh.importContext];
}

#pragma mark - metadata

-(NSString*)lastSyncEtag {
	return self.cdh.storeMetadata[@"EMKLastSyncEtag"];
}

-(void)saveLastSyncEtag:(NSString *)etag {
	NSMutableDictionary *dictionary = [self.cdh.storeMetadata mutableCopy];
	[dictionary setObject:etag forKey:@"EMKLastSyncEtag"];
	[self.cdh saveStoreMetadata:dictionary];
}

#pragma mark - saving

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

-(void)saveToPersistentStore {
	[self.cdh saveParentContext];
}

-(void)saveToPersistentStoreAsync {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		[self.cdh saveParentContext];
	});
}

#pragma mark - Create DB file path

NSString *dbFilename = @"Offices.sqlite";

-(NSString*)applicationDocumentsDirectory {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
}

-(NSURL*)applicationStoresDirectory {
    NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;

        if([fileManager createDirectoryAtURL:storesDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
        } else {
			NSLog(@"FAILED to create Stores directory: %@", error);
		}
    }

    return storesDirectory;
}

-(NSURL*)storeURL {
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:dbFilename];
}

@end

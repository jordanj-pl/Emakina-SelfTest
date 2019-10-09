//
//  EMKCoreDataHelper.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 06/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKCoreDataHelper.h"

@interface EMKCoreDataHelper ()

@property (nonatomic, strong, readonly) NSURL *storeURL;

@property (nonatomic, copy) void(^migrationProgressHandler)(float progress);

@end

@implementation EMKCoreDataHelper

#pragma mark - SETUP

-(instancetype)initWithStoreURL:(NSURL *)storeURL {
	self = [super init];
	if(!self) {
		return nil;
	}

	_storeURL = storeURL;

    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];

    _parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_parentContext performBlockAndWait:^{
        [_parentContext setPersistentStoreCoordinator:_coordinator];
        [_parentContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }];

    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setParentContext:_parentContext];
    [_context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];

    _importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_importContext performBlockAndWait:^{
        [_importContext setParentContext:_context];
        [_importContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_importContext setUndoManager:nil];
    }];


	return self;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
-(instancetype)init {
	@throw [NSException exceptionWithName:@"Designated initializer required" reason:@"Use initWithStoreURL: instead. storeURL is required." userInfo:nil];
	return nil;
}
#pragma clang diagnostic pop

-(void)loadDatabase {
    if(_store) {
        return;
    }

    NSLog(@"DB URL: %@", [self storeURL]);

	NSDictionary *options = @{
                                  NSMigratePersistentStoresAutomaticallyOption: @(YES),
                                  NSInferMappingModelAutomaticallyOption: @(NO),
                                  NSSQLitePragmasOption: @{
                                          @"journal_mode": @"DELETE"
                                          }
	};

	NSError *error = nil;
	_store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                            configuration:nil
                                                      URL:[self storeURL]
                                                  options:options
                                                    error:&error];

	if(!_store) {
		NSLog(@"FAILED to add store. Error: %@", error);
	}
}

#pragma mark - SAVING

-(void)saveContext {
    if(_context.hasChanges) {
        NSError *error = nil;

        if([_context save:&error]) {
            NSLog(@"Context saved changes to persistent store.");
        } else {
			//TODO handle error
            NSLog(@"FAILED to save _context: %@", error);
        }
    } else {
        NSLog(@"SKIPPED _context save, there are no changes.");
    }
}

-(void)saveParentContext {
	[self saveContext];

	__weak typeof(self) weakSelf = self;
	[self.parentContext performBlockAndWait:^{
		typeof(self) strongSelf = weakSelf;

		if(strongSelf->_parentContext.hasChanges) {
			NSError *error = nil;

			if([strongSelf->_parentContext save:&error]) {
				NSLog(@"_parentContext SAVED changed to persistent store.");
			} else {
				NSLog(@"_parentContext FAILED to save: %@", error);
				//TODO handle error
			}
		} else {
			NSLog(@"_parentContext SKIPPED - no changes.");
		}
	}];
}

#pragma mark - MIGRATION MANAGER

-(BOOL)isMigrationNecessary {

    if(![[NSFileManager defaultManager] fileExistsAtPath:self.storeURL.path]) {
        return NO;
    }

    NSError *error = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:self.storeURL options:nil error:&error];

    NSManagedObjectModel *destinationModel = _coordinator.managedObjectModel;

    if([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
        return NO;
    } else {
        return YES;
    }
}

-(void)migrateStoreWithCompletion:(void(^)(BOOL))completionHandler progressHandler:(void(^)(float progress))progressHanlder {

	self.migrationProgressHandler = progressHanlder;

    NSError *error = nil;

    //Gather source, destination and mapping model.
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:self.storeURL options:nil error:&error];
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];

    NSManagedObjectModel *destinationModel = _model;

    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                            forSourceModel:sourceModel
                                                          destinationModel:destinationModel];

    //Perform migration
    if(!mappingModel) {
		completionHandler(NO);
		return;
    }

	NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinationModel];

	[migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];


	NSURL *destinationStore = [[self.storeURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"Temp.sqlite"];

    BOOL success = [migrationManager migrateStoreFromURL:self.storeURL
                                                   type:NSSQLiteStoreType
                                                options:nil
                                       withMappingModel:mappingModel
                                       toDestinationURL:destinationStore
                                        destinationType:NSSQLiteStoreType
                                     destinationOptions:nil
                                                  error:&error];

	if(!success) {
        completionHandler(NO);
        return;
	}

	//Replace old store with the new migrated store
	if(![self replaceStore:self.storeURL withStore:destinationStore]) {
		completionHandler(NO);
		return;
	}

	[migrationManager removeObserver:self forKeyPath:@"migrationProgress"];

    completionHandler(YES);
}

-(BOOL)replaceStore:(NSURL*)old withStore:(NSURL*)new {

    BOOL success = NO;
    NSError *error = nil;
    if([[NSFileManager defaultManager] removeItemAtURL:old error:&error]) {

        error = nil;
        if([[NSFileManager defaultManager] moveItemAtURL:new toURL:old error:&error]) {
            success = YES;
        } else {
			NSLog(@"Failed to re-home new store: %@", error);
        }
    } else {
		NSLog(@"Failed to remove old store (%@): %@", old, error);
    }

    return success;
}

#pragma mark - KVC observers

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if([keyPath isEqualToString:@"migrationProgress"]) {
		float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
		self.migrationProgressHandler(progress);
    }
}

#pragma mark - Metadata

-(NSDictionary*)storeMetadata {
	return self.store.metadata;
}

-(void)saveStoreMetadata:(NSDictionary*)metadata {
	[self.coordinator setMetadata:metadata forPersistentStore:self.store];
}

@end

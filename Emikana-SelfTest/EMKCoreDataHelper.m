//
//  EMKCoreDataHelper.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 06/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKCoreDataHelper.h"

@implementation EMKCoreDataHelper

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

#pragma mark - SETUP

-(instancetype)init {
    self = [super init];
    if(!self) {
        return nil;
    }

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

-(void)loadStore {
    if(_store) {
        return;
    }

    BOOL useMigrationManager = YES;
    if(useMigrationManager && [self isMigrationNecessaryForStore:[self storeURL]]) {
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    } else {
        NSDictionary *options = @{
                                  NSMigratePersistentStoresAutomaticallyOption: @(YES),
                                  NSInferMappingModelAutomaticallyOption: @(NO) //,
                                  //NSSQLitePragmasOption: @{
                                    //      @"journal_mode": @"DELETE"
                                      //    }
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
}

-(void)setupCoreData {
    //[self setDefaultDataStoreAsInitialStore];
    [self loadStore];
    //[self checkIfDefaultDataNeedsImporting];
//    [self importGroceryDudeTestData];
}

#pragma mark - SAVING

-(void)saveContext {
    if(_context.hasChanges) {
        NSError *error = nil;

        if([_context save:&error]) {
            NSLog(@"Context saved changes to persistent store.");
        } else {
        //TODO
//            [self showValidationError:error];
            NSLog(@"FAILED to save _context: %@", error);
        }
    } else {
        NSLog(@"SKIPPED _context save, there are no changes.");
    }
}

-(void)backgroundSaveContext {
    [self saveContext];

	__weak typeof(self) weakSelf = self;
    [_parentContext performBlock:^{
		typeof(self) strongSelf = weakSelf;
        if(strongSelf->_parentContext.hasChanges) {
            NSError *error = nil;

            if([strongSelf->_parentContext save:&error]) {
                NSLog(@"_parentContext SAVED changed to persistent store.");
            } else {
                NSLog(@"_parentContext FAILED to save: %@", error);
                //TODO
//                [self showValidationError:error];
            }
        } else {
            NSLog(@"_parentContext SKIPPED - no changes.");
        }
    }];
}


#pragma mark - MIGRATION MANAGER

-(BOOL)isMigrationNecessaryForStore:(NSURL*)storeURL {

    if(![[NSFileManager defaultManager] fileExistsAtPath:self.storeURL.path]) {
        return NO;
    }

    NSError *error = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL options:nil error:&error];

    NSManagedObjectModel *destinationModel = _coordinator.managedObjectModel;

    if([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
        return NO;
    } else {
        return YES;
    }
}

-(BOOL)migrateStore:(NSURL*)sourceStore {
    BOOL success = NO;
    NSError *error = nil;

    //Gather source, destination and mapping model.
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:sourceStore
                                                                                          options:nil
                                                                                            error:&error];
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];

    NSManagedObjectModel *destinationModel = _model;

    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                            forSourceModel:sourceModel
                                                          destinationModel:destinationModel];

    //Perform migration
    if(mappingModel) {
        NSError *error = nil;
        NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                                                              destinationModel:destinationModel];

        [migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];

        NSURL *destinationStore = [[self applicationStoresDirectory] URLByAppendingPathComponent:@"Temp.sqlite"];

        success = [migrationManager migrateStoreFromURL:sourceStore
                                                   type:NSSQLiteStoreType
                                                options:nil
                                       withMappingModel:mappingModel
                                       toDestinationURL:destinationStore
                                        destinationType:NSSQLiteStoreType
                                     destinationOptions:nil
                                                  error:&error];

        if(success) {
            //Replace old store with the new migrated store

            if([self replaceStore:sourceStore withStore:destinationStore]) {
				[migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
            } else {
                NSLog(@"FAILED migration ERROR: %@", error);
            }
        }
    } else {
        NSLog(@"FAILED migration. Mapping model is null.");
    }

    return success;
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

-(void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL {
//TODO
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    self.migrationVC = [sb instantiateViewControllerWithIdentifier:@"migration"];

//    UIApplication *sa = [UIApplication sharedApplication];
//
//    UINavigationController *nc = (UINavigationController*)sa.keyWindow.rootViewController;
//    [nc presentViewController:self.migrationVC animated:NO completion:nil];

	__weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL done = [self migrateStore:storeURL];
        if(done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                typeof(self) strongSelf = weakSelf;
                strongSelf->_store = [strongSelf->_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                    configuration:nil
                                                              URL:[self storeURL]
                                                          options:nil
                                                            error:&error];

                if(!strongSelf->_store) {
                    NSLog(@"Failed to add migrated store. Error: %@", error);
                    abort();
                } else {
                    NSLog(@"Successfully added a migrated store: %@", strongSelf->_store);
                }

//                [self.migrationVC dismissViewControllerAnimated:NO completion:nil];
//                self.migrationVC = nil;
            });
        }
    });
}

#pragma mark - KVC observers

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if([keyPath isEqualToString:@"migrationProgress"]) {

        dispatch_async(dispatch_get_main_queue(), ^{
        //TODO
//            float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
//            self.migrationVC.progressView.progress = progress;
//
//            int percentage = progress * 100;
//
//            NSString *string = [NSString stringWithFormat:@"Migration progress: %i%%", percentage];
//            NSLog(@"%@", string);
//            self.migrationVC.label.text = string;
        });
    }
}


@end

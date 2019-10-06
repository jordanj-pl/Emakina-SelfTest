//
//  EMKCoreDataHelper.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 06/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import CoreData;

NS_ASSUME_NONNULL_BEGIN

@interface EMKCoreDataHelper : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *parentContext;
@property (nonatomic, readonly) NSManagedObjectContext *context;
@property (nonatomic, readonly) NSManagedObjectContext *importContext;
@property (nonatomic, readonly) NSManagedObjectModel *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSPersistentStore *store;

-(void)setupCoreData;
-(void)saveContext;
-(void)backgroundSaveContext;

@end

NS_ASSUME_NONNULL_END

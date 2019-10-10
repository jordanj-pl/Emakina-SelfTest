//
//  EMKDatabaseManager.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 09/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "Office+CoreDataProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMKDatabaseManager : NSObject

-(void)loadDatabase;
-(BOOL)isMigrationNeeded;
-(void)migrateDatabaseWithCompletion:(void(^)(BOOL))completionHandler progressHandler:(void(^)(float progress))progressHanlder;

-(NSFetchedResultsController*)allOffices;
-(Office*)officeByManagedObjectId:(NSManagedObjectID*)objectId;

-(NSManagedObject*)insertUniqueObjectInTargetEntity:(NSString *)entity uniqueAttributeKey:(NSString *)uniqueAttributeKey uniqueAttributeValue:(NSString *)uniqueAttributeValue properties:(NSDictionary*)properties syncDate:(NSDate*)syncDate;

-(void)updatePhotoData:(NSData*)data forObjectWithId:(NSManagedObjectID*)objectId;

-(void)deleteObjectsOlderThan:(NSDate*)lastSyncDate;

-(NSString*)lastSyncEtag;
-(void)saveLastSyncEtag:(NSString *_Nonnull)etag;

-(void)saveToPersistentStore;
-(void)saveToPersistentStoreAsync;

@end

NS_ASSUME_NONNULL_END

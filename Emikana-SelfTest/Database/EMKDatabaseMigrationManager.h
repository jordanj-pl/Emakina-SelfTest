//
//  EMKDatabaseMigrationManager.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 09/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

@class EMKDatabaseManager;

NS_ASSUME_NONNULL_BEGIN

@interface EMKDatabaseMigrationManager : NSObject

-(instancetype)initWithDatabaseManager:(EMKDatabaseManager*)dbManager NS_DESIGNATED_INITIALIZER;

-(void)migrateDatabaseWithCompletion:(void(^)(BOOL))completionHandler progressHandler:(void(^)(float progress))progressHanlder;

@end

NS_ASSUME_NONNULL_END

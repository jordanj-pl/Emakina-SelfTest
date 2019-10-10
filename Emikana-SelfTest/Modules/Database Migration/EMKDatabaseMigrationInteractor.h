//
//  EMKDatabaseMigrationManager.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 09/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKDatabaseMigrationProvider.h"
#import "EMKDatabaseMigrationOutput.h"

@class EMKDatabaseManager;

NS_ASSUME_NONNULL_BEGIN

@interface EMKDatabaseMigrationInteractor : NSObject<EMKDatabaseMigrationProvider>

@property (nonatomic, strong) id<EMKDatabaseMigrationOutput> output;

-(instancetype)initWithDatabaseManager:(EMKDatabaseManager*)dbManager NS_DESIGNATED_INITIALIZER;

-(void)migrateDatabase;

@end

NS_ASSUME_NONNULL_END

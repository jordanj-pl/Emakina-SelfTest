//
//  EMKDataSyncManager.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

@class EMKDatabaseManager;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kEMKDataSyncManagerProgressNotificationName;

@interface EMKDataSyncManager : NSObject

-(instancetype)initWithDatabaseManager:(EMKDatabaseManager*)dbManager NS_DESIGNATED_INITIALIZER;

-(void)syncWithCompletionHandler:(void (^)(bool))completion;

@end

NS_ASSUME_NONNULL_END

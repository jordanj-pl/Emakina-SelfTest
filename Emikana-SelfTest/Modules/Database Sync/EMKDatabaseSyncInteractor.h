//
//  EMKDataSyncManager.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKDatabaseSyncProvider.h"
#import "EMKDatabaseSyncOutput.h"

@class EMKDatabaseManager;

NS_ASSUME_NONNULL_BEGIN

@interface EMKDatabaseSyncInteractor : NSObject<EMKDatabaseSyncProvider>

@property (nonatomic, weak) id<EMKDatabaseSyncOutput> output;

-(instancetype)initWithDatabaseManager:(EMKDatabaseManager*)dbManager NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

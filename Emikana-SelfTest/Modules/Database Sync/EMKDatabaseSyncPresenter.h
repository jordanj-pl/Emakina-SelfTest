//
//  EMKDatabaseSyncPresenter.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKDatabaseSyncEventHandler.h"
#import "EMKDatabaseSyncView.h"
#import "EMKDatabaseSyncProvider.h"
#import "EMKDatabaseSyncOutput.h"

#import "EMKMainRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMKDatabaseSyncPresenter : NSObject<EMKDatabaseSyncEventHandler, EMKDatabaseSyncOutput>

@property (nonatomic, weak) id<EMKDatabaseSyncView> view;
@property (nonatomic, strong) id<EMKDatabaseSyncProvider> provider;

@property (nonatomic, weak) EMKMainRouter *mainRouter;

@end

NS_ASSUME_NONNULL_END

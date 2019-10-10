//
//  EMKMigrationProgressPresenter.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKDatabaseMigrationProgressViewProtocol.h"
#import "EMKDatabaseMigrationOutput.h"
#import "EMKDatabaseMigrationProvider.h"
#import "EMKDatabaseMigrationProgressViewEventHandlerProtocol.h"

#import "EMKMainRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMKDatabaseMigrationProgressPresenter : NSObject<EMKDatabaseMigrationOutput, EMKDatabaseMigrationProgressViewEventHandler>

@property (nonatomic, weak) id<EMKDatabaseMigrationProgressView> view;
@property (nonatomic, strong) id<EMKDatabaseMigrationProvider> provider;

@property (nonatomic, weak) EMKMainRouter *mainRouter;

@end

NS_ASSUME_NONNULL_END

//
//  EMKDatabaseMigrationProgressView.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import UIKit;

#import "EMKDatabaseMigrationProgressViewProtocol.h"
#import "EMKDatabaseMigrationProgressViewEventHandlerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMKDatabaseMigrationProgressView : UIViewController<EMKDatabaseMigrationProgressView>

@property (nonatomic, strong) id<EMKDatabaseMigrationProgressViewEventHandler> eventHandler;

@end

NS_ASSUME_NONNULL_END

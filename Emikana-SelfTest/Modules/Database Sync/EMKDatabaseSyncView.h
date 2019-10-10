//
//  EMKSyncViewController.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 07/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import UIKit;

#import "EMKDatabaseSyncViewProtocol.h"
#import "EMKDatabaseSyncEventHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMKDatabaseSyncView : UIViewController<EMKDatabaseSyncView>

@property (nonatomic, strong) id<EMKDatabaseSyncEventHandler> eventHandler;

@end

NS_ASSUME_NONNULL_END

//
//  AppDelegate.h
//  Emikana-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import UIKit;

#import "EMKCoreDataHelper.h"
#import "EMKDataSyncManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) EMKCoreDataHelper *coreDataHelper;
@property (nonatomic, strong, readonly) EMKDataSyncManager *dataSyncManager;

@end


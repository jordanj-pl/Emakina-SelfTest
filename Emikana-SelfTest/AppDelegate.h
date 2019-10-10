//
//  AppDelegate.h
//  Emikana-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import UIKit;

#import "EMKDatabaseManager.h"

@class EMKMainRouter;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//TODO It is only to preserv backward compatibility with non-VIPER modules. To be removed.
@property (nonatomic, strong, readonly) EMKMainRouter *mainRouter;

@end


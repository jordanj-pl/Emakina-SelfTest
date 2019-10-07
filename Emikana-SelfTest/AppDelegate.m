//
//  AppDelegate.m
//  Emikana-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize coreDataHelper = _coreDataHelper;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	_dataSyncManager = [EMKDataSyncManager new];
	[_dataSyncManager syncWithCompletionHandler:^(bool success) {
		if(success) {
			dispatch_async(dispatch_get_main_queue(), ^{
				UIApplication *app = [UIApplication sharedApplication];
				UINavigationController *nc = (UINavigationController*)app.keyWindow.rootViewController;

				UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
				UIViewController *rootVC = [sb instantiateViewControllerWithIdentifier:@"OfficesTable"];

				[nc setViewControllers:@[rootVC] animated:YES];
			});
		}
	}];


	return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.coreDataHelper backgroundSaveContext];
}

-(void)applicationWillTerminate:(UIApplication *)application {
	[self.coreDataHelper backgroundSaveContext];
}

#pragma mark - Core Data

-(EMKCoreDataHelper*)coreDataHelper {
    if(!_coreDataHelper) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _coreDataHelper = [EMKCoreDataHelper new];
        });

        [_coreDataHelper setupCoreData];
    }

    return _coreDataHelper;
}

@end

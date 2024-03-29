//
//  AppDelegate.m
//  Emikana-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "AppDelegate.h"

#import "EMKMainRouter.h"

@interface AppDelegate ()

//@property (nonatomic, strong, readonly) EMKMainRouter *mainRouter;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor clearColor];

	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil] instantiateInitialViewController]];
	self.window.rootViewController = nc;
	[self.window makeKeyAndVisible];

	_mainRouter = [EMKMainRouter new];
	[self.mainRouter startApp];

	return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.mainRouter.dbManager saveToPersistentStoreAsync];
}

-(void)applicationWillTerminate:(UIApplication *)application {
	[self.mainRouter.dbManager saveToPersistentStoreAsync];
}

@end

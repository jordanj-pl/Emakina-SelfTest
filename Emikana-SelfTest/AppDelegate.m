//
//  AppDelegate.m
//  Emikana-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "AppDelegate.h"

#import "EMKDataSyncManager.h"
#import "EMKDatabaseMigrationManager.h"

@interface AppDelegate ()

@property (nonatomic, strong, readonly) EMKDataSyncManager *dataSyncManager;

@end

@implementation AppDelegate

@synthesize dbManager = _dbManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	dispatch_semaphore_t migrationSemaphore = dispatch_semaphore_create(0);

	if(self.dbManager.isMigrationNeeded) {
		NSLog(@"PERFORM MIGRATION");

		__weak typeof(self) weakSelf = self;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			typeof(self) strongSelf = weakSelf;

			EMKDatabaseMigrationManager *migrationManager = [[EMKDatabaseMigrationManager alloc] initWithDatabaseManager:strongSelf.dbManager];
			[migrationManager migrateDatabaseWithCompletion:^(BOOL completed) {
				NSLog(@"Migration completed: %d", completed);
				[strongSelf.dbManager loadDatabase];
				dispatch_semaphore_signal(migrationSemaphore);
			} progressHandler:^(float progress) {
				NSLog(@"Migration progress: %f", progress);
			}];
		});
	} else {
		[self.dbManager loadDatabase];
		dispatch_semaphore_signal(migrationSemaphore);
	}

	__weak typeof(self) weakSelf = self;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		typeof(self) strongSelf = weakSelf;

		dispatch_semaphore_wait(migrationSemaphore, DISPATCH_TIME_FOREVER);

		strongSelf->_dataSyncManager = [[EMKDataSyncManager alloc] initWithDatabaseManager:strongSelf.dbManager];
		[strongSelf->_dataSyncManager syncWithCompletionHandler:^(bool success) {

			double waitUntilMainScreen = 0.7;
			if(!success) {
				//If error occurs during data sync screen should be shown a little bit longer to allow user to see that error occured.
				waitUntilMainScreen = 2.0;
			}

			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitUntilMainScreen * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

				UIApplication *app = [UIApplication sharedApplication];
				UINavigationController *nc = (UINavigationController*)app.keyWindow.rootViewController;

				UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
				UIViewController *rootVC = [sb instantiateViewControllerWithIdentifier:@"OfficesTable"];

				[nc setViewControllers:@[rootVC] animated:YES];
			});
		}];
	});

	return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.dbManager saveToPersistentStoreAsync];
}

-(void)applicationWillTerminate:(UIApplication *)application {
	[self.dbManager saveToPersistentStoreAsync];
}

#pragma mark - Core Data

-(EMKDatabaseManager*)dbManager {
    if(!_dbManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _dbManager = [EMKDatabaseManager new];
        });
    }

    return _dbManager;
}

@end

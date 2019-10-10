//
//  EMKMainRouter.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKMainRouter.h"

#import "EMKDatabaseMigrationProgressView.h"
#import "EMKDatabaseMigrationProgressPresenter.h"
#import "EMKDatabaseMigrationInteractor.h"

#import "EMKDatabaseSyncView.h"
#import "EMKDatabaseSyncPresenter.h"
#import "EMKDatabaseSyncInteractor.h"

@interface EMKMainRouter ()

@end

@implementation EMKMainRouter

@synthesize dbManager = _dbManager;

-(void)startApp {
	if(self.dbManager.isMigrationNeeded) {
		[self startDatabaseModelMigration];
	} else {
		[self startDatabaseSync];
	}
}

-(void)startDatabaseModelMigration {
	dispatch_async(dispatch_get_main_queue(), ^{

		UIApplication *app = [UIApplication sharedApplication];
		UINavigationController *nc = (UINavigationController*)app.keyWindow.rootViewController;

		UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
		EMKDatabaseMigrationProgressView *migrationView = [sb instantiateViewControllerWithIdentifier:@"databaseMigrationView"];

		EMKDatabaseMigrationProgressPresenter *presenter = [EMKDatabaseMigrationProgressPresenter new];
		presenter.view = migrationView;
		presenter.mainRouter = self;
		migrationView.eventHandler = presenter;

		EMKDatabaseMigrationInteractor *interactor = [[EMKDatabaseMigrationInteractor alloc] initWithDatabaseManager:self.dbManager];
		interactor.output = presenter;
		presenter.provider = interactor;

		[nc setViewControllers:@[migrationView] animated:YES];

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			[interactor migrateDatabase];
		});
	});
}

-(void)startDatabaseSync {
	[self.dbManager loadDatabase];

	dispatch_async(dispatch_get_main_queue(), ^{
		UIApplication *app = [UIApplication sharedApplication];
		UINavigationController *nc = (UINavigationController*)app.keyWindow.rootViewController;

		UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
		EMKDatabaseSyncView *syncView = [sb instantiateViewControllerWithIdentifier:@"databaseSyncView"];

		EMKDatabaseSyncPresenter *presenter = [EMKDatabaseSyncPresenter new];
		presenter.view = syncView;
		presenter.mainRouter = self;
		syncView.eventHandler = presenter;

		EMKDatabaseSyncInteractor *interactor = [[EMKDatabaseSyncInteractor alloc] initWithDatabaseManager:self.dbManager];
		interactor.output = presenter;

		presenter.provider = interactor;

		[nc setViewControllers:@[syncView] animated:YES];

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			[interactor sync];
		});
	});
}

-(void)startMainFlow {
	UIApplication *app = [UIApplication sharedApplication];
	UINavigationController *nc = (UINavigationController*)app.keyWindow.rootViewController;

	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	UIViewController *rootVC = [sb instantiateViewControllerWithIdentifier:@"OfficesTable"];

	[nc setViewControllers:@[rootVC] animated:YES];
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

//
//  EMKMainRouter.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKMainRouter.h"

#import "EMKRouter.h"

#import "EMKDatabaseMigrationProgressView.h"
#import "EMKDatabaseMigrationProgressPresenter.h"
#import "EMKDatabaseMigrationInteractor.h"

#import "EMKDatabaseSyncView.h"
#import "EMKDatabaseSyncPresenter.h"
#import "EMKDatabaseSyncInteractor.h"

#import "EMKOfficesRouter.h"

@interface EMKMainRouter ()

@property (nonatomic, strong) id<EMKRouter> currentRouter;

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
	self.currentRouter = [EMKOfficesRouter new];
	self.currentRouter.mainRouter = self;
	((EMKOfficesRouter*)self.currentRouter).dbManager = self.dbManager;

	UIApplication *app = [UIApplication sharedApplication];
	UINavigationController *nc = (UINavigationController*)app.keyWindow.rootViewController;

	[nc setViewControllers:@[self.currentRouter.mainView] animated:YES];
}

-(void)pushView:(id)view {
	UIApplication *app = [UIApplication sharedApplication];
	UINavigationController *nc = (UINavigationController*)app.keyWindow.rootViewController;

	[nc pushViewController:view animated:YES];
}

-(void)popView {
	UIApplication *app = [UIApplication sharedApplication];
	UINavigationController *nc = (UINavigationController*)app.keyWindow.rootViewController;

	[nc popViewControllerAnimated:YES];
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

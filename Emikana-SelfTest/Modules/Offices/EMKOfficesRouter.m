//
//  EMKOfficesRouter.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 11/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficesRouter.h"

@import UIKit;

#import "EMKOfficesView.h"
#import "EMKOfficesPresenter.h"
#import "EMKOfficesInteractor.h"

#import "EMKOfficeDetailsTableViewController.h"

@interface EMKOfficesRouter ()

@end

@implementation EMKOfficesRouter

-(id)mainView {
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	EMKOfficesView *view = [sb instantiateViewControllerWithIdentifier:@"OfficesTable"];

	EMKOfficesPresenter *presenter = [EMKOfficesPresenter new];
	presenter.view = view;
	presenter.router = self;

	view.eventHandler = presenter;

	EMKOfficesInteractor *interactor = [[EMKOfficesInteractor alloc] initWithDatabaseManager:self.dbManager];
	interactor.output = presenter;

	presenter.provider = interactor;

	return view;
}

-(void)presentOfficesList {

}

-(void)presentOfficeDetails:(NSManagedObjectID *)objectId {

	EMKOfficeDetailsTableViewController *officeView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"officeDetails"];
	officeView.officeID = objectId;

	[self.mainRouter pushView:officeView];
}

-(void)presentOfficeLocation:(NSManagedObjectID *)objectId {

}

@end

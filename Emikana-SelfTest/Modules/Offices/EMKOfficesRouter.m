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

#import "EMKOfficeDetailsView.h"
#import "EMKOfficeDetailsPresenter.h"
#import "EMKOfficeDetailsInteractor.h"

#import "EMKOfficeMapView.h"
#import "EMKOfficeMapPresenter.h"
#import "EMKOfficeMapInteractor.h"

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

	EMKOfficeDetailsView *view = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"officeDetails"];

	EMKOfficeDetailsPresenter *presenter = [EMKOfficeDetailsPresenter new];
	presenter.view = view;
	presenter.router = self;

	view.eventHandler = presenter;

	EMKOfficeDetailsInteractor *interactor = [[EMKOfficeDetailsInteractor alloc] initWithDatabaseManager:self.dbManager];
	interactor.output = presenter;

	presenter.provider = interactor;

	presenter.officeId = objectId;

	[self.mainRouter pushView:view];
}

-(void)presentOfficeLocation:(NSManagedObjectID *)objectId {
	EMKOfficeMapView *view = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"officeDetailsMap"];

	EMKOfficeMapPresenter *presenter = [EMKOfficeMapPresenter new];
	presenter.view = view;
	presenter.router = self;
	presenter.officeId = objectId;

	view.eventHandler = presenter;

	EMKOfficeMapInteractor *interactor = [[EMKOfficeMapInteractor alloc] initWithDatabaseManager:self.dbManager];
	interactor.output = presenter;

	presenter.provider = interactor;

	[self.mainRouter pushView:view];
}

@end

//
//  EMKOfficesPresenter.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 11/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficesPresenter.h"

@import CoreData;

@interface EMKOfficesPresenter ()

@property (nonatomic, strong) NSFetchedResultsController *frc;

@end

@implementation EMKOfficesPresenter

-(void)showOffices {
	[self.provider provideOffices];
}

-(void)didTapRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *office = [self.frc objectAtIndexPath:indexPath];
	[self.router presentOfficeDetails:office.objectID];
}

//This does not conform to VIPER but ensures CoreData built-in efficiency by using NSFetchedResultsController.
-(void)receiveOffices:(NSFetchedResultsController *)offices {
	self.frc = offices;
	//self.frc.delegate = self;
	[self.view setFetchedResultsController:self.frc];
}

-(void)receiveError:(NSString *)errorMsg {
	//TODO add error view
}

@end

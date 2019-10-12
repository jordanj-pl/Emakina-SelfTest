//
//  EMKOfficeDetailsInteractor.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficeDetailsInteractor.h"

#import "EMKDatabaseManager.h"
#import "Office+CoreDataProperties.h"

@interface EMKOfficeDetailsInteractor ()

@property (nonatomic, strong, readonly) EMKDatabaseManager *dbManager;

@end

@implementation EMKOfficeDetailsInteractor

-(instancetype)initWithDatabaseManager:(EMKDatabaseManager*)dbManager {
	self = [super init];
	if(!self) {
		return nil;
	}

	_dbManager = dbManager;

	return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
-(instancetype)init {
	@throw [NSException exceptionWithName:@"Designated initializer required" reason:@"Use initWithDatabaseManager: instead." userInfo:nil];
	return nil;
}
#pragma clang diagnostic pop

-(void)provideOfficeDetailsForOffice:(NSManagedObjectID *)officeId {
	Office *office = (Office*)[self.dbManager officeByManagedObjectId:officeId];

	EMKOfficeDetails details;
	details.name = office.name;
	details.street = office.street;
	details.zip = [office.zip stringValue];
	details.city = office.city;
	details.phone = office.phone;
	details.openingHours = office.openingHours;
	details.photo = [UIImage imageWithData:office.photoData];

	[self.output receiveOfficeDetails:details];
}

@end

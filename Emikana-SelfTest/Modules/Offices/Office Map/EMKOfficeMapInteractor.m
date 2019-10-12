//
//  EMKOfficeMapInteractor.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficeMapInteractor.h"

#import "EMKDatabaseManager.h"
#import "Office+CoreDataProperties.h"

@interface EMKOfficeMapInteractor ()

@property (nonatomic, strong, readonly) EMKDatabaseManager *dbManager;

@end

@implementation EMKOfficeMapInteractor

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

-(void)provideLocationForOffice:(NSManagedObjectID *)officeId {
	Office *office = [self.dbManager officeByManagedObjectId:officeId];

	EMKOfficeLocation location;
	location.latitude = office.locLatitude;
	location.longitude = office.locLongitude;
	location.countryCode = @"AT";//TODO it should be retrieved from API rather than hardcoded; Currently API does not provide such information.
	location.city = office.city;
	location.zip = [office.zip stringValue];
	location.street = office.street;

	[self.output receiveOfficeLocation:location];
}

@end

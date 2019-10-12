//
//  EMKOfficeMapPresenter.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficeMapPresenter.h"

@import MapKit;
@import Contacts;

@implementation EMKOfficeMapPresenter

-(void)showOfficeLocation {
	[self.provider provideLocationForOffice:self.officeId];
}

-(void)receiveOfficeLocation:(EMKOfficeLocation)location {
	CLLocationCoordinate2D officeLoc = CLLocationCoordinate2DMake(location.latitude, location.longitude);

	CNMutablePostalAddress *officeAddress = [[CNMutablePostalAddress alloc] init];
	officeAddress.city = location.city;
	officeAddress.street = location.street;
	officeAddress.postalCode = location.zip;
	officeAddress.ISOCountryCode = location.countryCode;

	MKPlacemark *officePlacemark = [[MKPlacemark alloc] initWithCoordinate:officeLoc postalAddress:officeAddress];

	[self.view setOfficePlacemark:officePlacemark];
}

@end

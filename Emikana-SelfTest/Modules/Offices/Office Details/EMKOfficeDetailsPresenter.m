//
//  EMKOfficeDetailsPresenter.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficeDetailsPresenter.h"

@implementation EMKOfficeDetailsPresenter

-(void)showOfficeDetails {
	[self.provider provideOfficeDetailsForOffice:self.officeId];
}

-(void)showOfficeMap {
	[self.router presentOfficeLocation:self.officeId];
}

-(void)receiveOfficeDetails:(EMKOfficeDetails)details {
	[self.view setOfficeName:details.name];
	[self.view setOfficeAddress:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Address:\n%@ %@, %@", @"OfficesMsgs", @"Address:\n%@ %@, %@"), details.zip, details.city, details.street]];
	[self.view setOfficePhone: [NSString stringWithFormat: NSLocalizedStringFromTable(@"Phone:\n%@", @"OfficesMsgs", @"Phone:\n%@"), details.phone]];
	[self.view setOfficeOpeningHours: [NSString stringWithFormat: NSLocalizedStringFromTable(@"Opening Hours:\n%@", @"OfficesMsgs", @"Opening Hours:\n%@"), details.openingHours]];
	[self.view setOfficePhoto:details.photo];
}

@end

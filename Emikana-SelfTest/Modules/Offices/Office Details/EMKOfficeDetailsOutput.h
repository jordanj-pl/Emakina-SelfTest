//
//  EMKOfficeDetailsOutput.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKOfficeDetailsOutput_h
#define EMKOfficeDetailsOutput_h

@class UIImage;

typedef struct {
	NSString *name;
	NSString *phone;
	NSString *street;
	NSString *city;
	NSString *zip;
	NSString *openingHours;
	UIImage *photo;
} EMKOfficeDetails;

@protocol EMKOfficeDetailsOutput <NSObject>

-(void)receiveOfficeDetails:(EMKOfficeDetails)details;

@end

#endif /* EMKOfficeDetailsOutput_h */

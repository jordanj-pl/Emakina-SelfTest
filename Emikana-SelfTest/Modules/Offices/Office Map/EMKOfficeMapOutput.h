//
//  EMKOfficeMapOutput.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKOfficeMapOutput_h
#define EMKOfficeMapOutput_h

typedef struct {
	double latitude;
	double longitude;
	NSString *street;
	NSString *city;
	NSString *zip;
	NSString *countryCode;
} EMKOfficeLocation;

@protocol EMKOfficeMapOutput <NSObject>

-(void)receiveOfficeLocation:(EMKOfficeLocation)location;

@end

#endif /* EMKOfficeMapOutput_h */

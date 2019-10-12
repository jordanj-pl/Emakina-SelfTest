//
//  EMKOfficeMapProvider.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKOfficeMapProvider_h
#define EMKOfficeMapProvider_h

@class NSManagedObjectID;

@protocol EMKOfficeMapProvider <NSObject>

-(void)provideLocationForOffice:(NSManagedObjectID*)officeId;

@end
#endif /* EMKOfficeMapProvider_h */

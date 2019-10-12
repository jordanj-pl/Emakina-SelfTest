//
//  EMKOfficeDetailsProvider.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKOfficeDetailsProvider_h
#define EMKOfficeDetailsProvider_h

@class NSManagedObjectID;

@protocol EMKOfficeDetailsProvider <NSObject>

-(void)provideOfficeDetailsForOffice:(NSManagedObjectID*)officeId;

@end

#endif /* EMKOfficeDetailsProvider_h */

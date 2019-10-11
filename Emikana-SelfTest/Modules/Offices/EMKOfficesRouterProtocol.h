//
//  EMKOfficesRouterProtocol.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKOfficesRouterProtocol_h
#define EMKOfficesRouterProtocol_h

#import "EMKRouter.h"

@class NSManagedObjectID;

@protocol EMKOfficesRouter <EMKRouter>

-(void)presentOfficesList;
-(void)presentOfficeDetails:(NSManagedObjectID*)objectId;
-(void)presentOfficeLocation:(NSManagedObjectID*)objectId;

@end

#endif /* EMKOfficesRouterProtocol_h */

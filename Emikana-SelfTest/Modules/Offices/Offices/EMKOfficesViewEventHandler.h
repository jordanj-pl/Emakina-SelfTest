//
//  EMKOfficesViewEventHandler.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 11/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKOfficesViewEventHandler_h
#define EMKOfficesViewEventHandler_h

@class NSIndexPath;

@protocol EMKOfficesViewEventHandler <NSObject>

-(void)showOffices;
-(void)didTapRowAtIndexPath:(NSIndexPath*)indexPath;

@end

#endif /* EMKOfficesViewEventHandler_h */

//
//  EMKOfficeMapViewProtocol.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKOfficeMapViewProtocol_h
#define EMKOfficeMapViewProtocol_h

@class MKPlacemark;

@protocol EMKOfficeMapView <NSObject>

-(void)setOfficePlacemark:(MKPlacemark*)placemark;

@end

#endif /* EMKOfficeMapViewProtocol_h */

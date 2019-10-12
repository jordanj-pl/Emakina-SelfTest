//
//  EMKOfficeDetailsViewProtocol.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKOfficeDetailsViewProtocol_h
#define EMKOfficeDetailsViewProtocol_h

@class UIImage;

@protocol EMKOfficeDetailsView <NSObject>

-(void)setOfficeName:(NSString*)name;
-(void)setOfficeAddress:(NSString*)address;
-(void)setOfficeOpeningHours:(NSString*)openingHours;
-(void)setOfficePhone:(NSString*)phone;
-(void)setOfficePhoto:(UIImage*)photo;

@end

#endif /* EMKOfficeDetailsViewProtocol_h */

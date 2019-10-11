//
//  EMKOfficesViewProtocol.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 11/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKOfficesViewProtocol_h
#define EMKOfficesViewProtocol_h
@class NSFetchedResultsController;

@protocol EMKOfficesView <NSObject>

-(void)setFetchedResultsController:(NSFetchedResultsController*)frc;

@end

#endif /* EMKOfficesViewProtocol_h */

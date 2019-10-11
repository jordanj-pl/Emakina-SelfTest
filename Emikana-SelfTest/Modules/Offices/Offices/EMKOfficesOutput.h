//
//  EMKOfficesOutput.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 11/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKOfficesOutput_h
#define EMKOfficesOutput_h

@class NSFetchedResultsController;

@protocol EMKOfficesOutput <NSObject>

-(void)receiveOffices:(NSFetchedResultsController*)offices;
-(void)receiveError:(NSString*)errorMsg;

@end

#endif /* EMKOfficesOutput_h */

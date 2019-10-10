//
//  EMKDatabaseSyncViewProtocol.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKDatabaseSyncViewProtocol_h
#define EMKDatabaseSyncViewProtocol_h

@protocol EMKDatabaseSyncView <NSObject>

-(void)setStatus:(NSString*)status;
-(void)setProgress:(float)progress;

@end

#endif /* EMKDatabaseSyncViewProtocol_h */

//
//  EMKDatabaseSyncOutput.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKDatabaseSyncOutput_h
#define EMKDatabaseSyncOutput_h

@protocol EMKDatabaseSyncOutput <NSObject>

-(void)didCompleteWithSuccess:(BOOL)success;
-(void)receiveStatus:(NSString*)status;
-(void)receiveProgress:(float)progress;

@end

#endif /* EMKDatabaseSyncOutput_h */

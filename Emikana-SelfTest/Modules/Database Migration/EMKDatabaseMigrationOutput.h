//
//  EMKDatabaseMigrationOutput.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKDatabaseMigrationOutput_h
#define EMKDatabaseMigrationOutput_h

@protocol EMKDatabaseMigrationOutput <NSObject>

-(void)didFinishMigrationWithSuccess:(BOOL)success;
-(void)receiveStatus:(NSString*)status;
-(void)receiveProgress:(float)progress;

@end

#endif /* EMKDatabaseMigrationOutput_h */

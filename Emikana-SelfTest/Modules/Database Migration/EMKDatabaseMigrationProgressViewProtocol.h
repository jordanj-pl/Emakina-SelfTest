//
//  EMKDatabaseMigrationProgressViewProtocol.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKDatabaseMigrationProgressViewProtocol_h
#define EMKDatabaseMigrationProgressViewProtocol_h

@protocol EMKDatabaseMigrationProgressView <NSObject>

-(void)setStatus:(NSString*)status;
-(void)setProgress:(float)progress;

@end

#endif /* EMKDatabaseMigrationProgressViewProtocol_h */

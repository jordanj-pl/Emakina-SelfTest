//
//  EMKDatabaseMigrationProvider.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKDatabaseMigrationProvider_h
#define EMKDatabaseMigrationProvider_h

@protocol EMKDatabaseMigrationProvider <NSObject>

-(void)migrateDatabase;

@end

#endif /* EMKDatabaseMigrationProvider_h */

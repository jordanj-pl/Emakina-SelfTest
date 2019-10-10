//
//  EMKMigrationProgressPresenter.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDatabaseMigrationProgressPresenter.h"

@implementation EMKDatabaseMigrationProgressPresenter

-(void)receiveStatus:(NSString *)status {
	[self.view setStatus:status];
}

-(void)receiveProgress:(float)progress {
	[self.view setProgress:progress];
}

-(void)didFinishMigrationWithSuccess:(BOOL)success {
	NSLog(@"---------- MIGRATION RESULT: %d", success);
	[self.mainRouter startDatabaseSync];
}

@end

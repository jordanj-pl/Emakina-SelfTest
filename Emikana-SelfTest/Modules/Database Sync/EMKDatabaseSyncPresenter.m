//
//  EMKDatabaseSyncPresenter.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDatabaseSyncPresenter.h"

@implementation EMKDatabaseSyncPresenter

-(void)didCompleteWithSuccess:(BOOL)success {
	double waitUntilMainScreen = 0.7;
	if(!success) {
		//If error occurs during data sync screen should be shown a little bit longer to allow user to see that error occured.
		waitUntilMainScreen = 2.0;
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitUntilMainScreen * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

		[self.mainRouter startMainFlow];
	});
}

-(void)receiveStatus:(NSString *)status {
	[self.view setStatus:status];
}

-(void)receiveProgress:(float)progress {
	[self.view setProgress:progress];
}

@end

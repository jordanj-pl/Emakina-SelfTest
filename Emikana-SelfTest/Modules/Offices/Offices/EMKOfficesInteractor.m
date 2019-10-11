//
//  EMKOfficesInteractor.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 11/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficesInteractor.h"

#import "EMKDatabaseManager.h"

@interface EMKOfficesInteractor ()

@property (nonatomic, strong, readonly) EMKDatabaseManager *dbManager;

@end

@implementation EMKOfficesInteractor

-(instancetype)initWithDatabaseManager:(EMKDatabaseManager*)dbManager {
	self = [super init];
	if(!self) {
		return nil;
	}

	_dbManager = dbManager;

	return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
-(instancetype)init {
	@throw [NSException exceptionWithName:@"Designated initializer required" reason:@"Use initWithDatabaseManager: instead." userInfo:nil];
	return nil;
}
#pragma clang diagnostic pop

-(void)provideOffices {

	NSFetchedResultsController *frc = self.dbManager.allOffices;

	[frc.managedObjectContext performBlockAndWait:^{
		NSError *error = nil;
		if(![frc performFetch:&error]) {
			NSLog(@"FAILED to perform fetch: %@", error);
			[self.output receiveError:@"Data unavailable"];
		} else {
			[self.output receiveOffices:frc];
		}
	}];
}

@end

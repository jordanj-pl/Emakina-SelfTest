//
//  EMKDatabaseMigrationManager.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 09/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDatabaseMigrationInteractor.h"

#import "EMKDatabaseManager.h"

@interface EMKDatabaseMigrationInteractor ()

@property (nonatomic, strong, readonly) EMKDatabaseManager *dbManager;

@end

@implementation EMKDatabaseMigrationInteractor

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

-(void)migrateDatabase {

	dispatch_async(dispatch_get_main_queue(), ^{
		[self.output receiveStatus:@"Migrating DB model..."];
	});

	__weak typeof(self) weakSelf = self;
	[self.dbManager migrateDatabaseWithCompletion:^(BOOL success) {
		typeof(self) strongSelf = weakSelf;

		dispatch_async(dispatch_get_main_queue(), ^{
			if(success) {
				[strongSelf.output receiveStatus:@"Migration completed"];
			} else {
				[strongSelf.output receiveStatus:@"Migration failed!"];
			}
			[strongSelf.output didFinishMigrationWithSuccess:success];
		});
	} progressHandler:^(float progress) {
		typeof(self) strongSelf = weakSelf;

		dispatch_async(dispatch_get_main_queue(), ^{
			[strongSelf.output receiveProgress:progress];
		});

	}];
}


@end

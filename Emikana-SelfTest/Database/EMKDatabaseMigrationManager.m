//
//  EMKDatabaseMigrationManager.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 09/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDatabaseMigrationManager.h"

#import "EMKDatabaseManager.h"

@interface EMKDatabaseMigrationManager ()

@property (nonatomic, strong, readonly) EMKDatabaseManager *dbManager;

@end

@implementation EMKDatabaseMigrationManager

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

-(void)migrateDatabaseWithCompletion:(void(^)(BOOL))completionHandler progressHandler:(void(^)(float progress))progressHanlder {

	[self.dbManager migrateDatabaseWithCompletion:completionHandler progressHandler:progressHanlder];

}


@end

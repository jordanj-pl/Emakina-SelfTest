//
//  EMKDataSyncManager.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDataSyncManager.h"

@import Reachability;

#import "EMKConstans.h"

@interface EMKDataSyncManager ()

@property (nonatomic, strong) Reachability *reachability;

@end

@implementation EMKDataSyncManager

-(instancetype)init {
	self = [super init];
	if(self) {
		self.reachability = [Reachability reachabilityWithHostName:kEMKAPIdomain];
		[self.reachability startNotifier];
	}
	return self;
}

-(void)dealloc {
	[self.reachability stopNotifier];
}

-(void)sync {
	if(!self.reachability.isReachable) {
		return;
	}

	
}

@end

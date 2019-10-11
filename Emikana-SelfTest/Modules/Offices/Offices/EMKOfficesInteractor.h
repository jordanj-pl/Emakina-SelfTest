//
//  EMKOfficesInteractor.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 11/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKOfficesOutput.h"
#import "EMKOfficesProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class EMKDatabaseManager;

@interface EMKOfficesInteractor : NSObject<EMKOfficesProvider>

@property (nonatomic, weak) id<EMKOfficesOutput> output;

-(instancetype)initWithDatabaseManager:(EMKDatabaseManager*)dbManager NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

//
//  EMKOfficeDetailsInteractor.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKOfficeDetailsProvider.h"
#import "EMKOfficeDetailsOutput.h"

@class EMKDatabaseManager;

NS_ASSUME_NONNULL_BEGIN

@interface EMKOfficeDetailsInteractor : NSObject<EMKOfficeDetailsProvider>

@property (nonatomic, weak) id<EMKOfficeDetailsOutput> output;

-(instancetype)initWithDatabaseManager:(EMKDatabaseManager*)dbManager NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

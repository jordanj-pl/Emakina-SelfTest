//
//  EMKOfficeMapInteractor.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKOfficeMapProvider.h"
#import "EMKOfficeMapOutput.h"

@class EMKDatabaseManager;

NS_ASSUME_NONNULL_BEGIN

@interface EMKOfficeMapInteractor : NSObject<EMKOfficeMapProvider>

-(instancetype)initWithDatabaseManager:(EMKDatabaseManager*)dbManager NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) id<EMKOfficeMapOutput> output;

@end

NS_ASSUME_NONNULL_END

//
//  EMKOfficesRouter.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 11/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKOfficesRouterProtocol.h"

#import "EMKMainRouter.h"
NS_ASSUME_NONNULL_BEGIN

@class EMKDatabaseManager;

@interface EMKOfficesRouter : NSObject<EMKOfficesRouter>

@property (nonatomic, weak) EMKMainRouter *mainRouter;
@property (nonatomic, strong) EMKDatabaseManager *dbManager;

@end

NS_ASSUME_NONNULL_END

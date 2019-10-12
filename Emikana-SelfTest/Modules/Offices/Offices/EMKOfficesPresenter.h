//
//  EMKOfficesPresenter.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 11/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKOfficesEventHandler.h"
#import "EMKOfficesViewProtocol.h"
#import "EMKOfficesOutput.h"
#import "EMKOfficesProvider.h"

#import "EMKOfficesRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMKOfficesPresenter : NSObject<EMKOfficesEventHandler, EMKOfficesOutput>

@property (nonatomic, strong) id<EMKOfficesProvider> provider;
@property (nonatomic, weak) id<EMKOfficesView> view;
@property (nonatomic, weak) EMKOfficesRouter *router;

@end

NS_ASSUME_NONNULL_END

//
//  EMKOfficeDetailsPresenter.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKOfficeDetailsViewProtocol.h"
#import "EMKOfficeDetailsEventHandler.h"
#import "EMKOfficeDetailsProvider.h"
#import "EMKOfficeDetailsOutput.h"

#import "EMKOfficesRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMKOfficeDetailsPresenter : NSObject<EMKOfficeDetailsEventHandler, EMKOfficeDetailsOutput>

@property (nonatomic, weak) id<EMKOfficeDetailsView> view;
@property (nonatomic, strong) id<EMKOfficeDetailsProvider> provider;

@property (nonatomic, weak) EMKOfficesRouter *router;

@property (nonatomic, strong) NSManagedObjectID *officeId;
@end

NS_ASSUME_NONNULL_END

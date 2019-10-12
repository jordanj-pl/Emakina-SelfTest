//
//  EMKOfficeMapPresenter.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 12/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKOfficeMapProvider.h"
#import "EMKOfficeMapOutput.h"
#import "EMKOfficeMapEventHandler.h"
#import "EMKOfficeMapViewProtocol.h"

#import "EMKOfficesRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMKOfficeMapPresenter : NSObject<EMKOfficeMapEventHandler, EMKOfficeMapOutput>

@property (nonatomic, weak) id<EMKOfficeMapView> view;
@property (nonatomic, strong) id<EMKOfficeMapProvider> provider;

@property (nonatomic, weak) EMKOfficesRouter *router;

@property (nonatomic, strong) NSManagedObjectID *officeId;

@end

NS_ASSUME_NONNULL_END

//
//  EMKOfficeMapViewController.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 08/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "EMKOfficeMapViewProtocol.h"
#import "EMKOfficeMapEventHandler.h"
NS_ASSUME_NONNULL_BEGIN

@interface EMKOfficeMapView : UIViewController<EMKOfficeMapView>

@property (nonatomic, strong) id<EMKOfficeMapEventHandler> eventHandler;

@end

NS_ASSUME_NONNULL_END

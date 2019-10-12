//
//  OfficeDetailsTableViewController.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 07/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "EMKOfficeDetailsViewProtocol.h"
#import "EMKOfficeDetailsEventHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMKOfficeDetailsView : UITableViewController<EMKOfficeDetailsView>

@property (nonatomic, strong) id<EMKOfficeDetailsEventHandler> eventHandler;

@end

NS_ASSUME_NONNULL_END

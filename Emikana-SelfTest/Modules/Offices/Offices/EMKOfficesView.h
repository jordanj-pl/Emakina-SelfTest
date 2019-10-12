//
//  EMKOfficesTableViewController.h
//  Emikana-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import UIKit;

#import "EMKOfficesViewProtocol.h"
#import "EMKOfficesEventHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMKOfficesView : UITableViewController<EMKOfficesView>

@property (nonatomic, strong) id<EMKOfficesEventHandler> eventHandler;

@end

NS_ASSUME_NONNULL_END

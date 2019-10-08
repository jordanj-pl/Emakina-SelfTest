//
//  OfficeDetailsTableViewController.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 07/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import UIKit;
@import CoreData;

NS_ASSUME_NONNULL_BEGIN

@interface EMKOfficeDetailsTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectID *officeID;

@end

NS_ASSUME_NONNULL_END
//
//  EMKOfficeTableViewCell.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 07/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface EMKOfficeTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

@end

NS_ASSUME_NONNULL_END

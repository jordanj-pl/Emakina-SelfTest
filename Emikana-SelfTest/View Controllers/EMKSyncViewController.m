//
//  EMKSyncViewController.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 07/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKSyncViewController.h"

#import "EMKDataSyncManager.h"

@interface EMKSyncViewController ()

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

@end

@implementation EMKSyncViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	__weak typeof(self) weakSelf = self;

    [[NSNotificationCenter defaultCenter] addObserverForName:kEMKDataSyncManagerProgressNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {

		typeof(self) strongSelf = weakSelf;

		strongSelf.statusLabel.text = note.userInfo[@"status"];
		[strongSelf.progressView setProgress:[note.userInfo[@"progress"] floatValue] animated:YES];
	}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

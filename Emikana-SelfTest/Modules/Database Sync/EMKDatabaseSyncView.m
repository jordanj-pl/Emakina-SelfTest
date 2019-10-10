//
//  EMKSyncViewController.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 07/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDatabaseSyncView.h"

@interface EMKDatabaseSyncView ()

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

@end

@implementation EMKDatabaseSyncView

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)setStatus:(NSString *)status {
	self.statusLabel.text = status;
}

-(void)setProgress:(float)progress {
	[self.progressView setProgress:progress animated:YES];
}

@end

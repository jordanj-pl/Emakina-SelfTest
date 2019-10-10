//
//  EMKDatabaseMigrationProgressView.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDatabaseMigrationProgressView.h"

@interface EMKDatabaseMigrationProgressView ()

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

@end

@implementation EMKDatabaseMigrationProgressView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)setStatus:(NSString *)status {
	self.statusLabel.text = status;
}

-(void)setProgress:(float)progress {
	[self.progressView setProgress:progress animated:YES];
}

@end

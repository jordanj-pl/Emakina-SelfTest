//
//  EMKMainRouter.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 10/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

#import "EMKDatabaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMKMainRouter : NSObject

@property (nonatomic, strong, readonly) EMKDatabaseManager *dbManager;

-(void)startApp;

-(void)startDatabaseModelMigration;
-(void)startDatabaseSync;
-(void)startMainFlow;

-(void)pushView:(id)view;
-(void)popView;

@end

NS_ASSUME_NONNULL_END

//
//  EMKDataSyncManager.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface EMKDataSyncManager : NSObject

-(void)syncWithCompletionHandler:(void (^)(bool))completion;

@end

NS_ASSUME_NONNULL_END

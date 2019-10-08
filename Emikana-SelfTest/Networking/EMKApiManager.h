//
//  ApiManager.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 08/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const EMKAPIErrorInvalidDataDomain;
extern NSString *const EMKAPIErrorUnexpectedResponseDomain;

typedef void(^ApiManagerErrorHandler)(NSError *error);
typedef void(^ApiManagerListOfOfficesHandler)(NSString *Etag, NSArray *offices);
typedef void(^ApiManagerDataHandler)(NSData *imgData);

@interface EMKApiManager : NSObject

-(instancetype)initWithQueue:(nullable NSOperationQueue*)queue NS_DESIGNATED_INITIALIZER;

-(bool)isServerReachable;
-(void)retrieveListOfOfficesWithCompletionHandler:(ApiManagerListOfOfficesHandler)completion error:(ApiManagerErrorHandler)errorHandler;
-(void)retrieveDataFromURL:(NSURL*)url completionHandler:(ApiManagerDataHandler)completion error:(ApiManagerErrorHandler)errorHandler;

@end

NS_ASSUME_NONNULL_END

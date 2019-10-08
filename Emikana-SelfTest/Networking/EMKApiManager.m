//
//  ApiManager.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 08/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKApiManager.h"

@import Reachability;

#import "EMKConstans.h"

NSString *const EMKAPIErrorInvalidDataDomain = @"EMKAPIErrorInvalidDataDomain";
NSString *const EMKAPIErrorUnexpectedResponseDomain = @"EMKAPIErrorUnexpectedResponseDomain";

NSString *kOfficesEndpoint = @"Finanzamtsliste.json";

@interface EMKApiManager ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSURLSession *urlSession;

@end

@implementation EMKApiManager

-(instancetype)init {
	return [self initWithQueue:nil];
}

-(instancetype)initWithQueue:(NSOperationQueue *)queue {
	self = [super init];
	if(self) {
		_queue = queue;

		_reachability = [Reachability reachabilityWithHostName:kEMKAPIdomain];
		[_reachability startNotifier];

		_urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:_queue];
	}
	return self;
}

-(void)dealloc {
	[self.reachability stopNotifier];
}

-(BOOL)isServerReachable {
	return self.reachability.isReachable;
}

-(void)retrieveListOfOfficesWithCompletionHandler:(ApiManagerListOfOfficesHandler)completion error:(ApiManagerErrorHandler)errorHandler {

	NSURL *endpointUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kEMKApiProtocol, kEMKAPIdomain]];
	endpointUrl = [endpointUrl URLByAppendingPathComponent:kOfficesEndpoint];

	NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithURL:endpointUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

		if(((NSHTTPURLResponse*)response).statusCode != 200) {
			errorHandler([NSError errorWithDomain:EMKAPIErrorUnexpectedResponseDomain code:0 userInfo:@{
				NSLocalizedFailureReasonErrorKey: @"Unexpected server response"
			}]);
			return;
		}

		NSString *etag = ((NSHTTPURLResponse*)response).allHeaderFields[@"Etag"];

			//TODO This is inefficient workaround which is forced by server which does not return valid UTF-8 encoded data. The server should return valid UTF-8 encoded data or header containing content encoding. The workaround may stop working properly if server encoding changes!!!!!
		NSString *latin1String = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
		NSData *utf8Data = [latin1String dataUsingEncoding:NSUTF8StringEncoding];

		NSError *deserializationError;
		id jsonObj = [NSJSONSerialization JSONObjectWithData:utf8Data options:0 error:&deserializationError];
		if(!jsonObj) {
			errorHandler([NSError errorWithDomain:EMKAPIErrorInvalidDataDomain code:0 userInfo:@{
				NSLocalizedFailureReasonErrorKey: @"Server returned invalid data"
			}]);
			return;
		}

		if(![jsonObj isKindOfClass:[NSArray class]]) {
			errorHandler([NSError errorWithDomain:EMKAPIErrorInvalidDataDomain code:0 userInfo:@{
				NSLocalizedFailureReasonErrorKey: @"Server returned invalid data"
			}]);
			return;
		}

		completion(etag, jsonObj);
	}];

	[dataTask resume];
}

-(void)retrieveDataFromURL:(NSURL *)url completionHandler:(ApiManagerDataHandler)completion error:(ApiManagerErrorHandler)errorHandler {

	NSURLSessionDataTask *downloadTask = [self.urlSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

		if(((NSHTTPURLResponse*)response).statusCode != 200) {
			errorHandler([NSError errorWithDomain:EMKAPIErrorUnexpectedResponseDomain code:0 userInfo:@{
				NSLocalizedFailureReasonErrorKey: @"Unexpected server response"
			}]);
			return;
		}

		if(!data || data.length == 0) {
			errorHandler([NSError errorWithDomain:EMKAPIErrorInvalidDataDomain code:0 userInfo:@{
				NSLocalizedFailureReasonErrorKey: @"Server returned invalid data"
			}]);
			return;
		}

		completion(data);
	}];

	[downloadTask resume];
}

@end

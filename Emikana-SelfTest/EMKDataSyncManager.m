//
//  EMKDataSyncManager.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKDataSyncManager.h"

@import Reachability;
@import CoreData;

#import "EMKConstans.h"
#import "AppDelegate.h"

#import "Office+CoreDataClass.h"
#import "Office+CoreDataProperties.h"

NSString *kOfficesRetrieveQueue = @"aero.skyisthelimit.EMKOfficesRetrieveQueue";

NSString *kOfficesEndpoint = @"Finanzamtsliste.json";

@interface EMKDataSyncManager ()<NSURLSessionDelegate>

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSOperationQueue *syncOfficesQueue;
@property (nonatomic, strong) NSURLSession *urlSession;


@end

@implementation EMKDataSyncManager

-(instancetype)init {
	self = [super init];
	if(self) {
		self.reachability = [Reachability reachabilityWithHostName:kEMKAPIdomain];
		[self.reachability startNotifier];

		self.syncOfficesQueue = [NSOperationQueue new];
		self.syncOfficesQueue.name = kOfficesRetrieveQueue;

		self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.syncOfficesQueue];
	}
	return self;
}

-(void)dealloc {
	[self.reachability stopNotifier];
}

-(void)sync {

	if(!self.reachability.isReachable) {
		NSLog(@"Sync server is offline");
		return;
	}

	NSURL *endpointUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kEMKApiProtocol, kEMKAPIdomain]];
	endpointUrl = [endpointUrl URLByAppendingPathComponent:kOfficesEndpoint];

	__weak typeof(self) weakSelf = self;
	NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithURL:endpointUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		typeof(self) strongSelf = weakSelf;

		NSString *etag = ((NSHTTPURLResponse*)response).allHeaderFields[@"Etag"];

		//TODO This is inefficient workaround which is forced by server which does not return valid UTF-8 encoded data. The server should return valid UTF-8 encoded data or header containing content encoding. The workaround may stop working properly if server encoding changes!!!!!
		NSString *latin1String = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
		NSData *utf8Data = [latin1String dataUsingEncoding:NSUTF8StringEncoding];

		[strongSelf syncWithDatabase:utf8Data etag: etag];
	}];
	[dataTask resume];
}

-(void)syncWithDatabase:(NSData*)data etag:(NSString*)etag {
	NSLog(@"QUEUE: %@", [NSOperationQueue currentQueue]);
	NSLog(@"Etag: %@", etag);
	NSLog(@"DATA: %@", data);

	NSError *deserializationError;

	id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&deserializationError];
	if(!jsonObj) {
		NSLog(@"JSON error: %@", deserializationError);
		//TODO handle error
		return;
	}

	if(![jsonObj isKindOfClass:[NSArray class]]) {
		NSLog(@"JSON Root is not a type of list");
		//TODO handle error
		return;
	}

	__block EMKCoreDataHelper *cdh;
	dispatch_sync(dispatch_get_main_queue(), ^{
		cdh = ((AppDelegate*)[UIApplication sharedApplication].delegate).coreDataHelper;
	});

	__weak typeof(self) weakSelf = self;

	for (NSDictionary *officeProperties in jsonObj) {
		NSLog(@"Office: %@", officeProperties);
		[cdh.importContext performBlockAndWait:^{
			typeof(self) strongSelf = weakSelf;

			Office *office = (Office*)[strongSelf insertUniqueObjectInTargetEntity:@"Office" uniqueAttributeKey:@"identifier" uniqueAttributeValue:officeProperties[@"DisId"] attributeValues:officeProperties inContext:cdh.importContext];

			[office setValuesForKeysWithDictionary:officeProperties];

			[strongSelf saveContext:cdh.importContext];
		}];
	}
}

#pragma mark - CoreData methods

-(NSManagedObject*)existingObjectInContext:(NSManagedObjectContext*)context forEntiry:(NSString*)entity withUniqueAttributeKey:(NSString*)uniqueAttributeKey andValue:(NSString*)uniqueAttributeValue {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K==%@", uniqueAttributeKey, uniqueAttributeValue];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    fetchRequest.predicate = predicate;
    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSArray *fetchRequestResults = [context executeFetchRequest:fetchRequest error:&error];

    if(!fetchRequestResults) {
        NSLog(@"Error: %@", error.localizedDescription);
    }

    if(fetchRequestResults.count == 0) {
        return nil;
    }

    return fetchRequestResults.lastObject;
}

-(NSManagedObject*)insertUniqueObjectInTargetEntity:(NSString *)entity uniqueAttributeKey:(NSString *)uniqueAttributeKey uniqueAttributeValue:(NSString *)uniqueAttributeValue attributeValues:(NSDictionary *)attributeValues inContext:(NSManagedObjectContext *)context {

    if(uniqueAttributeValue.length > 0) {
        NSManagedObject *existingObject = [self existingObjectInContext:context
                                                              forEntiry:entity
                                               withUniqueAttributeKey:uniqueAttributeKey
                                               andValue: uniqueAttributeValue];

        if(existingObject) {
            return existingObject;
        } else {
            NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
            [newObject setValuesForKeysWithDictionary:attributeValues];
            return newObject;
        }
    } else {
        NSLog(@"Skipped %@ object creation: unique attribute value is 0 length", entity);
        return nil;
    }
}

-(void)saveContext:(NSManagedObjectContext*)context {

    [context performBlockAndWait:^{
        if(context.hasChanges) {
            NSError *error = nil;

            if([context save:&error]) {
                NSLog(@"CoreDataImporter SAVED changes from import context to parent context");
            } else {
                NSLog(@"CoreDataImporter FAILED to save changes from import context to parent context: %@", error);
            }
        } else {
            NSLog(@"CoreDataImporter SKIPPED saving context as there are no changes");
        }
    }];
}

@end

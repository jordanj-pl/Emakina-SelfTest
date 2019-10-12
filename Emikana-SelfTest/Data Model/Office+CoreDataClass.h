//
//  Office+CoreDataClass.h
//  
//
//  Created by Jordan Jasinski on 06/10/2019.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface Office : NSManagedObject

-(void)setValuesForKeysWithDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END

#import "Office+CoreDataProperties.h"

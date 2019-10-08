//
//  Office+CoreDataProperties.h
//  
//
//  Created by Jordan Jasinski on 06/10/2019.
//
//

#import "Office+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Office (CoreDataProperties)

+ (NSFetchRequest<Office *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nonatomic) double locLatitude;
@property (nonatomic) double locLongitude;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *openingHours;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, copy) NSURL *photoUrl;
@property (nullable, nonatomic, copy) NSData *photoData;
@property (nullable, nonatomic, copy) NSString *street;
@property (nullable, nonatomic, copy) NSDecimalNumber *zip;

@end

NS_ASSUME_NONNULL_END

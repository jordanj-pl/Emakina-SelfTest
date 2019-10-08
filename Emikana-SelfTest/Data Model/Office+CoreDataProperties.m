//
//  Office+CoreDataProperties.m
//  
//
//  Created by Jordan Jasinski on 06/10/2019.
//
//

#import "Office+CoreDataProperties.h"

@implementation Office (CoreDataProperties)

+ (NSFetchRequest<Office *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Office"];
}

@dynamic city;
@dynamic identifier;
@dynamic locLatitude;
@dynamic locLongitude;
@dynamic name;
@dynamic openingHours;
@dynamic phone;
@dynamic photoUrl;
@dynamic photoData;
@dynamic street;
@dynamic zip;

@end

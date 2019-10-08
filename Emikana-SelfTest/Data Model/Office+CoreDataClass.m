//
//  Office+CoreDataClass.m
//  
//
//  Created by Jordan Jasinski on 06/10/2019.
//
//

#import "Office+CoreDataClass.h"

@implementation Office

-(void)setValuesForKeysWithDictionary:(NSDictionary *)dictionary {

	self.identifier = dictionary[@"DisKz"];
	self.name = dictionary[@"DisNameLang"];

	NSNumberFormatter *zipFormatter = [NSNumberFormatter new];
	zipFormatter.numberStyle = NSNumberFormatterNoStyle;

	self.zip = [NSDecimalNumber decimalNumberWithString:dictionary[@"DisPlz"]];

	self.city = dictionary[@"DisOrt"];
	self.street = dictionary[@"DisStrasse"];
	self.phone = dictionary[@"DisTel"];
	self.openingHours = dictionary[@"DisOeffnung"];
	self.photoUrl = [NSURL URLWithString:dictionary[@"DisFotoUrl"]];

	NSNumberFormatter *nf = [NSNumberFormatter new];
	nf.numberStyle = NSNumberFormatterNoStyle;
	nf.decimalSeparator = @".";

	self.locLatitude = [[nf numberFromString:dictionary[@"DisLatitude"]] doubleValue];
	self.locLongitude = [[nf numberFromString:dictionary[@"DisLongitude"]] doubleValue];
}

-(UIImage*)photo {
	return [UIImage imageWithData:self.photoData];
}

@end

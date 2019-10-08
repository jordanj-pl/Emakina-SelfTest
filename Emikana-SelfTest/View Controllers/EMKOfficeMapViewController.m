//
//  EMKOfficeMapViewController.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 08/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficeMapViewController.h"

@import MapKit;
@import Contacts;

#import "AppDelegate.h"
#import "EMKCoreDataHelper.h"
#import "Office+CoreDataProperties.h"

@interface EMKOfficeMapViewController ()

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) Office *office;

@end

@implementation EMKOfficeMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	EMKCoreDataHelper *cdh = ((AppDelegate*)[UIApplication sharedApplication].delegate).coreDataHelper;
	self.office = (Office*)[cdh.context existingObjectWithID:self.officeID error:nil];

	[self setUpMapView];
}

-(void)setUpMapView {
	CLLocationCoordinate2D officeLoc = CLLocationCoordinate2DMake(self.office.locLatitude, self.office.locLongitude);

	CNMutablePostalAddress *officeAddress = [[CNMutablePostalAddress alloc] init];
	officeAddress.city = self.office.city;
	officeAddress.street = self.office.street;
	officeAddress.postalCode = [NSString stringWithFormat:@"%@", self.office.zip];
	officeAddress.ISOCountryCode = @"AT";//TODO it should be retrieved from API rather than hardcoded;

	MKPlacemark *officePlacemark = [[MKPlacemark alloc] initWithCoordinate:officeLoc postalAddress:officeAddress];

	[self.mapView addAnnotation:officePlacemark];

	self.mapView.centerCoordinate = officeLoc;
	self.mapView.showsScale = YES;
	self.mapView.mapType = MKMapTypeStandard;
	self.mapView.showsCompass = YES;
	self.mapView.zoomEnabled = YES;

	MKCoordinateRegion regionToDisplay = MKCoordinateRegionMakeWithDistance(officeLoc, 5000, 5000);
	self.mapView.region = regionToDisplay;
}

@end

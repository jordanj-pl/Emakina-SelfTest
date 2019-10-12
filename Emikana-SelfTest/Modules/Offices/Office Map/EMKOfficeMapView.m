//
//  EMKOfficeMapViewController.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 08/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficeMapView.h"

@import MapKit;

#import "AppDelegate.h"

@interface EMKOfficeMapView ()

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation EMKOfficeMapView

- (void)viewDidLoad {
    [super viewDidLoad];

	[self setUpMapView];

    [self.eventHandler showOfficeLocation];
}

-(void)setUpMapView {
	self.mapView.showsScale = YES;
	self.mapView.mapType = MKMapTypeStandard;
	self.mapView.showsCompass = YES;
	self.mapView.zoomEnabled = YES;
}

-(void)setOfficePlacemark:(MKPlacemark *)placemark {
	[self.mapView addAnnotation:placemark];

	self.mapView.centerCoordinate = placemark.coordinate;

	MKCoordinateRegion regionToDisplay = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 5000, 5000);
	self.mapView.region = regionToDisplay;
}

@end

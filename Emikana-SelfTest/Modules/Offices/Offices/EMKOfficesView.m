//
//  EMKOfficesTableViewController.m
//  Emikana-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficesView.h"

@import CoreData;

#import "AppDelegate.h"
#import "EMKMainRouter.h"

#import "EMKDatabaseManager.h"
#import "Office+CoreDataProperties.h"
#import "EMKOfficeTableViewCell.h"
#import "EMKOfficeDetailsTableViewController.h"

@interface EMKOfficesView ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *frc;

@end

@implementation EMKOfficesView

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.eventHandler showOffices];
}

-(void)setFetchedResultsController:(NSFetchedResultsController *)frc {
	NSLog(@"setFetchedResultsController");

	self.frc = frc;

	[self.frc.managedObjectContext performBlockAndWait:^{
		[self.tableView reloadData];
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.frc.sections[0].numberOfObjects;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMKOfficeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OfficeCell" forIndexPath:indexPath];
    
    Office *office = [self.frc objectAtIndexPath:indexPath];
    cell.nameLabel.text = office.name;
	cell.addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@", office.zip, office.city, office.street];
    
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[self.eventHandler didTapRowAtIndexPath:indexPath];
}

@end

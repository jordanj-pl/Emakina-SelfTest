//
//  OfficeDetailsTableViewController.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 07/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficeDetailsTableViewController.h"

#import "AppDelegate.h"
#import "EMKMainRouter.h"

#import "EMKDatabaseManager.h"
#import "Office+CoreDataProperties.h"

#import "EMKOfficeDetailsNameCell.h"
#import "EMKOfficeDetailsDetailsCell.h"

#import "EMKOfficeMapViewController.h"

@interface EMKOfficeDetailsTableViewController ()

@property (nonatomic, strong) Office *office;

@end

@implementation EMKOfficeDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self loadOfficeData];
}

-(void)loadOfficeData {
	EMKDatabaseManager *dbManager = ((AppDelegate*)[UIApplication sharedApplication].delegate).mainRouter.dbManager;
	self.office = (Office*)[dbManager officeByManagedObjectId:self.officeID];

	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	switch (indexPath.row) {
		case 0:
			return [self nameCellForTableView:tableView];
			break;

		case 1:
			return [self imageCellForTableView:tableView];
			break;

		case 2:
			return [self addressCellForTableView:tableView];
			break;

		case 3:
			return [self openingHoursCellForTableView:tableView];
			break;

		case 4:
			return [self phoneCellForTableView:tableView];
			break;

		case 5:
			return [self buttonCellForTableView:tableView];
			break;

		default:
			return [tableView dequeueReusableCellWithIdentifier:@"details" forIndexPath:indexPath];
			break;
	}
}

-(UITableViewCell*)nameCellForTableView:(UITableView*)tableView {
    EMKOfficeDetailsNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"name"];
    cell.nameLabel.text = self.office.name;

    return cell;
}

-(UITableViewCell*)imageCellForTableView:(UITableView*)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image"];

	if(self.office.photo) {
		cell.imageView.image = self.office.photo;
	}

    return cell;
}

-(UITableViewCell*)addressCellForTableView:(UITableView*)tableView {
    EMKOfficeDetailsDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"details"];
    cell.detailsLabel.text = [NSString stringWithFormat:@"Address:\n%@ %@, %@", self.office.zip, self.office.city, self.office.street];

    return cell;
}

-(UITableViewCell*)openingHoursCellForTableView:(UITableView*)tableView {
    EMKOfficeDetailsDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"details"];
    cell.detailsLabel.text = [NSString stringWithFormat:@"Opening Hours:\n%@", self.office.openingHours];

    return cell;
}

-(UITableViewCell*)phoneCellForTableView:(UITableView*)tableView {
    EMKOfficeDetailsDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"details"];
    cell.detailsLabel.text = [NSString stringWithFormat:@"Phone:\n%@", self.office.phone];

    return cell;
}

-(UITableViewCell*)buttonCellForTableView:(UITableView*)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"button"];

    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if(indexPath.row == 5) {

		EMKOfficeMapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"officeDetailsMap"];
		mapVC.officeID = self.office.objectID;

		[self.navigationController pushViewController:mapVC animated:YES];

	}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

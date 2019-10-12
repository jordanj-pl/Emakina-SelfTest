//
//  OfficeDetailsTableViewController.m
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 07/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficeDetailsView.h"

#import "EMKOfficeDetailsNameCell.h"
#import "EMKOfficeDetailsDetailsCell.h"

@interface EMKOfficeDetailsView ()

@property (nonatomic, copy) NSString *officeName;
@property (nonatomic, copy) UIImage *officePhoto;
@property (nonatomic, copy) NSString *officeAddress;
@property (nonatomic, copy) NSString *officeOpeningHours;
@property (nonatomic, copy) NSString *officePhone;

@end

@implementation EMKOfficeDetailsView

- (void)viewDidLoad {
    [super viewDidLoad];

	[self.eventHandler showOfficeDetails];
}

-(void)setOfficeName:(NSString *)officeName {
	_officeName = officeName;

	[self.tableView reloadData];
}

-(void)setOfficeAddress:(NSString *)officeAddress {
	_officeAddress = officeAddress;

	[self.tableView reloadData];
}

-(void)setOfficePhone:(NSString *)officePhone {
	_officePhone = officePhone;

	[self.tableView reloadData];
}

-(void)setOfficeOpeningHours:(NSString *)officeOpeningHours {
	_officeOpeningHours = officeOpeningHours;

	[self.tableView reloadData];
}

-(void)setOfficePhoto:(UIImage *)officePhoto {
	_officePhoto = officePhoto;

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
    cell.nameLabel.text = self.officeName;

    return cell;
}

-(UITableViewCell*)imageCellForTableView:(UITableView*)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image"];

	if(self.officePhoto) {
		cell.imageView.image = self.officePhoto;
	}

    return cell;
}

-(UITableViewCell*)addressCellForTableView:(UITableView*)tableView {
    EMKOfficeDetailsDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"details"];
    cell.detailsLabel.text = self.officeAddress;

    return cell;
}

-(UITableViewCell*)openingHoursCellForTableView:(UITableView*)tableView {
    EMKOfficeDetailsDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"details"];
    cell.detailsLabel.text = self.officeOpeningHours;

    return cell;
}

-(UITableViewCell*)phoneCellForTableView:(UITableView*)tableView {
    EMKOfficeDetailsDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"details"];
    cell.detailsLabel.text = self.officePhone;

    return cell;
}

-(UITableViewCell*)buttonCellForTableView:(UITableView*)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"button"];

    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if(indexPath.row == 5) {
		[self.eventHandler showOfficeMap];
	}
}

@end

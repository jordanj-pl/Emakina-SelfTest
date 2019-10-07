//
//  EMKOfficesTableViewController.m
//  Emikana-SelfTest
//
//  Created by Jordan Jasinski on 04/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#import "EMKOfficesTableViewController.h"

@import CoreData;

#import "AppDelegate.h"
#import "EMKCoreDataHelper.h"
#import "Office+CoreDataProperties.h"
#import "EMKOfficeTableViewCell.h"
#import "EMKOfficeDetailsTableViewController.h"

@interface EMKOfficesTableViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *frc;

@end

@implementation EMKOfficesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    EMKCoreDataHelper *cdh = ((AppDelegate*)[UIApplication sharedApplication].delegate).coreDataHelper;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Office"];
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES],nil];
    [request setFetchBatchSize:15];

    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:cdh.context
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.frc.delegate = self;

	[self.frc.managedObjectContext performBlockAndWait:^{
		NSError *error = nil;
		if(![self.frc performFetch:&error]) {
			NSLog(@"FAILED to perform fetch: %@", error);
		}

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

	Office *office = (Office*)[self.frc objectAtIndexPath:indexPath];

    EMKOfficeDetailsTableViewController *officeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"officeDetails"];
    officeVC.officeID = office.objectID;

    [self.navigationController pushViewController:officeVC animated:YES];
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

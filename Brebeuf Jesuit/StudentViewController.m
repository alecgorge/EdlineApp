//
//  StudentViewController.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/12/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "StudentViewController.h"
#import "SVPullToRefresh.h"
#import "ItemViewController.h"

@interface StudentViewController ()

@end

@implementation StudentViewController

- (id)initWithStudentName:(NSString *)name
				studentID:(NSString *)_studentId {
    self = [super initWithStyle: UITableViewStyleGrouped];
    if (self) {
        self.classes = [NSMutableArray array];
		self.title = name;
		
		studentId = _studentId;
		
		StudentViewController *this = self;
		[self addPullToRefreshWithActionHandler:^{
			[this reload];
		}];
		
		[self triggerPullToRefresh];
    }
    return self;
}

- (void)reload {
	[[EdlineAPIClient client] loadClassesForStudent:studentId
											success:^(NSArray * cls) {
												self.classes = cls;
												
												[self.tableView reloadData];
												
												[self stopAnimating];
											}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == 0 && [self.classes count] > 0) {
		return 2;
	}
	
    return [self.classes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:CellIdentifier];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if(indexPath.section == 0 && indexPath.row == 0) {
		cell.textLabel.text = @"Private Reports";
		return cell;
	}
	else if (indexPath.section == 0 && indexPath.row == 1) {
		cell.textLabel.text = @"Combined Calendar";
		return cell;
	}
	
	NSDictionary *dict = [self.classes objectAtIndex: indexPath.row];
	cell.textLabel.text = [dict objectForKey:@"name"];
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0 && indexPath.row == 0) {
		[self startAnimating];
		[[EdlineAPIClient client] privateReportsForStudent:studentId
		   success:^(EdlineItem *item) {
			   [self stopAnimating];
			   
			   ItemViewController *vc = [[ItemViewController alloc] initWithItem:item];
			   [self.navigationController pushViewController:vc
													animated:YES];
		   }];
		return;
	}
	else if (indexPath.section == 0 && indexPath.row == 1) {
		[self startAnimating];
		[[EdlineAPIClient client] combinedCalendarForStudent:studentId
													 success:^(EdlineItem *item) {
														 [self stopAnimating];
														 
														 ItemViewController *vc = [[ItemViewController alloc] initWithItem:item];
														 [self.navigationController pushViewController:vc
																							  animated:YES];
													 }];
		return;
	}
	
	NSDictionary *dict = [self.classes objectAtIndex: indexPath.row];
    ItemViewController *vc = [[ItemViewController alloc] initWithName:[dict objectForKey:@"name"]
																  url:[dict objectForKey:@"id"]];
	
	[self.navigationController pushViewController:vc
										 animated:YES];
}

@end

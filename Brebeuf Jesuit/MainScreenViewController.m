//
//  MainScreenViewController.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/12/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "MainScreenViewController.h"
#import "LoginViewController.h"
#import "StudentViewController.h"
#import "ItemViewController.h"
#import "SVPullToRefresh.h"
#import <SVWebViewController.h>

@interface MainScreenViewController ()

@end

@implementation MainScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Classes";
	
	MainScreenViewController *x = self;
	[self addPullToRefreshWithActionHandler:^{
		[x reload];
	}];
	
	[self triggerPullToRefresh];
	
	UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Log Out"
															   style:UIBarButtonItemStyleDone
															  target:self
															  action:@selector(logOutTapped:)];
	
	UIBarButtonItem *abouts = [[UIBarButtonItem alloc] initWithTitle:@"About"
															   style:UIBarButtonItemStyleBordered
															  target:self
															  action:@selector(about:)];
	
	self.navigationItem.rightBarButtonItem = logout;
	self.navigationItem.leftBarButtonItem = abouts;
}

-(void)about:(id)sender {
    SVModalWebViewController *m = [[SVModalWebViewController alloc] initWithAddress:@"http://alecgorge.com/edline/#about"];
	m.title = @"About the Edline App";
	
	[self presentModalViewController:m
							animated:YES];
}

- (void)reload {
	// show login screen if user is not logged in
	if(![EdlineUser currentUser].isLoggedIn) {
		[self logOutTapped:nil];
		
		return;
	}
	
	EdlineUser *user = [EdlineUser currentUser];
	[[EdlineAPIClient client] attemptLogIn:user.username
								  password:user.password
								   success:^{
									   if([EdlineUser currentUser].isParent) {
										   self.title = @"Students";
									   }
									   
									   [self.tableView reloadData];
									   
									   [self stopAnimating];
								   }
								   failure:^(NSError * err){
									   if(err.code == 54) {
										   [EdlineUser currentUser].isParent = NO;
										   [EdlineUser currentUser].studentsOrClasses = [NSMutableArray array];
																			   
										   [self.tableView reloadData];
										   
										   double delayInSeconds = 1.0;
										   dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
										   dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
											   [self stopAnimating];
											   [self logOutTapped:nil];
											   
											   UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error logging in"
																						   message:@"Your username or password is incorrect"
																						  delegate:nil
																				 cancelButtonTitle:@"OK"
																				 otherButtonTitles:nil];
											   [a show];
											   a = nil;
										   });
									   }
									   else {
										   [self stopAnimating];
										   
										   UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error"
																					   message:[err localizedDescription]
																					  delegate:nil
																			 cancelButtonTitle:@"OK"
																			 otherButtonTitles:nil];
										   [a show];
										   a = nil;										   
									   }
								   }];
}

- (IBAction)logOutTapped:(id)sender {
	[[EdlineUser currentUser] logOut];
	
	[EdlineUser currentUser].isParent = NO;
	[EdlineUser currentUser].studentsOrClasses = [NSMutableArray array];
	
	[self.tableView reloadData];

	[self performSegueWithIdentifier:@"showLoginForm" sender:self];
}

- (void)performSegueWithIdentifier:(NSString *)identifier
							sender:(id)sender {
	if([identifier isEqualToString:@"showLoginForm"]) {
		LoginViewController *vc = [[LoginViewController alloc] initWithMain: self];
		
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController: vc];
		
		nav.navigationBar.barStyle = UIBarStyleBlackOpaque;

		if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
			nav.navigationBar.translucent = NO;
		}

		if(IS_IPAD()) {
			nav.modalPresentationStyle = UIModalPresentationFormSheet;
		}
		else {
			nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		}
	
		[self presentModalViewController:nav
								animated:YES];
		
		return;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if([EdlineUser currentUser].studentsOrClasses == nil
    || [EdlineUser currentUser].studentsOrClasses.count == 0) {
		return 0;
	}
	
	if(![EdlineUser currentUser].isParent) {
		return 2;
	}
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == 0 && ![EdlineUser currentUser].isParent) {
		return 2;
	}
    // Return the number of rows in the section.
    return [[EdlineUser currentUser].studentsOrClasses count];
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
	
	if(indexPath.section == 0 && indexPath.row == 0  && ![EdlineUser currentUser].isParent) {
		cell.textLabel.text = @"Private Reports";
	}
	else if (indexPath.section == 0 && indexPath.row == 1 && ![EdlineUser currentUser].isParent) {
		cell.textLabel.text = @"Combined Calendar";
	}
	else {
		NSDictionary *dict = [[EdlineUser currentUser].studentsOrClasses objectAtIndex: indexPath.row];
		cell.textLabel.text = [dict objectForKey:@"name"];
	}
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0 && indexPath.row == 0  && ![EdlineUser currentUser].isParent) {
		[self startAnimating];
		[[EdlineAPIClient client] privateReportsForStudent:nil
												   success:^(EdlineItem *item) {
													   [self stopAnimating];
													   
													   ItemViewController *vc = [[ItemViewController alloc] initWithItem:item];
													   [self.navigationController pushViewController:vc
																							animated:YES];
												   }];
		return;
	}
	else if (indexPath.section == 0 && indexPath.row == 1 && ![EdlineUser currentUser].isParent) {
		[self startAnimating];
		[[EdlineAPIClient client] combinedCalendarForStudent:nil
													 success:^(EdlineItem *item) {
														 [self stopAnimating];
														 
														 ItemViewController *vc = [[ItemViewController alloc] initWithItem:item];
														 [self.navigationController pushViewController:vc
																							  animated:YES];
													 }];
		return;
	}

	NSDictionary *dict = [[EdlineUser currentUser].studentsOrClasses objectAtIndex: indexPath.row];
	BOOL isStudent = [[dict objectForKey:@"is_student"] boolValue];
	
	if(isStudent) {
		StudentViewController *vc = [[StudentViewController alloc] initWithStudentName:[dict objectForKey:@"name"]
																			 studentID:[dict objectForKey:@"student_id"]];
		
		[self.navigationController pushViewController:vc
											 animated:YES];
		
		return;
	}
	else {
		[self startAnimating];
		
		[[EdlineAPIClient client] loadItem:[dict objectForKey:@"id"]
									 title:[dict objectForKey:@"name"]
								   success:^(EdlineItem * item) {
									   UIViewController *vc;
									   if(item.isFile) {
										   
									   }
									   else if ([item.type isEqualToString:@"folder"]
										|| [item.type isEqualToString:@"calendar"]) {
										   vc = [[ItemViewController alloc] initWithItem:item];
									   }
									   else if([item.type isEqualToString:@"iframe"]) {
										   vc = [[SVWebViewController alloc] initWithAddress: item.content];
									   }
									   
									   [self.navigationController pushViewController:vc
																			animated:YES];
									   
									   [self stopAnimating];
								   }];
	}
}

@end

//
//  EdlineHomeViewController.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineHomeViewController.h"

#import "EdlineListDataSourceDelegate.h"
#import "EdlineListItemViewController.h"
#import "EdlineTabbedViewController.h"
#import "EdlineSettingsViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <Appirater.h>

@interface EdlineHomeViewController ()

@property (nonatomic) EdlineListDataSourceDelegate *eldsd;
@property BOOL cameFromSignIn;

@end

@implementation EdlineHomeViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Edline";
	
	[self setupViewControllers];
}

- (void)viewDidAppear:(BOOL)animated {
	[self attemptSignIn];
}

- (void)attemptSignIn {
	if([FXKeychain defaultKeychain][@"u"] == nil) {
		[self showSignIn];
		return;
	}
	
	[SVProgressHUD show];
	[[EdlineAPI2 sharedAPI] testLoginForUsername:[FXKeychain defaultKeychain][@"u"]
										password:[FXKeychain defaultKeychain][@"p"]
										 success:^(EdlineTabbedPage *homepage) {
											 if(homepage) {
												 [SVProgressHUD dismiss];
												 
												 [Appirater userDidSignificantEvent:YES];
												 
												 self.homepage = homepage;
												 [self setupViewControllers];
											 }
											 else {
												 double delayInSeconds = 0.3;
												 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
												 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
													 [SVProgressHUD dismiss];
													 
													 if(self.cameFromSignIn) {
														 [self showInvalidLoginAlert];
													 }
													 [self showSignIn];
												 });
											 }
										 }
										 failure:REQUEST_FAILED()];
}

- (void)showInvalidLoginAlert {
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Couldn't Sign In"
												message:@"Your username or password could be incorrect or you may not have signed up for an account yet. Visit edline.net in your web browser and make sure you can sign in there before you try signing in here."
											   delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
	
	[a show];
}

- (void)setupViewControllers {
	self.viewControllers = [self standardTabViewControllers];
	if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		for (UINavigationController *nav in self.viewControllers) {
			nav.navigationBar.translucent = NO;
		}
	}
	
}

- (NSArray *)standardTabViewControllers {
	EdlineTabbedViewController *school = [[EdlineTabbedViewController alloc] initWithTabPage:self.homepage];
	school.title = @"School";
	
	self.schoolTabController = [[UINavigationController alloc] initWithRootViewController:school];
	self.schoolTabController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"School"
																		image:[UIImage imageNamed:@"school.png"]
																		  tag:0];
	
	EdlineListItem *item = nil;
	
	
	
	if(self.homepage != nil) {
		item = [[EdlineListItem alloc] init];
		item.text = @"Students";
		item.url = @"javascript:submitEvent('viewAsPicker', 'TCNK=mobileHelper;mode=MyClasses');";
	}
	
	EdlineListItemViewController *students = [[EdlineListItemViewController alloc] initWithListItem:item];
	students.title = @"Students";
	self.studentsController = [[UINavigationController alloc] initWithRootViewController:students];
	self.studentsController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Students"
																	   image:[UIImage imageNamed:@"students.png"]
																		 tag:0];
	
	if(self.homepage != nil) {
		item = [[EdlineListItem alloc] init];
		item.text = @"Activity";
		item.url = @"javascript:submitEvent('viewAsPicker', 'TCNK=mobileHelper;mode=ActivityFeed');";
	}
	
	EdlineListItemViewController *activity = [[EdlineListItemViewController alloc] initWithListItem:item];
	activity.title = @"Activity Feed";
	self.activityController = [[UINavigationController alloc] initWithRootViewController:activity];
	self.activityController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Activity"
																	   image:[UIImage imageNamed:@"activity.png"]
																		 tag:0];
	
	
	if(self.homepage != nil) {
		item = [[EdlineListItem alloc] init];
		item.text = @"Reports";
		item.url = @"javascript:submitEvent('viewAsPicker', 'TCNK=mobileHelper;mode=PrivateReports');";
	}
	
	EdlineListItemViewController *private = [[EdlineListItemViewController alloc] initWithListItem:item];
	private.title = @"Private Reports";
	self.privateReportsController = [[UINavigationController alloc] initWithRootViewController:private];
	self.privateReportsController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Reports"
																			 image:[UIImage imageNamed:@"reports.png"]
																			   tag:0];
	
	
	if(self.homepage != nil) {
		item = [[EdlineListItem alloc] init];
		item.text = @"Calendar";
		item.url = @"javascript:submitEvent('viewAsPicker', 'TCNK=mobileHelper;mode=CombinedCalendar');";
	}
	
	EdlineListItemViewController *cal = [[EdlineListItemViewController alloc] initWithListItem:item];
	self.combinedCalendarController = [[UINavigationController alloc] initWithRootViewController:cal];
	self.combinedCalendarController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Calendar"
																			   image:[UIImage imageNamed:@"calendar.png"]
																				 tag:0];
	
	self.settingsController = [[UINavigationController alloc] initWithRootViewController:[[EdlineSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped]];
	self.settingsController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
																	   image:[UIImage imageNamed:@"settings.png"]
																		 tag:0];
	
	return @[
			 self.activityController,
			 self.studentsController,
			 self.privateReportsController,
//			 self.combinedCalendarController,
			 self.schoolTabController,
			 self.settingsController
			 ];
	
}

- (void)showSignIn {
	EdlineLoginViewController *login = [[EdlineLoginViewController alloc] initWithDelegate:self];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
	
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
}

- (void)didSignIn {
	self.cameFromSignIn = YES;
	[self attemptSignIn];
}

@end

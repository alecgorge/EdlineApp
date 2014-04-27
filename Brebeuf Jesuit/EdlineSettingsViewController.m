//
//  EdlineSettingsViewController.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/25/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineSettingsViewController.h"

#import <FXKeychain/FXKeychain.h>
#import <SVWebViewController/SVWebViewController.h>
#import <SVWebViewController/SVModalWebViewController.h>

#import "AppDelegate.h"

@interface EdlineSettingsViewController ()

@property (nonatomic) UISwitch *activityFeedNotifications;
@property (nonatomic) UISwitch *privateReportsNotifications;

@end

@implementation EdlineSettingsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Settings";
	
	self.activityFeedNotifications = [[UISwitch alloc] init];
	self.activityFeedNotifications.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"activityNotifications"] boolValue];
	[self.activityFeedNotifications addTarget:self
									   action:@selector(changeActivityFeedNotifications:)
							 forControlEvents:UIControlEventValueChanged];
	
	self.privateReportsNotifications = [[UISwitch alloc] init];
	self.privateReportsNotifications.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"privateReportsNotifications"] boolValue];
	[self.privateReportsNotifications addTarget:self
										 action:@selector(changePrivateReportsNotifications:)
							   forControlEvents:UIControlEventValueChanged];
}

- (void)changeActivityFeedNotifications:(UISwitch*)sw {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:sw.on]
											  forKey:@"activityNotifications"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)changePrivateReportsNotifications:(UISwitch*)sw {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:sw.on]
											  forKey:@"privateReportsNotifications"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(ENABLE_NOTIFICATIONS && section == 0 && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		return 2;
	}
	else if(section == 1) {
		return 3;
	}
	else if(section == 2) {
		return 1;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
										  reuseIdentifier:@"Cell"];
			
			cell.textLabel.text = @"Activity Feed";
			cell.accessoryView = self.activityFeedNotifications;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else if(indexPath.row == 1) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
										  reuseIdentifier:@"Cell"];
			
			cell.textLabel.text = @"Private Reports";
			cell.accessoryView = self.privateReportsNotifications;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
	else if(indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
										  reuseIdentifier:@"TextCell"];
			
			cell.textLabel.text = @"App by @alecgorge";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if (indexPath.row == 1) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
										  reuseIdentifier:@"TextCell"];
			
			cell.textLabel.text = @"About";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if (indexPath.row == 2) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
										  reuseIdentifier:@"TextCell"];
			
			cell.textLabel.text = @"Contact";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else if(indexPath.section == 2) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									  reuseIdentifier:@"TextCell"];
		
		if([FXKeychain defaultKeychain][@"u"])
			cell.textLabel.text = [@"Sign out of " stringByAppendingString:[FXKeychain defaultKeychain][@"u"]];
		else
			cell.textLabel.text = @"Sign out";
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1) {
		if (indexPath.row == 0) {
			NSURL *urlApp = [NSURL URLWithString: @"twitter:///user?screen_name=alecgorge"];
			
			if ([[UIApplication sharedApplication] canOpenURL:urlApp]){
				[[UIApplication sharedApplication] openURL:urlApp];
			}
			else {
				NSURL *url = [NSURL URLWithString:@"https://twitter.com/alecgorge"];
				SVWebViewController *vc = [[SVWebViewController alloc] initWithURL:url];
				
				[self.navigationController pushViewController:vc
													 animated:YES];
			}
		}
		else if (indexPath.row == 1) {
			NSURL *url = [NSURL URLWithString:@"http://alecgorge.com/edline/#about"];
			SVWebViewController *vc = [[SVWebViewController alloc] initWithURL:url];
			
			[self.navigationController pushViewController:vc
												 animated:YES];
		}
		else if (indexPath.row == 2) {
			NSURL *url = [NSURL URLWithString:@"mailto:alecgorge+edlineapp@gmail.com?subject=Edline&20App"];
			[[UIApplication sharedApplication] openURL:url];
		}
	}
	else if(indexPath.section == 2) {
		[FXKeychain defaultKeychain][@"u"] = nil;
		[FXKeychain defaultKeychain][@"p"] = nil;
		
		[[AppDelegate sharedDelegate].home showSignIn];
	}
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(ENABLE_NOTIFICATIONS && section == 0 && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		return @"Push Notifications";
	}
	else if(section == 1) {
		return nil;
	}
	
	return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if(section == 2) {
		return @"This app is not endorsed or supported by Edline or Blackboard in any way. It was created and is maintained by Alec Gorge.";
	}
	
	return nil;
}

@end

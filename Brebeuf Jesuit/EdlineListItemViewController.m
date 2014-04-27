//
//  EdlineListItemViewController.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineListItemViewController.h"
#import "EdlineListDataSourceDelegate.h"
#import "EdlineTabbedViewController.h"

@interface EdlineListItemViewController ()

@property (nonatomic) EdlineListDataSourceDelegate *eldsd;

@end

@implementation EdlineListItemViewController

- (instancetype)initWithListItem:(EdlineListItem *)item {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.item = item;
	}
	return self;
}

- (void)viewDidLoad {
	self.eldsd = [[EdlineListDataSourceDelegate alloc] initWithNavigationController:self.navigationController];

	if(self.item != nil) {
		[super viewDidLoad];
	}
	else {
		self.tableView.delegate = self.eldsd;
		self.tableView.dataSource = self.eldsd;
		
		[self.tableView reloadData];
	}
}

- (void)refresh:(id)sender {
	[[EdlineAPI2 sharedAPI] loadListItem:self.item
								 success:^(id displayable) {
									 [super refresh:sender];

									 if([displayable isKindOfClass:[EdlineList class]]
									 || displayable == nil) {
										 self.eldsd.list = displayable;
										 self.eldsd.list.previousItem = self.item;
										 
										 if(self.eldsd.list.title != nil && self.eldsd.list.title.length > 0)
											 self.title = self.eldsd.list.title;
										 
										 self.tableView.delegate = self.eldsd;
										 self.tableView.dataSource = self.eldsd;
										 
										 [self.tableView reloadData];
									 }
									 else if([displayable isKindOfClass:[EdlineTabbedPage class]]) {
										 EdlineTabbedViewController *vc = [[EdlineTabbedViewController alloc] initWithTabPage:displayable];
										 
										 [self.navigationController pushViewController:vc
																			  animated:YES];
									 }
									 
									 [Flurry logError:@"ListItemViewController"
											  message:[NSString stringWithFormat:@"Couldn't display: %@", displayable]
												error:[NSError errorWithDomain:@"com.alecgorge.ios.edline"
																		  code:6548
																	  userInfo:@{@"displayable": displayable?displayable:@"nil"}]];
								 }
								 failure:REQUEST_FAILED()];
}

@end

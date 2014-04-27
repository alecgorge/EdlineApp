//
//  EdlineListViewController.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineListViewController.h"

#import "EdlineListDataSourceDelegate.h"

@interface EdlineListViewController ()

@property (nonatomic) EdlineListDataSourceDelegate *eldsd;

@end

@implementation EdlineListViewController

- (instancetype)initWithList:(EdlineList *)item {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.eldsd = [[EdlineListDataSourceDelegate alloc] initWithNavigationController:self.navigationController];
		
		self.title = item.title;
		
		self.eldsd.list = item;
	}
	
	return self;
}

- (void)viewDidLoad {
	self.eldsd.controller = self.navigationController;
	
	self.tableView.delegate = self.eldsd;
	self.tableView.dataSource = self.eldsd;
	[self.tableView reloadData];
}

@end

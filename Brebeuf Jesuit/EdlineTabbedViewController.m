//
//  EdlineTabbedViewController.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineTabbedViewController.h"

#import "EdlineListItemViewController.h"

typedef enum {
	kEdlineTabNewsRow,
	kEdlineTabEventsRow,
	kEdlineTabContentsRow,
	kEdlineTabRowCount
} kEdlineTabbedRows;

@implementation EdlineTabbedViewController

- (instancetype)initWithTabPage:(EdlineTabbedPage *)page {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.page = page;
		self.title = page.title;
		
		[self.tableView registerClass:[UITableViewCell class]
			   forCellReuseIdentifier:@"Cell"];
	}
	
	return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
															forIndexPath:indexPath];
	
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	int row = indexPath.row;
	if(row == kEdlineTabNewsRow) {
		cell.textLabel.text = @"News";
	}
	else if(row == kEdlineTabEventsRow) {
		cell.textLabel.text = @"Events";
	}
	else if(row == kEdlineTabContentsRow) {
		cell.textLabel.text = @"Contents";
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	int row = indexPath.row;
	if(row == kEdlineTabNewsRow) {
		EdlineListItemViewController *news = [[EdlineListItemViewController alloc] initWithListItem:self.page.newsItem];
		news.title = @"News";
		[self.navigationController pushViewController:news
											 animated:YES];
	}
	else if(row == kEdlineTabEventsRow) {
		EdlineListItemViewController *events = [[EdlineListItemViewController alloc] initWithListItem:self.page.eventsItem];
		events.title = @"Events";
		[self.navigationController pushViewController:events
											 animated:YES];
	}
	else if(row == kEdlineTabContentsRow) {
		EdlineListItemViewController *contents = [[EdlineListItemViewController alloc] initWithListItem:self.page.contentsItem];
		contents.title = @"Contents";
		[self.navigationController pushViewController:contents
											 animated:YES];
	}
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return kEdlineTabRowCount;
}

@end

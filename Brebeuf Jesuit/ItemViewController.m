//
//  ClassViewController.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/13/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "ItemViewController.h"
#import "SVPullToRefresh.h"
#import <SVWebViewController.h>
#import "EdlineFilePreviewDataSource.h"

@interface ItemViewController ()

@end

@implementation ItemViewController

- (id)initWithName:(NSString*)name url:(NSString *)class {
    self = [super initWithStyle: UITableViewStyleGrouped];
    if (self) {
		self.title = name;
				
		url = class;
		qlDataSources = [NSMutableArray array];
		
		ItemViewController *this = self;
		[self addPullToRefreshWithActionHandler:^{
			[this reload];
		}];
		
		[self triggerPullToRefresh];
    }
    return self;
}

- (id)initWithItem:(EdlineItem *)__item {
	self = [super initWithStyle: UITableViewStyleGrouped];
	if(self) {
		self.item = __item;
		self.title = self.item.name;
		qlDataSources = [NSMutableArray array];
		
		// needed for show the loaded even if we don't use it
		ItemViewController *v = self;
		[self addPullToRefreshWithActionHandler:^{
			[v reload];
		}];
	}
	
	return self;
}

- (void)reload {
	NSString *reloadURL;
	if(self.item == nil) {
		reloadURL = url;
	}
	else {
		if([self.item.url isEqualToString:@"private_reports"]) {
			[self stopAnimating];
			return;
		}
		else {
			reloadURL = self.item.url;
		}
	}
	[[EdlineAPIClient client] loadItem:reloadURL
								 title:self.title
							   success:^(EdlineItem *item) {
								   self.item = item;
								   
								   [self.tableView reloadData];
								   [self stopAnimating];
							   }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.item.isSectioned ? [self.item.sectionedInformation count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(self.item == nil) {
		return 0;
	}
	
	if(self.item.isSectioned) {
		return [[[self.item.sectionedInformation objectAtIndex: section] objectForKey:@"cells"] count];
	}
	
	return MAX(self.item.contents.count, 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView
	 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	if ([self.item.type isEqualToString:@"calendar"]) {
		CellIdentifier = @"CalendarCell";
	}
	else if([self.item.type isEqualToString:@"sectioned"]) {
		CellIdentifier = @"SectionedCell";
	}
	else {
		CellIdentifier = @"Cell";
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
		if ([self.item.type isEqualToString:@"calendar"]) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										  reuseIdentifier:CellIdentifier];
		}
		else if(self.item.isSectioned) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										  reuseIdentifier:CellIdentifier];
		}
		else {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:CellIdentifier];
		}
	}
	
	if(self.item.isSectioned) {
		NSArray *section = [[self.item.sectionedInformation objectAtIndex:indexPath.section] objectForKey:@"cells"];
		NSDictionary *dict = [section objectAtIndex:indexPath.row];
		cell.textLabel.text = [dict objectForKey:@"key"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		
		if([[dict objectForKey:@"url"] length] == 0) {
			cell.userInteractionEnabled = NO;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		cell.detailTextLabel.text = [dict objectForKey:@"value"];
		return cell;
	}
	
	if(self.item.contents.count == 0) {
		cell.textLabel.text = @"Empty Folder!";
		cell.userInteractionEnabled = NO;
		return cell;
	}
	
	NSDictionary *dict;
	dict = [self.item.contents objectAtIndex: indexPath.row];
	cell.textLabel.text = [dict objectForKey:@"name"];
	cell.textLabel.numberOfLines = 0;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if([[dict objectForKey:@"id"] length] == 0) {
		cell.userInteractionEnabled = NO;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	if ([self.item.type isEqualToString:@"calendar"]) {
		cell.detailTextLabel.text = [dict objectForKey:@"date"];
	}
	
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.item.isSectioned) {
		return self.tableView.rowHeight * 1.15;
	}
	if(self.item.contents.count == 0) {
		return self.tableView.rowHeight;
	}
	
	CGFloat width = 200.0;
	
	if(IS_IPAD()) {
		width = 600.0;
	}
	
    CGSize labelSize = CGSizeMake(width, self.tableView.rowHeight / 2.0);
	
    NSString *strTemp = [[self.item.contents objectAtIndex: indexPath.row] objectForKey:@"name"];
	
    if ([strTemp length] > 0)
        labelSize = [strTemp sizeWithFont: [UIFont boldSystemFontOfSize: 14.0]
						constrainedToSize: CGSizeMake(labelSize.width, 1000)
							lineBreakMode: NSLineBreakByWordWrapping];
	
    return MAX((labelSize.height + 17.0), self.tableView.rowHeight);
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(self.item.isSectioned) {
		return [[self.item.sectionedInformation objectAtIndex:section] objectForKey:@"header"];
	}
	return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self startAnimating];
	
	NSString *id;
	NSString *name;
	if(self.item.isSectioned) {
		NSDictionary *dict = [[[self.item.sectionedInformation objectAtIndex:indexPath.section] objectForKey:@"cells"] objectAtIndex:indexPath.row];
		id = [dict objectForKey:@"url"];
		name = [dict objectForKey:@"key"];
	}
	else {
		id = [[self.item.contents objectAtIndex: indexPath.row] objectForKey: @"id"];
		name = [[self.item.contents objectAtIndex: indexPath.row] objectForKey: @"name"];
	}
	[[EdlineAPIClient client] loadItem:id
								 title:name
							   success:^(EdlineItem * item) {
								   UIViewController *vc;
								   if(item.isFile) {
									   NSURL *furl = [NSURL fileURLWithPath: item.url];
									   EdlineFilePreviewDataSource *ds = [[EdlineFilePreviewDataSource alloc] initWithURL:furl];
									   
									   [qlDataSources addObject: ds];
									   
									   QLPreviewController *prev = [[QLPreviewController alloc] init];
									   prev.dataSource = ds;
									   
									   vc = prev;
								   }
								   else if ([item.type isEqualToString:@"folder"]
											|| [item.type isEqualToString:@"calendar"]
											|| item.isSectioned) {
									   vc = [[ItemViewController alloc] initWithItem:item];
								   }
								   else if([item.type isEqualToString:@"iframe"]) {
									   vc = [[SVWebViewController alloc] initWithAddress: item.content];
									   vc.navigationItem.title = item.name;
								   }
								   
								   [self.navigationController pushViewController:vc
																		animated:YES];
								   
								   [self stopAnimating];
							   }];	
}

@end

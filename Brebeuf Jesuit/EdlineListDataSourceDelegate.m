//
//  EdlineListDataSourceDelegate.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineListDataSourceDelegate.h"

#import "EdlineListViewController.h"
#import "EdlineDocListItem.h"
#import "EdlineActivityListItem.h"
#import "EdlineTabbedViewController.h"
#import "EdlineFile.h"
#import "EdlineIframe.h"
#import "EdlineEventListItem.h"

#import <SVWebViewController/SVWebViewController.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <TDBadgedCell/TDBadgedCell.h>

@interface EdlineListDataSourceDelegate ()

@property EdlineFile *selectedFile;

@end

@implementation EdlineListDataSourceDelegate

- (instancetype)initWithNavigationController:(UINavigationController *)con {
    self = [super init];
    if (self) {
        self.controller = con;
		self.pushModal = NO;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return self.list == nil ? 1 : self.list.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.list == nil) {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
													   reuseIdentifier:@"Cell"];
		
		
		cell.textLabel.text = @"This folder is empty";
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		return cell;
	}

	EdlineListItem *item = self.list.items[indexPath.row];
	
	if([item isKindOfClass:[EdlineDocListItem class]]) {
		EdlineDocListItem *i = (EdlineDocListItem*)item;
		
		TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BadgedCell"];
		
		if(!cell) {
			cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:@"BadgedCell"];
		}
		
		cell.textLabel.text = i.text;
		cell.detailTextLabel.text = i.className;
		cell.badgeString = i.date;
		cell.badgeColor = EDLINE_GREEN;
		
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
	else if([item isKindOfClass:[EdlineActivityListItem class]]) {
		EdlineActivityListItem *i = (EdlineActivityListItem*)item;
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Activity"];
		
		if(!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										  reuseIdentifier:@"Activity"];
		}
		
		cell.textLabel.text = i.text;
		cell.detailTextLabel.text = [i.className stringByAppendingString:i.updatedAt];
		
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
	else if([item isKindOfClass:[EdlineEventListItem class]]) {
		EdlineEventListItem *i = (EdlineEventListItem*)item;
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Event"];
		
		if(!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										  reuseIdentifier:@"Event"];
		}
		
		cell.textLabel.text = i.text;
		cell.textLabel.numberOfLines = 2;
		cell.detailTextLabel.text = i.date;
		
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
	else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
		
		if(!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:@"Cell"];
		}
		
		cell.textLabel.text = item.text;
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	EdlineListItem *item = self.list.items[indexPath.row];
	
	if([item isKindOfClass:[EdlineDocListItem class]]
    || [item isKindOfClass:[EdlineActivityListItem class]]
	|| [item isKindOfClass:[EdlineEventListItem class]]) {
		return tableView.rowHeight * 1.4;
	}
	
	return UITableViewAutomaticDimension;
}

- (void)display:(UIViewController*)vc {
	if(self.pushModal) {
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
		[self.controller presentViewController:nav
									  animated:YES
									completion:nil];
	}
	else {
		[self.controller pushViewController:vc
								   animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(self.list == nil) return;
	
	[SVProgressHUD show];
	[[EdlineAPI2 sharedAPI] loadListItem:self.list.items[indexPath.row]
								 success:^(id displayable) {
									 [SVProgressHUD dismiss];
									 
									 if(displayable != nil) {
										 if([displayable isKindOfClass:[EdlineList class]]) {
											 EdlineListViewController *vc = [[EdlineListViewController alloc] initWithList:displayable];
											 vc.title = [self.list.items[indexPath.row] text];
											 [self display:vc];
										 }
										 else if([displayable isKindOfClass:[EdlineTabbedPage class]]) {
											 EdlineTabbedViewController *vc = [[EdlineTabbedViewController alloc] initWithTabPage:displayable];
											 [self display:vc];
										 }
										 else if([displayable isKindOfClass:[EdlineFile class]]) {
											 self.selectedFile = displayable;
											 
											 QLPreviewController *preview = [[QLPreviewController alloc] init];
											 preview.dataSource = self;
											 
											 [self display:preview];
										 }
										 else if([displayable isKindOfClass:[EdlineIframe class]]) {
											 SVWebViewController *vc = [[SVWebViewController alloc] initWithURL:[displayable url]];
											 vc.navigationItem.title = [self.list.items[indexPath.row] text];
											 [self display:vc];
										 }
									 }
									 else {
										 alert(@"Whoops!", @"Unfortunately this item couldn't be opened. This item may be empty or is not understood by the app.");
									 }
								 }
								 failure:REQUEST_FAILED()];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
	return self.selectedFile != nil ? 1 : 0;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller
					previewItemAtIndex:(NSInteger)index {
	return self.selectedFile.url;
}

@end

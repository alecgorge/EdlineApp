//
//  ClassViewController.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/13/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface ItemViewController : UITableViewController {
	NSString *url;
	NSMutableArray *qlDataSources;
}

@property (nonatomic) EdlineItem *item;

- (id)initWithName:(NSString*)name url:(NSString *)class;
- (id)initWithItem:(EdlineItem*)_item;

@end

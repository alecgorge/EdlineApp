//
//  EdlineTabbedViewController.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EdlineTabbedViewController : UITableViewController

- (instancetype)initWithTabPage:(EdlineTabbedPage*)page;

@property (nonatomic) EdlineTabbedPage *page;

@end

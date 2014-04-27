//
//  RefreshableViewController.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "RefreshableViewController.h"

@implementation RefreshableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self
					   action:@selector(refresh:)
			 forControlEvents:UIControlEventValueChanged];
	
	self.refreshControl = refreshControl;
	[self beginRefreshingTableView];
	
	[self refresh: self.refreshControl];
}

- (void)refresh:(id)sender {
	[sender endRefreshing];
}

- (void)beginRefreshingTableView {
    [self.refreshControl beginRefreshing];
	
    if (self.tableView.contentOffset.y == 0) {
        [UIView animateWithDuration:0.25
							  delay:0
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^(void){
            self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        }
						 completion:^(BOOL finished){}];
		
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

@end

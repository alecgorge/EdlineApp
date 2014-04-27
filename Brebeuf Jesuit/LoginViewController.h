//
//  LoginViewController.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/12/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScreenViewController.h"
#import "SVPullToRefresh.h"

@interface LoginViewController : UITableViewController<UITextFieldDelegate> {
	MainScreenViewController *toRefresh;
}

- (id)initWithMain:(MainScreenViewController*)main;

@end

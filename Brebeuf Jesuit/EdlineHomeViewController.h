//
//  EdlineHomeViewController.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineTabbedViewController.h"

#import <FXKeychain/FXKeychain.h>
#import "EdlineLoginViewController.h"

@interface EdlineHomeViewController : UITabBarController<EdlineLoginDelegate>

@property (nonatomic) EdlineTabbedPage *homepage;

@property (nonatomic) UINavigationController *activityController;
@property (nonatomic) UINavigationController *studentsController;
@property (nonatomic) UINavigationController *privateReportsController;
@property (nonatomic) UINavigationController *combinedCalendarController;
@property (nonatomic) UINavigationController *schoolTabController;
@property (nonatomic) UINavigationController *settingsController;

-(void)showSignIn;

@end

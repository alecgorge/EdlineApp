//
//  AppDelegate.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/10/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EdlineHomeViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (AppDelegate*)sharedDelegate;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) EdlineHomeViewController *home;
@property (nonatomic) BOOL notificationsEnabled;

@end

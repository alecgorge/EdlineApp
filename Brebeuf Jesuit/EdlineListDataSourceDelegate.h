//
//  EdlineListDataSourceDelegate.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface EdlineListDataSourceDelegate : NSObject<UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDataSource>

- (instancetype)initWithNavigationController:(UINavigationController*)con;

@property (nonatomic) EdlineList *list;
@property (nonatomic, weak) UINavigationController *controller;

@property (nonatomic) BOOL pushModal;

@end

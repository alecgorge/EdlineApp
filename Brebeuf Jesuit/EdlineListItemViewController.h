//
//  EdlineListItemViewController.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "RefreshableViewController.h"

@interface EdlineListItemViewController : RefreshableViewController

- (instancetype)initWithListItem:(EdlineListItem*)item;

@property (nonatomic) EdlineListItem *item;

@end

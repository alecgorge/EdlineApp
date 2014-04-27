//
//  EdlineTabbedPage.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EdlineAPI2.h"
#import "EdlineModel.h"
#import "EdlineList.h"
#import "EdlineListItem.h"

typedef void (^FailureBlock)(AFHTTPRequestOperation *, NSError *);

@interface EdlineTabbedPage : EdlineModel

@property (nonatomic) NSString *title;

@property (nonatomic, readonly) BOOL hasNews;
@property (nonatomic, readonly) BOOL hasEvents;
@property (nonatomic, readonly) BOOL hasContents;

@property (nonatomic) EdlineListItem *newsItem;
@property (nonatomic) EdlineListItem *eventsItem;
@property (nonatomic) EdlineListItem *contentsItem;

@end

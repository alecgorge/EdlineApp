//
//  EdlineList.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineModel.h"
#import "EdlineListItem.h"

@interface EdlineList : EdlineModel<NSCoding>

@property (nonatomic) NSString *eventPath;
@property (nonatomic) NSString *title;
@property (nonatomic) NSArray *items;

- (EdlineListItem *)itemForHTMLNode:(HTMLNode*)node;

@property (readonly, nonatomic) NSString *listXPathKey;
@property (readonly, nonatomic) NSString *titleXPathKey;

@property (nonatomic) EdlineListItem *previousItem;

@end

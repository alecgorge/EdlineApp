//
//  EdlineActivityList.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineActivityList.h"
#import "EdlineActivityListItem.h"

@implementation EdlineActivityList

- (NSString *)listXPathKey {
	return @"ActivityItems";
}

- (NSString *)title {
	return @"Activity Feed";
}

- (EdlineListItem *)itemForHTMLNode:(HTMLNode *)node {
	EdlineActivityListItem *item = [[EdlineActivityListItem alloc] initWithHTMLNode:node];
	item.eventPath = self.eventPath;
	item.eventOperation = self.operation;
	item.previousItem = self.previousItem;
	
	return item;
}

@end

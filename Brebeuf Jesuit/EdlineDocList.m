//
//  EdlineDocList.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineDocList.h"
#import "EdlineDocListItem.h"

@implementation EdlineDocList

- (NSString *)listXPathKey {
	return @"ListDocItems";
}

- (NSString *)titleXPathKey {
	return @"ListDocTitle";
}

- (EdlineListItem *)itemForHTMLNode:(HTMLNode *)node {
	EdlineDocListItem *item = [[EdlineDocListItem alloc] initWithHTMLNode:node];
	item.eventPath = self.eventPath;
	item.eventOperation = self.operation;
	item.previousItem = self.previousItem;
	
	return item;
}

@end

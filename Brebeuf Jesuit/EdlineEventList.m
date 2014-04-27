//
//  EdlineEventList.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineEventList.h"
#import "EdlineEventListItem.h"

@implementation EdlineEventList

- (NSString *)title {
	return @"Calendar";
}

- (NSString *)listXPathKey {
	return @"CalItems";
}

- (NSArray *)items {
	if(!_items) {
		NSArray *nodes = [self.document.rootNode nodesForXPath:[EdlineXPath xPathForKey:self.listXPathKey]];
		
		NSMutableArray *cal = [NSMutableArray array];
		NSString *date = nil;
		
		for (HTMLNode *node in nodes) {
			if ([node attributeForName:@"data-role"]) {
				date = [node nodeForXPath:@"/span"].textContent;
			}
			else {
				EdlineEventListItem *item = [[EdlineEventListItem alloc] initWithHTMLNode:node
																				  andDate:date];
				item.eventPath = self.eventPath;
				item.eventOperation = self.operation;
				item.previousItem = self.previousItem;
				
				[cal insertObject:item
						  atIndex:0];
			}
		}
		
		_items = cal;
	}
	
	return _items;
}

@end

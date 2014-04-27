//
//  EdlineList.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineList.h"

@implementation EdlineList

- (NSString *)title {
	if(!_title) {
		HTMLNode *node = [self.document.rootNode nodeForXPath:[EdlineXPath xPathForKey:self.titleXPathKey]];
		_title = node.textContent;
	}
	
	return _title;
}

- (EdlineListItem *)itemForHTMLNode:(HTMLNode*)node {
	EdlineListItem *item = [[EdlineListItem alloc] initWithHTMLNode:node];
	item.eventPath = self.eventPath;
	item.eventOperation = self.operation;
	item.previousItem = self.previousItem;
	
	return item;
}

- (NSString *)titleXPathKey {
	return @"ListTitle";
}

- (NSString *)listXPathKey {
	return @"ListItems";
}

- (NSArray *)items {
	if(!_items) {
		NSArray *nodes = [self.document.rootNode nodesForXPath:[EdlineXPath xPathForKey:self.listXPathKey]];
		_items = [nodes map:^id(id object) {
			return [self itemForHTMLNode:object];
		}];
	}
	
	return _items;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(!self) return nil;
	
	self.title = [aDecoder decodeObjectForKey:@"title"];
	self.items = [aDecoder decodeObjectForKey:@"items"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.title
				  forKey:@"title"];

	[aCoder encodeObject:self.items
				  forKey:@"items"];
}

@end

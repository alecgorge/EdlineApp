//
//  EdlineActivityListItem.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineActivityListItem.h"

@implementation EdlineActivityListItem

- (instancetype)initWithHTMLNode:(HTMLNode *)htmlNode {
	if (self = [super init]) {
		HTMLNode *link = [htmlNode nodeForXPath:@"/h3/a"];
		self.text = link.textContent;
		self.url = [link attributeForName:@"href"];
		
		HTMLNode *desc = [htmlNode nodeForXPath:@"/p[2]"];
		self.className = [desc nodeForXPath:@"/a"].textContent;
		self.updatedAt = [@" " stringByAppendingString:desc.textContent];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if(!self) return nil;
	
	self.className = [aDecoder decodeObjectForKey:@"className"];
	self.updatedAt = [aDecoder decodeObjectForKey:@"updatedAt"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:self.className
				  forKey:@"className"];
	
	[aCoder encodeObject:self.updatedAt
				  forKey:@"updatedAt"];
}

@end

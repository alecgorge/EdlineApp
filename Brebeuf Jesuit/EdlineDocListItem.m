//
//  EdlineDocListItem.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineDocListItem.h"

@implementation EdlineDocListItem

- (instancetype)initWithHTMLNode:(HTMLNode *)htmlNode {
	if (self = [super init]) {
		self.text = [htmlNode attributeForName:@"title"];
		
		if (self.text == nil) {
			self.text = [htmlNode nodeForXPath:@"/h3"].textContent;
		}
		
		self.className = [htmlNode nodeForXPath:@"/p"].textContent;
		self.date = [htmlNode nodeForXPath:@"/span"].textContent;
		
		self.url = [htmlNode attributeForName:@"href"];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if(!self) return nil;
	
	self.className = [aDecoder decodeObjectForKey:@"className"];
	self.date = [aDecoder decodeObjectForKey:@"date"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:self.className
				  forKey:@"className"];
	
	[aCoder encodeObject:self.date
				  forKey:@"date"];
}

@end

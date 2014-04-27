//
//  EdlineListItem.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineListItem.h"

@implementation EdlineListItem

- (instancetype)initWithHTMLNode:(HTMLNode *)htmlNode {
	if (self = [super init]) {
		self.text = [htmlNode attributeForName:@"title"];
		
		if (self.text == nil) {
			self.text = [htmlNode textContent];
		}
		
		self.url = [htmlNode attributeForName:@"href"];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	
	if(!self) return nil;
	
	self.text = [aDecoder decodeObjectForKey:@"text"];
	self.url  = [aDecoder decodeObjectForKey:@"url"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.text
				  forKey:@"text"];
	
	[aCoder encodeObject:self.url
				  forKey:@"url"];
}

- (BOOL)isEqual:(id)object {
	return [self.url isEqual:[object url]];
}

@end

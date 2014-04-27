//
//  EdlineEventListItem.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineEventListItem.h"

@implementation EdlineEventListItem

- (instancetype)initWithHTMLNode:(HTMLNode *)htmlNode andDate:(NSString*)date {
	if (self = [super init]) {
		self.text = [htmlNode nodeForXPath:@"/a/h3"].textContent;
		self.date = date;
		self.url = [[htmlNode nodeForXPath:@"/a"] attributeForName:@"href"];
	}
	
	return self;
}

@end

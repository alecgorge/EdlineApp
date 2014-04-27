//
//  EdlineIframe.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineIframe.h"

@implementation EdlineIframe

- (instancetype)initWithRequestOperation:(AFHTTPRequestOperation *)operation
					   andResponseObject:(NSData *)data {
	if (self = [super initWithRequestOperation:operation
							 andResponseObject:data]) {
		HTMLNode *node = [self.document.rootNode nodeForXPath:[EdlineXPath xPathForKey:@"IFrameItem"]];
		self.url = [NSURL URLWithString:[@"https://www.edline.net" stringByAppendingString:[node attributeForName:@"src"]]];
	}
	return self;
}

@end

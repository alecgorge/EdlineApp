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
        
        NSString *iframeDocInfo = @"//*[@class=\"be-docContents cf\"]/*[starts-with(@class,\"be-docInfo\")]";
        
        NSArray *metaInfo = [self.document.rootNode nodesForXPath:iframeDocInfo];
        
        NSMutableDictionary *d = NSMutableDictionary.dictionary;
        for (HTMLNode *metaNode in metaInfo) {
            NSArray *contents = metaNode.textContentOfDescendants;
            d[contents.firstObject] = contents.lastObject;
        }
        
        self.documentMetadata = d;
        
		self.url = [NSURL URLWithString:[@"https://www.edline.net" stringByAppendingString:[node attributeForName:@"src"]]];
	}
	return self;
}

@end

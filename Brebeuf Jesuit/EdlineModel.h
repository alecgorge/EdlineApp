//
//  EdlineModel.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTMLDocument.h"
#import "HTMLNode.h"
#import "HTMLNode+XPath.h"

@interface EdlineModel : NSObject

- (instancetype)initWithRequestOperation:(AFHTTPRequestOperation *)operation
					   andResponseObject:(NSData*)data;

@property (nonatomic) AFHTTPRequestOperation *operation;
@property (nonatomic) NSData *data;
@property (nonatomic) NSString *response;
@property (nonatomic) HTMLDocument *document;

@end

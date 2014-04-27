//
//  EdlineListItem.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

#import "HTMLNode.h"

@interface EdlineListItem : NSObject<NSCoding>

- (instancetype)initWithHTMLNode:(HTMLNode*)htmlNode;

@property (nonatomic) NSString *text;
@property (nonatomic) NSString *url;

@property (nonatomic) NSString *eventPath;
@property (nonatomic) AFHTTPRequestOperation *eventOperation;
@property (nonatomic) EdlineListItem *previousItem;

@end

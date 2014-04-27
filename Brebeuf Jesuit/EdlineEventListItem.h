//
//  EdlineEventListItem.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineListItem.h"

@interface EdlineEventListItem : EdlineListItem

- (instancetype)initWithHTMLNode:(HTMLNode *)htmlNode andDate:(NSString*)date;

@property (nonatomic) NSString *date;

@end

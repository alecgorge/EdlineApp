//
//  EdlineItem.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/13/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EdlineItem : NSObject

@property BOOL isFile;
@property BOOL isSectioned;
@property NSArray *sectionedInformation;
@property NSString *url;
@property NSString *name;
@property NSString *type;
@property NSString *content;
@property NSArray *contents;

@end

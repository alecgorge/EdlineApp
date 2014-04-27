//
//  EdlineXPath.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EdlineXPath : NSObject

+ (instancetype)shared;
+ (NSString *)xPathForKey:(NSString *)key;

@property (nonatomic) NSDictionary *mapping;

@end

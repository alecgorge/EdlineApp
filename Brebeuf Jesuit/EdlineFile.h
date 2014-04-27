//
//  EdlineFile.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EdlineFile : NSObject

- (instancetype)initWithURL:(NSURL*)url;

@property (nonatomic) NSURL *url;

@end

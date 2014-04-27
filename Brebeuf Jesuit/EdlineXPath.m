//
//  EdlineXPath.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineXPath.h"

@implementation EdlineXPath

+ (instancetype)shared {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)xPathForKey:(NSString *)key {
	return [self shared][key];
}

- (id)objectForKeyedSubscript:(id)key {
	return self.mapping[key];
}

- (id)init {
    if (self = [super init]) {
        self.mapping = @{
						 @"ListTitle"		: @"/head/title",
						 @"ListItems"		: @"//*[@id=\"be-pageContainer\"]/div[3]/ul/li/a",
						 @"ListDocTitle"	: @"//*[@id=\"viewAsEntid\"]/option[@selected=\"selected\"]",
						 @"ListDocItems"	: @"//*[@id=\"be-pageContainer\"]/div[3]/div[2]/ul/li/a",
						 @"CalItems"		: @"//*[@id=\"be-pageContainer\"]/div[3]/ul[@class=\"be-events\"]/li",
						 @"ActivityItems"	: @"//*[@id=\"be-pageContainer\"]/div[3]/div[@class=\"be-activFeed\"]/ul/li",
						 @"IFrameItem"		: @"//*[@id=\"docViewBodyIframe\"]",
						 @"TabTitle"		: @"//*[@id=\"be-pageContainer\"]/div[3]/div[1]/h1",
						 @"TabNewsItem"		: @"//*[@id=\"be-pageContainer\"]/div[3]/div[2]/div[2]/ul/a",
						 @"TabCalendarItem"	: @"//*[@id=\"be-pageContainer\"]/div[3]/div[2]/div[3]/ul/a",
						 @"TabContentsItem"	: @"//*[@id=\"be-pageContainer\"]/div[3]/div[2]/div[4]/ul/a",
						};
    }
    return self;
}

@end

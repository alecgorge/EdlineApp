//
//  EdlineFile.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineFile.h"

@implementation EdlineFile

- (instancetype)initWithURL:(NSURL *)url {
	if(self = [super init]) {
		self.url = url;
	}
	
	return self;
}

@end

//
//  EdlineModel.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineModel.h"

@implementation EdlineModel

- (instancetype)initWithRequestOperation:(AFHTTPRequestOperation *)operation
					   andResponseObject:(NSData *)data {
    self = [super init];
    if (self) {
        self.operation = operation;
		self.data = data;
		self.response = [[NSString alloc] initWithData:data
											  encoding:NSUTF8StringEncoding];
    }
    return self;
}

- (HTMLDocument *)document {
	if(!_document) {
		NSError *error;
		_document = [HTMLDocument documentWithData:self.data
										  encoding:NSUTF8StringEncoding
											 error:&error];

		if(error) {
			NSLog(@"html error: %@", error);
		}
	}
	
	return _document;
}

@end

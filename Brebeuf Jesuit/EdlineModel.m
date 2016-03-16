//
//  EdlineModel.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineModel.h"
#import "EdlineAPI2.h"

#import <NSData+Base64/NSData+Base64.h>

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

- (NSString *)description {
    return [NSString stringWithFormat:@"<---------------------\nHTTP Request: %@ %@\n======================\nHTTP Response: %@\n======================\nHTTP Body: %@\n--------------------->", self.operation.request, self.operation.request.allHTTPHeaderFields, self.operation.response, [[[NSString stringWithFormat:@"%@\n%@", EdlineAPI2.sharedAPI.uuid, self.response] dataUsingEncoding:NSUTF8StringEncoding]  base64Encoding]];
}

@end

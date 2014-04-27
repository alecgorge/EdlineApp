//
//  EdlineFilePreviewDataSource.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/13/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineFilePreviewDataSource.h"

@implementation EdlineFilePreviewDataSource

- (id)initWithURL:(NSURL *)_url {
	if(self = [super init]) {
		url = _url;
	}
	return self;
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
	return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller
					previewItemAtIndex:(NSInteger)index {
	return url;
}

@end

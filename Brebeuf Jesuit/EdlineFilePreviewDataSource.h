//
//  EdlineFilePreviewDataSource.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/13/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface EdlineFilePreviewDataSource : NSObject<QLPreviewControllerDataSource> {
	NSURL *url;
}

-(id)initWithURL:(NSURL*)_url;

@end

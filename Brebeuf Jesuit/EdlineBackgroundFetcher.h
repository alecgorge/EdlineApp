//
//  EdlineBackgroundFetcher.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/24/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EdlineBackgroundFetcher : NSObject

- (void)performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@property (nonatomic, readonly) BOOL hasCache;
@property (nonatomic) BOOL sendNotifications;

@end

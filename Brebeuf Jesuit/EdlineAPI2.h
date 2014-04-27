//
//  EdlineAPI2.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "EdlineTabbedPage.h"
#import "EdlineList.h"
#import "EdlineListItem.h"

typedef void (^FailureBlock)(AFHTTPRequestOperation *, NSError *);

@interface EdlineAPI2 : AFHTTPClient

+ (instancetype)sharedAPI;

@property (nonatomic) BOOL requiresCompleteLogin;

- (void)testLoginForUsername:(NSString*)username
					password:(NSString*)password
					 success:(void (^)(EdlineTabbedPage *homepage))cb
					 failure:(FailureBlock)failure;

- (void)reLoginIfNeeded:(void (^)(void))cb
				failure:(FailureBlock)failure;

- (void)submitEventForPage:(AFHTTPRequestOperation *)op
					onPath:(NSString *)path
					 named:(NSString *)name
					params:(NSString *)params
				   success:(void (^)(id displayable))cb
				   failure:(FailureBlock)failure;

- (void)loadListItem:(EdlineListItem*)item
			 success:(void (^)(id displayable))cb
			 failure:(FailureBlock)failure;

@property (nonatomic, readonly) EdlineListItem *activityFeedItem;
@property (nonatomic, readonly) EdlineListItem *privateReportsItem;

@end

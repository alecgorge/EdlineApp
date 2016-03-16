//
//  EdlineBackgroundFetcher.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/24/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineBackgroundFetcher.h"

#import "EdlineDocList.h"
#import "EdlineActivityList.h"

#import "EdlineActivityListItem.h"
#import "EdlineDocListItem.h"

@interface EdlineBackgroundFetcher ()

@property (nonatomic, copy) void (^completionHandler)(UIBackgroundFetchResult);

@property (nonatomic) BOOL userRequestedActivityFeedNotifications;
@property (nonatomic) BOOL userRequestedPrivateReportsNotifications;

@property (nonatomic) NSArray *activityFeedCache;
@property (nonatomic) NSDictionary *privateReportsCache;

@property EdlineList *currentActivityFeed;
@property EdlineList *currentPrivateReports;

@property NSMutableArray *activityFeed;
@property NSMutableDictionary *privateReports;

@property NSMutableArray *notifications;

@end

@implementation EdlineBackgroundFetcher

- (instancetype)init {
	if (self = [super init]) {
		self.privateReports = [NSMutableDictionary dictionary];
		self.activityFeed = [NSMutableArray array];
		
		self.notifications = [NSMutableArray array];
		
		self.userRequestedActivityFeedNotifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"activityNotifications"] boolValue];
		self.userRequestedPrivateReportsNotifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"privateReportsNotifications"] boolValue];

	}
	
	return self;
}

- (BOOL)hasCache {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"activityFeedCache"] != nil;
}

- (void)loadCache {
	NSData *activityData = [[NSUserDefaults standardUserDefaults] objectForKey:@"activityFeedCache"];
	self.activityFeedCache = nil;
	
	if(activityData)
		self.activityFeedCache = [NSKeyedUnarchiver unarchiveObjectWithData:activityData];
	
	NSData *reportsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"privateReportsCache"];
	self.privateReportsCache = nil;
	
	if(reportsData)
		self.privateReportsCache = [NSKeyedUnarchiver unarchiveObjectWithData:reportsData];
}

- (void)saveCache {
	NSData *activityData = [NSKeyedArchiver archivedDataWithRootObject:self.activityFeed];
	[[NSUserDefaults standardUserDefaults] setObject:activityData
											  forKey:@"activityFeedCache"];
	
	NSData *reportsData = [NSKeyedArchiver archivedDataWithRootObject:self.privateReports];
	[[NSUserDefaults standardUserDefaults] setObject:reportsData
											  forKey:@"privateReportsCache"];

	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)failure {
	CLS_LOG(@"background fetch failed.");
	[Flurry logEvent:@"background_fetch_failed"];
	self.completionHandler(UIBackgroundFetchResultFailed);
}

- (void)performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	[Flurry logEvent:@"background_fetch_started"];
	self.completionHandler = completionHandler;
	
	[EdlineAPI2 sharedAPI].requiresCompleteLogin = YES;
	
	[self loadCache];
	
	[[EdlineAPI2 sharedAPI] loadListItem:[EdlineAPI2 sharedAPI].privateReportsItem
								 success:^(id displayable) {
									 CLS_LOG(@"found displayable %@", displayable);
									 if(displayable && [displayable respondsToSelector:@selector(items)]) {
										 self.currentPrivateReports = displayable;
										 NSUInteger index = 0;
										 
										 for (EdlineListItem *user in self.currentPrivateReports.items) {
											 [self loadPrivateReportFor:user
																atIndex:index];
											 
											 index++;
										 }
									 }
									 else {
										 [self fetchActivityFeed];
									 }
								 }
								 failure:^(AFHTTPRequestOperation *op, NSError *err) {
									 [self failure];
								 }];
}

- (void)loadPrivateReportFor:(EdlineListItem*)user
					 atIndex:(NSUInteger)index {
	[[EdlineAPI2 sharedAPI] loadListItem:user
								 success:^(id displayable) {
									 if(displayable) {
										 EdlineDocList *docList = displayable;
										 
										 CLS_LOG(@"found displayable %@ for user %@", displayable, user);
										 if([docList respondsToSelector:@selector(items)] && docList.items) {
											 self.privateReports[@(index)] = docList.items;
										 }
										 else {
											 self.privateReports[@(index)] = @[];
										 }
										 
										 [self validatePrivateReports];
									 }
								 }
								 failure:^(AFHTTPRequestOperation *op, NSError *err) {
									 [self failure];
								 }];
}

- (void)validatePrivateReports {
	if(self.privateReports.count != self.currentPrivateReports.items.count) {
		return;
	}
	
	for (NSUInteger i = 0; i < self.privateReports.count; i++) {
		NSArray *cachedDocList = self.privateReportsCache[[NSNumber numberWithInteger:i]];
		NSMutableArray *fetchedDocList = [self.privateReports[[NSNumber numberWithInteger:i]] mutableCopy];
		
		NSMutableArray *newDocItems = [NSMutableArray array];

		for (NSInteger j = 0; j < fetchedDocList.count; j++) {
			EdlineDocListItem *item = fetchedDocList[j];
			
			if(![cachedDocList containsObject:item]) {
				[newDocItems addObject:item];
			}
		}
	
		if(newDocItems.count == 0) {
			continue;
		}
		
		if(self.userRequestedPrivateReportsNotifications) {
			for (EdlineDocListItem *item in newDocItems) {
				UILocalNotification *not = [[UILocalNotification alloc] init];
				not.alertBody = [NSString stringWithFormat:@"Private Report: %@ —  %@", item.text, item.className];
				not.userInfo = @{@"tab": @2};
				
				[self.notifications addObject:not];
			}
		}
	}
	
	[self fetchActivityFeed];
}

- (void)fetchActivityFeed {
	[[EdlineAPI2 sharedAPI] loadListItem:[EdlineAPI2 sharedAPI].activityFeedItem
								 success:^(id displayable) {
									 CLS_LOG(@"found displayable %@", displayable);
									 if(displayable && [displayable respondsToSelector:@selector(items)]) {
										 self.currentActivityFeed = displayable;
										 
										 if (self.currentActivityFeed.items.count > 0) {
											 [self fetchAllUsersActivityFeed: self.currentActivityFeed.items[1]];
										 }
										 else {
											 [self processNotifications];
										 }
									 }
									 else {
										 [self failure];
									 }
								 }
								 failure:^(AFHTTPRequestOperation *op, NSError *err) {
									 [self failure];
								 }];
}

- (void)fetchAllUsersActivityFeed:(EdlineActivityListItem*)item {
	[[EdlineAPI2 sharedAPI] loadListItem:item
								 success:^(id displayable) {
									 CLS_LOG(@"found displayable %@", displayable);
									 if(displayable) {
										 if([displayable isKindOfClass:[EdlineActivityList class]]) {
											 EdlineActivityList *actList = displayable;
											 
											 [self.activityFeed addObject:actList.items];
											 
											 [self validateActivityFeed];
										 }
										 else {
											 [self processNotifications];
										 }
									 }
									 else {
										 [self failure];
									 }
								 }
								 failure:^(AFHTTPRequestOperation *op, NSError *err) {
									 [self failure];
								 }];
}

- (void)validateActivityFeed {
	NSArray *cachedActivityFeed = self.activityFeedCache[0];
	NSMutableArray *fetchedActivityFeed = [self.activityFeed[0] mutableCopy];
	
	NSMutableArray *newActivityFeedItems = [NSMutableArray array];
	
	for (NSInteger j = 0; j < fetchedActivityFeed.count; j++) {
		EdlineActivityListItem *item = fetchedActivityFeed[j];
		
		if(![cachedActivityFeed containsObject:item]) {
			[newActivityFeedItems addObject:item];
		}
	}
	
	if(newActivityFeedItems.count > 0 && self.userRequestedActivityFeedNotifications) {
		for (EdlineActivityListItem *item in newActivityFeedItems) {
			UILocalNotification *not = [[UILocalNotification alloc] init];
			not.alertBody = [NSString stringWithFormat:@"Activity Feed: %@ —  %@", item.text, item.className];
			not.userInfo = @{@"tab": @0};
			
			[self.notifications addObject:not];
		}
	}
	
	[self processNotifications];
}

- (void)processNotifications {
	if(self.userRequestedActivityFeedNotifications || self.userRequestedPrivateReportsNotifications) {
		NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber;
		
		[UIApplication sharedApplication].applicationIconBadgeNumber = count + self.notifications.count;
		
		for (UILocalNotification *not in self.notifications) {
			[[UIApplication sharedApplication] presentLocalNotificationNow:not];
		}
		
		[self saveCache];
		
		CLS_LOG(@"done with background fetch. found %lu new items", self.notifications.count);
		
		if(self.notifications.count == 0) {
			[Flurry logEvent:@"background_fetch_no_items"
			  withParameters:@{@"new_items": [NSNumber numberWithInteger:self.notifications.count]}];
		}
		else {
			[Flurry logEvent:@"background_fetch_completed"
			  withParameters:@{@"new_items": [NSNumber numberWithInteger:self.notifications.count]}];
		}
	}
	else {
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	}
	
	[Flurry logEvent:@"background_fetch_settings"
	  withParameters:@{@"activity_feed": [NSNumber numberWithBool:self.userRequestedActivityFeedNotifications],
					   @"private_reports": [NSNumber numberWithBool:self.userRequestedPrivateReportsNotifications]}];

	if(self.notifications.count > 0)
		self.completionHandler(UIBackgroundFetchResultNewData);
	else
		self.completionHandler(UIBackgroundFetchResultNoData);
}

@end

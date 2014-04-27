//
//  AppDelegate.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/10/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "AppDelegate.h"

#import "EdlineAPIClient.h"
#import "EdlineHomeViewController.h"

#import "EdlineBackgroundFetcher.h"

#import <Crashlytics/Crashlytics.h>
#import <Appirater.h>
#import <FXKeychain/FXKeychain.h>

static AppDelegate *inst;

@implementation AppDelegate

+ (AppDelegate *)sharedDelegate {
	return inst;
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.notificationsEnabled = NO;
	
	if(SYSTEM_VERSION_LESS_THAN(@"7.0")) {
		[[NSUserDefaults standardUserDefaults] setObject:@NO
												  forKey:@"activityNotifications"];
		[[NSUserDefaults standardUserDefaults] synchronize];

		[[NSUserDefaults standardUserDefaults] setObject:@NO
												  forKey:@"privateReportsNotifications"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

	
	inst = self;
	
	[FXKeychain defaultKeychain].accessibility = FXKeychainAccessibleAfterFirstUnlock;
	
	[EdlineAPI2 sharedAPI].requiresCompleteLogin = YES;
	
	if(![[NSUserDefaults standardUserDefaults] objectForKey:@"activityNotifications"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@YES
												  forKey:@"activityNotifications"];
	}
	
	if(![[NSUserDefaults standardUserDefaults] objectForKey:@"privateReportsNotifications"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@YES
												  forKey:@"privateReportsNotifications"];
	}
	
	[Crashlytics startWithAPIKey:@"bbdd6a4df81e6b1498130a0f1fbf72d14e334fb4"];
	
	[Appirater setAppId:@"501559510"];
	[Appirater setUsesUntilPrompt: 10];
	[Appirater appLaunched: YES];
	
	[Flurry setBackgroundSessionEnabled:NO];
	[Flurry startSession:@"NWRKYDKCCWN7FXDMJYZ3"];
	
	[self setupVisuals];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	self.home = [[EdlineHomeViewController alloc] init];
		
	self.window.rootViewController = self.home;
	
    [self.window makeKeyAndVisible];
	
	// 45 minutes
	if (ENABLE_NOTIFICATIONS && [[UIApplication sharedApplication] respondsToSelector:@selector(setMinimumBackgroundFetchInterval:)]) {
		[UIApplication sharedApplication].minimumBackgroundFetchInterval = 60 * 45;
	
		EdlineBackgroundFetcher *fetcher = [[EdlineBackgroundFetcher alloc] init];
		if(!fetcher.hasCache) {
			CLS_LOG(@"no background cache found!");
			
			fetcher.sendNotifications = NO;
			[fetcher performFetchWithCompletionHandler:^(UIBackgroundFetchResult res) {
				CLS_LOG(@"background fetch cache preload result: %d", res);
			}];
		}
	}
	
	UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
	if(localNotif) {
		self.home.selectedIndex = [localNotif.userInfo[@"tab"] integerValue];
	}
		
    return YES;
}

- (void)setupVisuals {
	NSDictionary *font = @{UITextAttributeTextColor: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
						   UITextAttributeTextShadowColor: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
						   UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
						   UITextAttributeFont: [UIFont fontWithName:@"Chalkduster" size:16.0]};
	
	UIColor *green = EDLINE_GREEN;
	

	if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
		
		[UINavigationBar appearance].tintColor = [UIColor whiteColor];
		[UINavigationBar appearance].barTintColor = green;

		[UIToolbar appearance].tintColor = [UIColor whiteColor];
		[UIToolbar appearance].barTintColor = green;
				
		[UIBarButtonItem appearance].tintColor = [UIColor whiteColor];
		
		[UITabBar appearance].tintColor = green;
	}
	else {
		[[UINavigationBar appearance] setTintColor:green];
		[[UIToolbar appearance] setBackgroundColor:green];
	}

	[[UINavigationBar appearance] setTitleTextAttributes:font];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[EdlineAPI2 sharedAPI].requiresCompleteLogin = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	[Appirater appEnteredForeground: YES];

	application.applicationIconBadgeNumber = 0;
}

-  (void)application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	if (!ENABLE_NOTIFICATIONS) {
		completionHandler(UIBackgroundFetchResultNoData);
		return;
	}
	EdlineBackgroundFetcher *fetcher = [[EdlineBackgroundFetcher alloc] init];
	[fetcher performFetchWithCompletionHandler:completionHandler];
}

@end

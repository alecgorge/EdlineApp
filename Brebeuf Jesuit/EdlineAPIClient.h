//
//  EdlineAPIClient.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/10/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <AFHTTPClient.h>
#import "EdlineItem.h"

@interface EdlineAPIClient : AFHTTPClient {
	BOOL _isLoggedIn;
	void(^err)(AFHTTPRequestOperation *operation, NSError *err);
	
	NSRegularExpression *findClasses;
	NSRegularExpression *testLogin;
	NSRegularExpression *findStudents;
}

@property BOOL requiresCompleteLogin;

+ (EdlineAPIClient *) client;

- (void) attemptLogIn:(NSString *) username password:(NSString *) password success:(void(^)(void)) success failure:(void(^)(NSError*)) failure;

- (void)loadClassesForStudent:(NSString *)studentId success:(void(^)(NSArray *)) succ;
- (void)loadItem:(NSString *)item title:(NSString*)title success:(void(^)(EdlineItem *)) succ;

- (void)loginForCookies:(NSString *) username password:(NSString *) password success:(void(^)(AFHTTPRequestOperation *operation, id responseObject)) success failure:(void(^)(AFHTTPRequestOperation *operation, id responseObject)) failure;

- (void)privateReportsForStudent:(NSString *)studentId success:(void (^)(EdlineItem *))succ;
- (void)combinedCalendarForStudent:(NSString *)studentId success:(void (^)(EdlineItem *))succ;

@end

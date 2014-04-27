//
//  EdlineUser.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/12/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineUser.h"
#import <SSKeychain.h>

@implementation EdlineUser

@synthesize isLoggedIn = _isLoggedIn;

@synthesize isParent;

@synthesize username;
@synthesize password;

+(EdlineUser *)currentUser {
	static EdlineUser *sharedSingleton;
	
	@synchronized(self) {
		if (!sharedSingleton) {
			sharedSingleton = [[EdlineUser alloc] init];
		}
		
		return sharedSingleton;
	}
}

- (id)init {
	if(self = [super init]) {
		_isLoggedIn = NO;
		
		self.studentsOrClasses = [NSMutableArray array];
		
		[self loadSavedCredentials];
	}
	return self;
}

-(void)loadSavedCredentials {
	NSArray *accounts = [SSKeychain accountsForService:@"com.alecgorge.edline"];
	if(accounts == nil) {
		username = nil;
		password = nil;
	}
	else {
		username = [[accounts objectAtIndex:0] objectForKey: @"acct"];
		password = [SSKeychain passwordForService:@"com.alecgorge.edline"
										  account:username];
	}
	
	if(self.username != nil && self.password != nil) {
		_isLoggedIn = YES;
	}
}

-(void)saveCredentials {
	// remove all old credentials
	NSArray *accounts = [SSKeychain accountsForService:@"com.alecgorge.edline"];
	for(NSDictionary *dict in accounts) {
		[SSKeychain deletePasswordForService:@"com.alecgorge.edline"
									 account:[dict objectForKey:@"acct"]];
	}
	
	[SSKeychain setPassword:self.password
				 forService:@"com.alecgorge.edline"
					account:self.username];
	
	[self loadSavedCredentials];
}

-(void)setUsername:(NSString *)newusername {
	username = newusername;
	
	if(username != nil && ![username isEqualToString:@""]) {
		if(password != nil && ![password isEqualToString:@""]) {
			_isLoggedIn = YES;
			[self saveCredentials];
		}
	}
}

-(void)setPassword:(NSString *)newpassword {
	password = newpassword;
	
	if(username != nil && ![username isEqualToString:@""]) {
		if(password != nil && ![password isEqualToString:@""]) {
			_isLoggedIn = YES;
			[self saveCredentials];
		}
	}
}

- (void)logOut {
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

	[def removeObjectForKey: @"username"];
	[def removeObjectForKey: @"password"];
	
	[def synchronize];
	
	_isLoggedIn = NO;
}

@end

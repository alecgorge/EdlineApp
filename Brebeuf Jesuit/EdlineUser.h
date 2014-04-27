//
//  EdlineUser.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/12/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EdlineUser : NSObject {
	BOOL _isLoggedIn;
}

@property (readonly) BOOL isLoggedIn;

@property BOOL isParent;

@property (nonatomic) NSString *username;
@property (nonatomic) NSString *password;

@property NSMutableArray *studentsOrClasses;

+ (EdlineUser *)currentUser;
- (void)logOut;
- (void)saveCredentials;

@end

//
//  EdlineAPIClient.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/10/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineAPIClient.h"
#import "NSString+HTML.h"
#import "jQuery.h"

@implementation EdlineAPIClient

+ (EdlineAPIClient *)client {
	static EdlineAPIClient *sharedSingleton;
	
	@synchronized(self) {
		if (!sharedSingleton) {
			sharedSingleton = [[EdlineAPIClient alloc] init];
		}
		
		return sharedSingleton;
	}
}

- (id)init {
	if(self = [super initWithBaseURL:[NSURL URLWithString:@"https://www.edline.net"]]) {
		_isLoggedIn = NO;
		self.requiresCompleteLogin = YES;
		
		[self setDefaultHeader:@"User-Agent"
						 value:@"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"];
		
		err = ^(AFHTTPRequestOperation *op, NSError *error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			alert = nil;
		};
		
		findClasses = [NSRegularExpression regularExpressionWithPattern:@"href=\"([^;\"]+)\"[^t]*title=\"([^\"]+)\""
																options:NSRegularExpressionDotMatchesLineSeparators
																  error:nil];
		
		findStudents = [NSRegularExpression regularExpressionWithPattern:@"<option value=\"(\\d+)\"\\W+>\\W+([a-zA-Z0-9#&;., -]+)\\W+</option>"
																 options:NSRegularExpressionDotMatchesLineSeparators
																   error:nil];
	}
	return self;
}

- (void)loadItem:(NSString *)url
		   title:(NSString *)title
		 success:(void(^)(EdlineItem *)) succ {
	void(^suc)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject){
		if(![((AFURLConnectionOperation*)operation).response.MIMEType isEqualToString:@"text/html"]) {
			EdlineItem *item = [[EdlineItem alloc] init];
			item.name = ((AFURLConnectionOperation*)operation).response.suggestedFilename;
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			
			//make a file name to write the data to using the
			//documents directory:
			NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, item.name];
			[((NSData*)responseObject) writeToFile:fullPath
										atomically:YES];

			item.url = fullPath;
			item.isFile = YES;
			
			succ(item);
			return;
		}
		
		NSString *itemPage = [[NSString alloc] initWithData:(NSData*) responseObject
												   encoding:NSUTF8StringEncoding];
		
		CLS_LOG(@"itemPage: %@", itemPage);
		
		jQuery *_$ = [[jQuery alloc] initWithHTML:itemPage
										andScript:@"scrape_items"];
		[_$ start:^(NSError *error, id res) {
			EdlineItem *item = [[EdlineItem alloc] init];
			item.name = title;
			item.url = url;
			
			if(error) {
				item.type = @"iframe";
				item.content = url;
				
				succ(item);
				return;
			}
			
			item.type = [res objectForKey:@"type"];
			
			if([item.type isEqualToString:@"html"]) {
				item.type = @"iframe";
				NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *documentsDirectory = [pathArray objectAtIndex:0];
				NSString *textPath = [documentsDirectory stringByAppendingPathComponent:@"temp.html"];
				[[res objectForKey:@"content"] writeToFile:textPath
												atomically:YES
												  encoding:NSUTF8StringEncoding
													 error:nil];
				
				item.content = [NSURL fileURLWithPath:textPath];
				succ(item);
				return;
			}
			
			item.content = [res objectForKey:@"content"];
			item.contents = [res objectForKey:@"contents"];
			item.isSectioned = [[res objectForKey:@"isSectioned"] boolValue];
			item.sectionedInformation = [res objectForKey:@"sectionedInformation"];
			
			succ(item);
		}];
	};
	
	if(self.requiresCompleteLogin) {
		[self loginForCookies:[EdlineUser currentUser].username
					 password:[EdlineUser currentUser].password
					  success:^(AFHTTPRequestOperation *operation, id responseObject) {
						  [self getPath:url
							 parameters:nil
								success:suc
								failure:err];						  
					  }
					  failure:err];
		
		return;
	}
	
	[self getPath:url
	   parameters:nil
		  success:suc
		  failure:err];
}

- (void)privateReportsForStudent:(NSString *)studentId
						 success:(void (^)(EdlineItem *))succ {
	void(^s)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *classesPage = [[NSString alloc] initWithData:(NSData*) responseObject
													  encoding:NSUTF8StringEncoding];
		CLS_LOG(@"private reports page: %@", classesPage);
		jQuery *_$ = [[jQuery alloc] initWithHTML:classesPage
										andScript:@"private_reports"];
		[_$ start:^(NSError *error, id res) {
			if(error != nil) {
				CLS_LOG(@"Error fetching private reports: %@", error);
			}
			
			EdlineItem *item = [[EdlineItem alloc] init];
			item.isSectioned = YES;
			item.type = @"sectioned";
			item.name = @"Private Reports";
			item.sectionedInformation = res;
			item.url = @"private_reports";
			
			succ(item);
		}];
	};
	
	[self submitEvent:@"https://www.edline.net/post/GroupHome.page"
				 data:@{@"invokeEvent" : @"privateReports", @"eventParms" : @"TCNK=mobileHelper"}
			  success:^(AFHTTPRequestOperation *operation, id responseObject) {
				  if(studentId != nil) {
					  [self submitEvent:@"https://www.edline.net/post/UserDocList.page"
								   data:@{@"selectViewAsEvent" : @"1", @"viewAsEntid" : studentId}
								success:s];
				  }
				  else {
					  s(operation, responseObject);
				  }
			  }];
}

- (void)combinedCalendarForStudent:(NSString *)studentId
						   success:(void (^)(EdlineItem *))succ {
	void(^s)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *classesPage = [[NSString alloc] initWithData:(NSData*) responseObject
													  encoding:NSUTF8StringEncoding];
		CLS_LOG(@"combined calendar reports page: %@", classesPage);
		jQuery *_$ = [[jQuery alloc] initWithHTML:classesPage
										andScript:@"scrape_items"];
		[_$ start:^(NSError *error, id res) {
			if(error != nil) {
				CLS_LOG(@"Error fetching calendar reports: %@", error);
			}
			
			EdlineItem *item = [[EdlineItem alloc] init];
			item.name = @"Combined Calendar";
			item.url = @"private_reports";
			
			item.type = [res objectForKey:@"type"];
			
			if([item.type isEqualToString:@"html"]) {
				item.type = @"iframe";
				NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *documentsDirectory = [pathArray objectAtIndex:0];
				NSString *textPath = [documentsDirectory stringByAppendingPathComponent:@"temp.html"];
				[[res objectForKey:@"content"] writeToFile:textPath
												atomically:YES
												  encoding:NSUTF8StringEncoding
													 error:nil];
				
				item.content = [NSURL fileURLWithPath:textPath];
				succ(item);
				return;
			}
			
			item.content = [res objectForKey:@"content"];
			item.contents = [res objectForKey:@"contents"];
			item.isSectioned = [[res objectForKey:@"isSectioned"] boolValue];
			item.sectionedInformation = [res objectForKey:@"sectionedInformation"];
			
			succ(item);
		}];
	};
	
	[self submitEvent:@"https://www.edline.net/post/GroupHome.page"
				 data:@{@"invokeEvent" : @"combinedCalendar", @"eventParms" : @"TCNK=mobileHelper"}
			  success:^(AFHTTPRequestOperation *operation, id responseObject) {
				  if(studentId != nil) {
					  [self submitEvent:@"https://www.edline.net/post/CalendarView.page"
								   data:@{@"selectViewAsEvent" : @"1", @"viewAsEntid" : studentId}
								success:s];
				  }
				  else {
					  s(operation, responseObject);
				  }
			  }];
}

- (void)submitEvent:(NSString*)path data:(NSDictionary *) eventParams success:(void(^)(AFHTTPRequestOperation *operation, id responseObject)) succ {
	if(self.requiresCompleteLogin) {
		[self loginForCookies:[EdlineUser currentUser].username
					 password:[EdlineUser currentUser].password
					  success:^(AFHTTPRequestOperation *operation, id responseObject) {
						  [self postPath:path
							  parameters: eventParams
								 success:succ
								 failure:err];
					  }
					  failure:err];
		
		return;
	}
	[self postPath:path
		parameters:eventParams
		   success:succ
		   failure:err];
}

- (void)loadClassesForStudent:(NSString *)studentId success:(void(^)(NSArray *results)) succ {
	[self submitEvent:@"https://www.edline.net/post/MyClasses.page"
				 data:@{@"selectViewAsEvent" : @"1", @"viewAsEntid" : studentId}
			  success:^(AFHTTPRequestOperation *operation, id responseObject) {
				  NSString *classesPage = [[NSString alloc] initWithData:(NSData*) responseObject
																encoding:NSUTF8StringEncoding];
				  
				  NSArray *matches = [findClasses matchesInString:classesPage
														  options:0
															range:NSMakeRange(0, classesPage.length)];
				  
				  NSMutableArray *results = [NSMutableArray array];
				  
				  for(NSTextCheckingResult *match in matches) {
					  NSString *url = [[classesPage substringWithRange:[match rangeAtIndex:1]] kv_decodeHTMLCharacterEntities];
					  NSString *name = [[classesPage substringWithRange:[match rangeAtIndex:2]] kv_decodeHTMLCharacterEntities];
					  
					  CLS_LOG(@"url, name for %@: %@ %@", studentId, url, name);
					  
					  [results addObject:@{
					   @"is_student": @NO,
					   @"name": name,
					   @"id": url
					   }];
				  }
				  
				  succ(results);
			  }];
}

- (void)loginForCookies:(NSString *)username
			   password:(NSString *)password
				success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
				failure:(void (^)(AFHTTPRequestOperation *operation, id responseObject))failure {
	[self getPath:@"/Index.page"
	   parameters:nil
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  NSString *homePage = [[NSString alloc] initWithData:((NSData*) responseObject)
														 encoding:NSUTF8StringEncoding];
			  CLS_LOG(@"homePage for %@ %@: %@", username, password, homePage);
			  
			  [self postPath:@"/post/Index.page"
				  parameters:@{
			   @"loginEvent": @"1",
			   @"login": @"Log In",
			   @"un": username,
			   @"kscf": password
			   }
					 success:^(AFHTTPRequestOperation *operation, id responseObject) {
						 self.requiresCompleteLogin = NO;
						 
						 success(operation, responseObject);
					 }
					 failure:failure];
		  }
		  failure:failure];
	
}

- (void)attemptLogIn:(NSString *)username
			password:(NSString *)password
			 success:(void (^)(void))success
			 failure:(void (^)(NSError *))failure {
	[self loginForCookies:username
				 password:password
				  success:^(AFHTTPRequestOperation *operation, id responseObject) {
					  NSString *loginPage = [[NSString alloc] initWithData:((NSData*) responseObject)
																  encoding:NSUTF8StringEncoding];
					  CLS_LOG(@"loginPage for %@ %@: %@", username, password, loginPage);
					  
					  if([loginPage rangeOfString:@"<title>Please note:</title>"].location != NSNotFound) {
						  // invalid login
						  
						  failure([[NSError alloc] initWithDomain:@"com.alecgorge.Brebeuf-Jesuit"
															 code:54
														 userInfo:nil]);
						  
						  return;
					  }
					  
					  [self postPath:@"/post/MyClasses.page"
						  parameters:@{
					   @"invokeEvent": @"myClasses",
					   @"eventParms": @"TCNK=mobileHelper"
					   }
							 success:^(AFHTTPRequestOperation *operation, id responseObject) {
								 NSString *classesPage = [[NSString alloc] initWithData:((NSData*) responseObject)
																			   encoding:NSUTF8StringEncoding];
								 CLS_LOG(@"classesPage for %@ %@: %@", username, password, classesPage);
								 
								 // first check if this is a parent account
								 NSArray *studentMatches = [findStudents matchesInString:classesPage
																				 options:0
																				   range:NSMakeRange(0, classesPage.length)];
								 
								 if([studentMatches count] > 0) {
									 [EdlineUser currentUser].isParent = YES;
									 [EdlineUser currentUser].studentsOrClasses = [NSMutableArray array];
									 
									 for(NSTextCheckingResult *match in studentMatches) {
										 NSString *stud_id = [classesPage substringWithRange:[match rangeAtIndex:1]];
										 NSString *stud_name = [[classesPage substringWithRange:[match rangeAtIndex:2]] kv_decodeHTMLCharacterEntities];
										 
										 CLS_LOG(@"id, name for %@ %@: %@ %@", username, password, stud_id, stud_name);
										 
										 [[EdlineUser currentUser].studentsOrClasses addObject:@{
										  @"is_student": @YES,
										  @"name": stud_name,
										  @"student_id": stud_id
										  }];
									 }
									 
									 success();
									 
									 return;
								 }
								 
								 NSArray *matches = [findClasses matchesInString:classesPage
																		 options:0
																		   range:NSMakeRange(0, classesPage.length)];
								 
								 [EdlineUser currentUser].isParent = NO;
								 [EdlineUser currentUser].studentsOrClasses = [NSMutableArray array];
								 
								 for(NSTextCheckingResult *match in matches) {
									 NSString *url = [[classesPage substringWithRange:[match rangeAtIndex:1]] kv_decodeHTMLCharacterEntities];
									 NSString *name = [[classesPage substringWithRange:[match rangeAtIndex:2]] kv_decodeHTMLCharacterEntities];
									 
									 CLS_LOG(@"url, name for %@ %@: %@ %@", username, password, url, name);
									 
									 [[EdlineUser currentUser].studentsOrClasses addObject:@{
									  @"is_student": @NO,
									  @"name": name,
									  @"id": url
									  }];
								 }
								 
								 if([matches count] > 0) {
									 [EdlineUser currentUser].isParent = NO;
									 
									 success();
								 }
							 }
							 failure:err];
				  }
				  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					  failure(error);
					  err(operation, error);
				  }];
}

@end

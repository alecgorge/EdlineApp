//
//  EdlineAPI2.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineAPI2.h"

#import "EdlineDocList.h"
#import "EdlineEventList.h"
#import "EdlineActivityList.h"
#import "EdlineFile.h"
#import "EdlineIframe.h"
#import <FXKeychain/FXKeychain.h>

@interface EdlineAPI2 ()

- (void)visitHomePage:(void (^)(void))success
			  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

@end

@implementation EdlineAPI2

+ (instancetype)sharedAPI {
    static dispatch_once_t once;
    static EdlineAPI2 *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.edline.net"]];
		
		[sharedInstance setDefaultHeader:@"User-Agent"
								   value:@"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"];
		
		sharedInstance.requiresCompleteLogin = YES;
    });
    return sharedInstance;
}

- (void)visitHomePage:(void (^)(void))success
			  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:@"/Index.page"
	   parameters:Nil
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  success();
		  }
		  failure:failure];
}

- (void)testLoginForUsername:(NSString *)username
					password:(NSString *)password
					 success:(void (^)(EdlineTabbedPage *homepage))cb
					 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self visitHomePage:^{
		[self postPath:@"/post/Index.page"
			parameters:@{
						 @"loginEvent"	: @1,
						 @"un"			: username == nil ? @"" : username,
						 @"kscf"		: password == nil ? @"" : password
						 }
			   success:^(AFHTTPRequestOperation *operation, id responseObject) {
				   if([operation.response.URL.path isEqualToString:@"/Notification.page"]) {
					   cb(nil);
				   }
				   else {
					   cb([[EdlineTabbedPage alloc] initWithRequestOperation:operation
														   andResponseObject:responseObject]);
				   }
			   }
			   failure:failure];
	}
				failure:failure];
}

- (void)submitEventForPage:(AFHTTPRequestOperation *)op
					onPath:(NSString *)path
					 named:(NSString *)name
					params:(NSString *)params
				   success:(void (^)(id displayable))cb
				   failure:(FailureBlock)failure {
	
	__block NSString *postPath = path;
	[self reLoginIfNeeded:^{
		if([params hasPrefix:@"viewAsUserEntid"]) {
			postPath = @"/post/ViewAsPicker.page";
		}
		
		void (^blk)(void) = ^{
			[self postPath:postPath == nil ? @"/post/GroupHome.page" : postPath
				   referer:op == nil ? nil : op.response.URL.absoluteString
				parameters:@{@"invokeEvent": name, @"eventParms": params == nil ? @"undefined": params}
				  redirect:YES
				   success:^(AFHTTPRequestOperation *operation, id responseObject) {
					   NSString *str = [[NSString alloc] initWithData:responseObject
															 encoding:NSUTF8StringEncoding];
					   
					   if([operation.response.URL.path isEqualToString:@"/CalendarView.page"]
						  && [str rangeOfString:@"id=\"calView1\" value=\"off\" checked"].location == NSNotFound) {
						   [self postPath:@"/post/CalendarView.page"
								  referer:operation.response.URL.absoluteString
							   parameters:@{@"invokeEvent": @"toggleMode", @"eventParms": @"undefined"}
								 redirect:YES
								  success:^(AFHTTPRequestOperation *operation, id responseObject) {
									  cb([self findDisplayableForOperation:operation
														 andResponseObject:responseObject]);
								  }
								  failure:failure];
					   }
					   else {
						   cb([self findDisplayableForOperation:operation
											  andResponseObject:responseObject]);
					   }
				   }
				   failure:failure];
		};
		
		if(op) {
			[self getPath:op.response.URL.absoluteString
			   parameters:nil
				  success:^(AFHTTPRequestOperation *operation, id responseObject) {
					  blk();
				  }
				  failure:failure];
		}
		else {
			blk();
		}
	}
				  failure:failure];
}

- (void)loadListItem:(EdlineListItem *)item
			 success:(void (^)(id))cb
			 failure:(FailureBlock)failure {
	CLS_LOG(@"loading: %@", item.url);
	[self reLoginIfNeeded:^{
		NSURL *testExternal = [NSURL URLWithString:item.url];
		
		if ([[item.url substringToIndex:4] isEqualToString:@"java"]) {
			NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:@"javascript:submitEvent\\('([a-zA-Z0-9-_]+)', '([a-zA-Z0-9-_=;]*)'\\);"
																				 options:0
																				   error:nil];
			NSArray *matches = [exp matchesInString:item.url
											options:0
											  range:NSMakeRange(0, item.url.length)];
			
			NSString *key = nil;
			NSString *val = nil;
			if(matches.count == 0) {
				exp = [NSRegularExpression regularExpressionWithPattern:@"javascript:submitEvent\\('([a-zA-Z0-9-_]+)'\\);"
																options:0
																  error:nil];
				
				matches = [exp matchesInString:item.url
									   options:0
										 range:NSMakeRange(0, item.url.length)];
				
				NSTextCheckingResult *match = matches[0];
				key = [item.url substringWithRange:[match rangeAtIndex:1]];
			}
			else {
				NSTextCheckingResult *match = matches[0];
				key = [item.url substringWithRange:[match rangeAtIndex:1]];
				val = [item.url substringWithRange:[match rangeAtIndex:2]];
			}
			
			void (^blk)(void) = ^{
				[self submitEventForPage:item.eventOperation
								  onPath:item.eventPath
								   named:key
								  params:val
								 success:^(id list) {
									 cb(list);
								 }
								 failure:failure];
			};
			
			if(item.previousItem) {
				[self loadListItem:item.previousItem
						   success:^(id displayable) {
							   blk();
						   }
						   failure:failure];
			}
			else {
				blk();
			}
		}
		else if (testExternal && testExternal.host && ![testExternal.host isEqualToString:@"edline.net"] && ![testExternal.host isEqualToString:@"www.edline.net"]) {
			// external link
			EdlineIframe *iframe = [[EdlineIframe alloc] init];
			iframe.url = testExternal;
			
			cb(iframe);
		}
		else {
			void (^blk)(void) = ^{
				[self getPath:item.url
				   ifModified:nil
				handleCookies:YES
					  referer:item.eventOperation ? item.eventOperation.response.URL.absoluteString : nil
					  success:^(AFHTTPRequestOperation *operation, id responseObject) {
						  cb([self findDisplayableForOperation:operation
											 andResponseObject:responseObject]);
					  }
					  failure:failure];
			};
			
			if(item.previousItem) {
				[self loadListItem:item.previousItem
						   success:^(id displayable) {
							   blk();
						   }
						   failure:failure];
			}
			else {
				blk();
			}
		}
	}
				  failure:failure];
}

- (void)reLoginIfNeeded:(void (^)(void))cb
				failure:(FailureBlock)failure {
	if(!self.requiresCompleteLogin) {
		return cb();
	}
	
	[self testLoginForUsername:[FXKeychain defaultKeychain][@"u"]
					  password:[FXKeychain defaultKeychain][@"p"]
					   success:^(EdlineTabbedPage *homepage) {
						   self.requiresCompleteLogin = NO;
						   cb();
					   }
					   failure:failure];
}

- (NSString *) applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (id)findDisplayableForOperation:(AFHTTPRequestOperation*)operation
				andResponseObject:(id)responseObject {
	HTMLDocument *doc = [HTMLDocument documentWithData:responseObject
											  encoding:NSUTF8StringEncoding
												 error:nil];
	
	if(![operation.response.allHeaderFields[@"Content-Type"] hasPrefix:@"text/html"]) {
		[Flurry logEvent:@"view_file"];
		NSString *filename = [operation.response.URL.lastPathComponent stringByReplacingOccurrencesOfString:@"+"
																								 withString:@" "];
		
		NSString *file = [NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory], filename];
		
		[((NSData*)responseObject) writeToFile:file
									atomically:YES];
		
		EdlineFile *efile = [[EdlineFile alloc] init];
		efile.url = [NSURL fileURLWithPath:file];
		
		return efile;
	}
	
	if([doc.rootNode nodesForXPath:[EdlineXPath xPathForKey:@"ActivityItems"]]) {
		CLS_LOG(@"activity");
		[Flurry logEvent:@"view_activity_list"];
		return [[EdlineActivityList alloc] initWithRequestOperation:operation
												  andResponseObject:responseObject];
	}
	else if([doc.rootNode nodesForXPath:[EdlineXPath xPathForKey:@"CalItems"]]) {
		CLS_LOG(@"calendar");
		[Flurry logEvent:@"view_calendar"];
		return [[EdlineEventList alloc] initWithRequestOperation:operation
											   andResponseObject:responseObject];
	}
	else if([doc.rootNode nodesForXPath:[EdlineXPath xPathForKey:@"ListItems"]]) {
		CLS_LOG(@"list");
		[Flurry logEvent:@"view_list"];
		return [[EdlineList alloc] initWithRequestOperation:operation
										  andResponseObject:responseObject];
	}
	else if([doc.rootNode nodesForXPath:[EdlineXPath xPathForKey:@"TabContentsItem"]]) {
		CLS_LOG(@"tab_contents");
		[Flurry logEvent:@"view_contents_tab"];
		return [[EdlineTabbedPage alloc] initWithRequestOperation:operation
												andResponseObject:responseObject];
	}
	else if([doc.rootNode nodesForXPath:[EdlineXPath xPathForKey:@"ListDocItems"]]) {
		CLS_LOG(@"doc_items");
		[Flurry logEvent:@"view_document_list"];
		return [[EdlineDocList alloc] initWithRequestOperation:operation
											 andResponseObject:responseObject];
	}
	else if([doc.rootNode nodeForXPath:[EdlineXPath xPathForKey:@"IFrameItem"]]){
		CLS_LOG(@"iframe");
		[Flurry logEvent:@"view_iframe"];
		return [[EdlineIframe alloc] initWithRequestOperation:operation
											andResponseObject:responseObject];
	}
	else if([doc.rootNode.description rangeOfString:@"There are currently no reports."].location != NSNotFound) {
		CLS_LOG(@"no_reports");
		[Flurry logEvent:@"view_no_reports"];
		return nil;
	}
	else if([doc.rootNode.description rangeOfString:@"There are currently no feed items."].location != NSNotFound) {
		CLS_LOG(@"no_feed");
		[Flurry logEvent:@"view_no_feed"];
		return nil;
	}
	else if([doc.rootNode.description rangeOfString:@"There is currently empty."].location != NSNotFound) {
		CLS_LOG(@"no_items");
		[Flurry logEvent:@"view_no_items"];
		return nil;
	}
	
	CLS_LOG(@"unhandled: %@", [[NSString alloc] initWithData:responseObject
													encoding:NSUTF8StringEncoding]);
	
	return nil;
}

- (EdlineListItem *)activityFeedItem {
	EdlineListItem *item = [[EdlineListItem alloc] init];
	item.text = @"Activity";
	item.url = @"javascript:submitEvent('viewAsPicker', 'TCNK=mobileHelper;mode=ActivityFeed');";
	
	return item;
	
}

- (EdlineListItem *)privateReportsItem {
	EdlineListItem *item = [[EdlineListItem alloc] init];
	item.text = @"Activity";
	item.url = @"javascript:submitEvent('viewAsPicker', 'TCNK=mobileHelper;mode=PrivateReports');";
	
	return item;
}

- (void) getPath:(NSString *)path
      ifModified:(NSString *)ifModified
   handleCookies:(BOOL) handleCookies
         referer:(NSString *)referer
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self getPath:path
       ifModified:ifModified
    handleCookies:handleCookies
          referer:referer
       parameters:nil
          success:success
          failure:failure
         progress:nil];
}

- (void) getPath:(NSString *)path
      ifModified:(NSString *)ifModified
   handleCookies:(BOOL) handleCookies
         referer:(NSString *)referer
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self getPath:path
       ifModified:ifModified
    handleCookies:handleCookies
          referer:referer
       parameters:nil
          success:success
          failure:failure
         progress:nil];
}

- (void) getPath:(NSString *)path
      ifModified:(NSString *)ifModified
   handleCookies:(BOOL) handleCookies
         referer:(NSString *)referer
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
        progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
{
    
    NSAssert(path != nil && path.length > 0, @"empty path");
    
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    
    [request setHTTPShouldHandleCookies: handleCookies];
    
    if (referer)
        [request addValue:referer forHTTPHeaderField:@"Referer"];
    
    if (ifModified) {
        [request setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
        [request addValue:ifModified forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    
    if (progress) {
        operation.downloadProgressBlock = progress;
    }
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)postPath:(NSString *)path
         referer:(NSString *)referer
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self postPath:path
           referer:referer
        parameters:parameters
          redirect:YES
           success: success
           failure:failure];
}

- (void)postPath:(NSString *)path
         referer:(NSString *)referer
      parameters:(NSDictionary *)parameters
        redirect:(BOOL)redirect
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    
    [request setHTTPShouldHandleCookies: YES];
    
    if (referer)
        [request addValue:referer forHTTPHeaderField:@"Referer"];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    
    [self enqueueHTTPRequestOperation:operation];
}


- (void) cancelAll
{
    for (NSOperation *operation in [self.operationQueue operations]) {
        if ([operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            [operation cancel];
        }
    }
}

@end

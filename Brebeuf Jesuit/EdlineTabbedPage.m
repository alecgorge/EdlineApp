//
//  EdlineTabbedPage.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineTabbedPage.h"

@implementation EdlineTabbedPage

- (NSString *)title {
	if(!_title) {
		HTMLNode *node = [self.document.rootNode nodeForXPath:[EdlineXPath xPathForKey:@"TabTitle"]];
		_title = node.textContent;
	}
	
	return _title;
}

- (BOOL)hasContents {
	return YES;
}

- (BOOL)hasEvents {
	return [self.response rangeOfString:@"There are currently no events."].location == NSNotFound;
}

- (BOOL)hasNews {
	return [self.response rangeOfString:@"There is currently no news."].location == NSNotFound;
}

- (EdlineListItem *)newsItem {
	if(self.hasNews) {
		if(!_newsItem) {
			NSError *err = nil;
			
			HTMLNode *node = [self.document.rootNode nodeForXPath:[EdlineXPath xPathForKey:@"TabNewsItem"]
															error:&err];
			
			_newsItem = [[EdlineListItem alloc] initWithHTMLNode:node];
			_newsItem.eventOperation = self.operation;
		}
		
		return _newsItem;
	}
	
	return nil;
}

- (EdlineListItem *)eventsItem {
	if(self.hasEvents) {
		if(!_eventsItem) {
			HTMLNode *node = [self.document.rootNode nodeForXPath:[EdlineXPath xPathForKey:@"TabCalendarItem"]];
			_eventsItem = [[EdlineListItem alloc] initWithHTMLNode:node];
			_eventsItem.eventOperation = self.operation;
		}
		
		return _eventsItem;
	}
	
	return nil;
}

- (EdlineListItem *)contentsItem {
	if(self.hasContents) {
		if(!_contentsItem) {
			HTMLNode *node = [self.document.rootNode nodeForXPath:[EdlineXPath xPathForKey:@"TabContentsItem"]];
			_contentsItem = [[EdlineListItem alloc] initWithHTMLNode:node];
			_contentsItem.eventOperation = self.operation;
		}
		
		return _contentsItem;
	}
	
	return nil;
}

@end

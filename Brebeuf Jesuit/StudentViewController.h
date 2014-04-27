//
//  StudentViewController.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/12/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentViewController : UITableViewController {
	NSString *studentId;
}

@property (nonatomic) NSArray *classes;

- (id)initWithStudentName:(NSString *)name studentID:(NSString *)studentId;

@end

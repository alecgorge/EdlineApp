//
//  EdlineLoginViewController.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EdlineLoginDelegate <NSObject>

- (void)didSignIn;

@end

@interface EdlineLoginViewController : UITableViewController<UITextFieldDelegate>

- (instancetype)initWithDelegate:(id<EdlineLoginDelegate>)delegate;

@property (weak, nonatomic) id<EdlineLoginDelegate> delegate;

@end

//
//  EdlineLoginViewController.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 10/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "EdlineLoginViewController.h"

#import <FXKeychain/FXKeychain.h>

typedef enum {
	kEdlineLoginRowUsername,
	kEdlineLoginRowPassword,
} kEdlineLoginRows;

@interface EdlineLoginViewController ()

@property (nonatomic) UITextField *username;
@property (nonatomic) UITextField *password;

@end

@implementation EdlineLoginViewController

- (instancetype)initWithDelegate:(id<EdlineLoginDelegate>)delegate {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		self.title = @"Edline";
		self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.username = [[UITextField alloc] initWithFrame:CGRectMake(15, 7, self.tableView.bounds.size.width, 30)];
	self.username.autocorrectionType = UITextAutocorrectionTypeNo;
	self.username.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.username.placeholder = @"Username";
	self.username.returnKeyType = UIReturnKeyNext;
	self.username.delegate = self;
	
	self.password = [[UITextField alloc] initWithFrame:CGRectMake(15, 7, self.tableView.bounds.size.width, 30)];
	self.password.autocorrectionType = UITextAutocorrectionTypeNo;
	self.password.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.password.secureTextEntry = YES;
	self.password.placeholder = @"Password";
	self.password.returnKeyType = UIReturnKeyDone;
	self.password.delegate = self;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign In"
																			  style:UIBarButtonItemStyleDone
																			 target:self
																			 action:@selector(signIn:)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField == self.username) {
		[textField resignFirstResponder];
		[self.password becomeFirstResponder];
	}
	else {
		[self signIn:nil];
	}
	
	return NO;
}

- (void)cancel {
	[self.navigationController dismissViewControllerAnimated:YES
												  completion:nil];
}

- (void)signIn:(id)sender {
	if(self.username.text.length > 0 && self.password.text.length > 0) {
		[FXKeychain defaultKeychain][@"u"] = self.username.text;
		[FXKeychain defaultKeychain][@"p"] = self.password.text;
		
		[self.delegate didSignIn];
		[self cancel];
	}
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
												   reuseIdentifier:@"Cell"];
	
	if(indexPath.row == kEdlineLoginRowUsername) {
		[cell addSubview:self.username];
	}
	else if(indexPath.row == kEdlineLoginRowPassword) {
		[cell addSubview:self.password];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section {
	return @"Your login information is not sent to any 3rd-party servers. It is only stored on your device and transferred to Edline's servers in an encrypted fashion.\n\nYou need to have a working Edline account for this to work. You can only use this app if you have signed into your Edline account at least once via edline.net.";
}

@end

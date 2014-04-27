//
//  LoginViewController.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/12/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithMain:(MainScreenViewController *)main {
	if(self = [super initWithStyle: UITableViewStyleGrouped]) {
		toRefresh = main;
		self.tableView.allowsSelection = NO;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Log In";
	
	UIBarButtonItem *logIn = [[UIBarButtonItem alloc] initWithTitle:@"Log In"
															  style:UIBarButtonItemStyleDone
															 target:self
															 action:@selector(logInPressed:)];
	
	self.navigationItem.rightBarButtonItem = logIn;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"input_cell"];
	
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:@"input_cell"];
	} 
	
	UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 40)];
	field.autocapitalizationType = UITextAutocapitalizationTypeNone;
	field.autocorrectionType = UITextAutocorrectionTypeNo;
	field.placeholder = indexPath.row == 0 ? @"Username" : @"Password";
	field.secureTextEntry = indexPath.row;
	field.tag = indexPath.row;
	field.delegate = self;
	
	[cell.contentView addSubview:field];
	
	if(indexPath.row == 0) {
		[field becomeFirstResponder];
	}
	
	return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if(textField.tag == 0) {
		[EdlineUser currentUser].username = textField.text;
	}
	else {
		[EdlineUser currentUser].password = textField.text;
	}
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section {
	return @"Your login information is not sent to any 3rd-party servers. It is only stored on your device and transferred to Edline's servers in an encrypted fashion.";
}
- (void)logInPressed:(id)sender {
	[self.view endEditing:YES];
	
	[[EdlineUser currentUser] saveCredentials];
	
	[self.navigationController dismissModalViewControllerAnimated: YES];
	[toRefresh triggerPullToRefresh];
}
@end

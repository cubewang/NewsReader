//
//  PasswordViewController_iPad.h
//  EnglishFun
//
//  Created by cg on 12-8-7.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface PasswordViewController_iPad : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITextField *newPasswordTextField;
    UITextField *confirmPasswordTextField;
}

@property (nonatomic, retain) UITextField *newPasswordTextField;
@property (nonatomic, retain) UITextField *confirmPasswordTextField;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *completeButton;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;

- (IBAction)savePassword;
- (IBAction)closeAction:(id)sender;

@end
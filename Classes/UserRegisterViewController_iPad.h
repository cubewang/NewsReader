//
//  UserRegisterViewController_iPad.h
//  EnglishFun
//
//  Created by cg on 12-8-3.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserRegisterViewController.h"

@interface UserRegisterViewController_iPad : UIViewController<UITextFieldDelegate,
iKnowXMPPRegisterDelegate,RegisterViewControllerResultDelegate> {
    
    UIActivityIndicatorView *activityIndicator;
    
    //界面元素
    UITextField *emailTextField;
    UITextField *nickNameTextField;
    UITextField *passwordTextField;
    
    
    IBOutlet UITableView *emailPromptTableView;
    IBOutlet UIImageView *emailPromptBgView;
    NSArray *emailArray;
    
    IBOutlet UINavigationBar *navBar;
    id resultDelegate;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UITextField *nickNameTextField;

@property (nonatomic, retain) IBOutlet UITableView *emailPromptTableView;
@property (nonatomic, retain) IBOutlet UIImageView *emailPromptBgView;
@property (nonatomic, retain) IBOutlet UILabel *registerLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIButton *backButton;

@property (nonatomic, assign) id resultDelegate;
@property (nonatomic, retain) UINavigationBar *navBar;

- (IBAction)closeAction:(id)sender;
- (IBAction)registerUserAction:(id)sender;

@end

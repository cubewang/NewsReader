//
//  UserLoginViewController_iPad.h
//  EnglishFun
//
//  Created by cg on 12-8-3.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserLoginViewController_iPad : UIViewController<UITextFieldDelegate> {
    
    UIActivityIndicatorView *activityIndicator;
    
    //界面元素
    UITextField *emailTextField;
    UITextField *passwordTextField;
    
    UIButton *registerButton;
    UITableView *emailPromptTableView;
    UIImageView *emailPromptBgView;
    
    NSArray *emailArray;
    IBOutlet UINavigationBar *navBar;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

@property (nonatomic, retain) IBOutlet UIButton *registerButton;
@property (nonatomic, retain) IBOutlet UITableView *emailPromptTableView;
@property (nonatomic, retain) IBOutlet UIImageView *emailPromptBgView;
@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIButton *backItem;
@property (nonatomic, retain) IBOutlet UILabel *loginButtonLabel;
@property (nonatomic, retain) IBOutlet UILabel *registerButtonLabel;

- (IBAction)close:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)registerUser:(id)sender;

@end

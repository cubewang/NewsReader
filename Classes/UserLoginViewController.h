//
//  UserLoginViewController.h
//  iKnow
//
//  Created by 何京涛 on 11-7-5.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserRegisterViewController.h"

@interface UserLoginViewController : UIViewController <UITextFieldDelegate> {
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

- (IBAction)close:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)registerUser:(id)sender;

@end
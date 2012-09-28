//
//  UserRegisterViewController.h
//
//  Created by 何京涛 on 11-6-30.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol RegisterViewControllerResultDelegate <NSObject>
@optional
- (void)RegisterViewControllerResult:(BOOL)bRegistered;
@end

@interface UserRegisterViewController: UIViewController <UITextFieldDelegate,
                iKnowXMPPRegisterDelegate> 
{
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

@property (nonatomic, assign) id resultDelegate;
@property (nonatomic, retain) UINavigationBar *navBar;

- (IBAction)closeAction:(id)sender;
- (IBAction)registerUserAction:(id)sender;

@end

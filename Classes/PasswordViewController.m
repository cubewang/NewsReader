//
//  ChangePasswordViewController.m
//  EnglishFun
//
//  Created by cg on 12-8-15.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import "PasswordViewController.h"
#import "XMPPiKnowUserModule.h"
#import "ArticleDownloader.h"
#import "MessageManager.h"

@implementation PasswordViewController

@synthesize newPasswordTextField;
@synthesize confirmPasswordTextField;
@synthesize tableView;
@synthesize backButton,completeButton;
@synthesize navBar;

- (XMPPiKnowUserModule *)getUserModule
{
    return[[[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient] xmppiKnowUserModule];
}

- (IBAction)closeAction:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)savePassword
{
    if ([newPasswordTextField.text length] == 0
        || [confirmPasswordTextField.text length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:NSLocalizedString(@"提示", @"")
                                  message:NSLocalizedString(@"密码不能为空", @"")
                                  delegate:self 
                                  cancelButtonTitle:NSLocalizedString(@"确定", @"")
                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        return;
    }
    
    //验证密码长度，密码有可能为空
    if ((newPasswordTextField.text.length > 0 && newPasswordTextField.text.length < PASSWORD_MIN_LENGTH) || newPasswordTextField.text.length > PASSWORD_MAX_LENGTH) {
        
        
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:NSLocalizedString(@"提示", @"")
                                  message:[NSString stringWithFormat:NSLocalizedString(@"密码长度需要在%d～%d之间", @""), PASSWORD_MIN_LENGTH, PASSWORD_MAX_LENGTH]                                  delegate:self 
                                  cancelButtonTitle:NSLocalizedString(@"确定", @"")
                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        return;
    }
    
    //验证密码与确认密码是否一致
    if (![newPasswordTextField.text isEqualToString:confirmPasswordTextField.text] && ![confirmPasswordTextField.text isEqualToString:@""]) {
        
        
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:NSLocalizedString(@"提示", @"")
                                  message:NSLocalizedString(@"两次输入的密码不一致", @"")
                                  delegate:self 
                                  cancelButtonTitle:NSLocalizedString(@"确定", @"")
                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        BOOL bRes = [[self getUserModule] changePassword:newPasswordTextField.text];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSString *message = bRes ? NSLocalizedString(@"修改密码成功", @"") : NSLocalizedString(@"修改密码失败", @"");
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil 
                                                           message:message   
                                                          delegate:nil 
                                                 cancelButtonTitle:NSLocalizedString(@"确定", @"")
                                                 otherButtonTitles:nil     
                                 ];
            [view show];
            [view release];
            
        });
    });
    
    [self closeAction:nil];
}
/*
 - (id)initWithStyle:(UITableViewStyle)style
 {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 self = [super initWithStyle:UITableViewStyleGrouped];
 if (self) {
 // Custom initialization.
 }
 return self;
 }*/

- (void)viewDidLoad
{   
    [super viewDidLoad];
    
    [self.backButton setTitle:NSLocalizedString(@"返回", @"") forState:UIControlStateNormal];
    [self.completeButton setTitle:NSLocalizedString(@"保存", @"") forState:UIControlStateNormal];
    
    self.navBar.tintColor = NAV_BAR_ITEM_COLOR;
    if ([self.navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [ self.navBar setBackgroundImage:[UIImage imageNamed:@"settingBar_ipad.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.navBar.layer.shadowRadius = 3.0f;
    self.navBar.layer.shadowOpacity = 0.8f;
    
    self.view.backgroundColor = self.tableView.backgroundColor = CELL_BACKGROUND;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.userInteractionEnabled = YES;
    self.tableView.alpha = 1;
}


- (void)dealloc
{
    [newPasswordTextField release];
    [confirmPasswordTextField release];
    [[ArticleDownloader shareInstance] cancel];
    
    self.backButton = nil;
    self.completeButton = nil;
    self.navBar = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SettingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        CGRect rc = cell.frame;
        rc.size.width -= 50;
        rc.origin.x += 10;
        rc.origin.y += 5;
        
        if (indexPath.row == 0) {
            self.newPasswordTextField = [[UITextField alloc] initWithFrame:rc];
            self.newPasswordTextField.placeholder = NSLocalizedString(@"密码", @"");
            self.newPasswordTextField.secureTextEntry = YES;
            [cell.contentView addSubview:newPasswordTextField];
        }
        else if (indexPath.row == 1){
            self.confirmPasswordTextField = [[UITextField alloc] initWithFrame:rc];
            self.confirmPasswordTextField.placeholder = NSLocalizedString(@"确认密码", @"");
            self.confirmPasswordTextField.secureTextEntry = YES;
            [cell.contentView addSubview:confirmPasswordTextField];
        }
    }
    
    return cell;
}


@end




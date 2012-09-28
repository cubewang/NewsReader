//
//  UserRegisterViewController.m
//
//  Created by 何京涛 on 11-6-30.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "UserRegisterViewController.h"
#import "iKnowXMPPClient.h"
#import "NSObject+ZResult.h"

@implementation UserRegisterViewController

@synthesize activityIndicator, resultDelegate;
@synthesize navBar;

@synthesize nickNameTextField;
@synthesize passwordTextField;
@synthesize emailTextField;

- (IBAction)closeAction:(id)sender
{
    BOOL bAnimation = sender != nil;
    
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        
        if (self.presentedViewController) {
            [[self presentedViewController] dismissModalViewControllerAnimated:bAnimation];
        }
        else {
            [self dismissModalViewControllerAnimated:bAnimation];
        }
    }
    else {
        [[self parentViewController] dismissModalViewControllerAnimated:bAnimation];
    }  
}

- (void)loginFinished 
{
    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] 
        hidePopProgress:YES andText:IKNOW_XMPP_REGISTER_SUCCESSED_TEXT];
    
     [self closeAction:nil];
    
    if ([resultDelegate respondsToSelector:@selector(RegisterViewControllerResult:)])
        [resultDelegate RegisterViewControllerResult:YES];
}

- (void)registerFinished {
    
    NSString *regstr = NSLocalizedString(@"注册成功",@"");
    NSString *loadingstr = NSLocalizedString(@"登录中...",@"");
    NSString *noticestr = [NSString stringWithFormat:@"%@,%@",regstr,loadingstr];
    
    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] 
     changePopProgress:noticestr];
}

- (void)registerError:(NSString *)errorStr {

    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] 
     hidePopProgress:NO andText:[errorStr length] ? errorStr : 
        IKNOW_REGISTER_FAILED_TEXT];
}

- (IBAction)registerUserAction:(id)sender
{
    //验证邮箱格式
    if (![StringUtils isEmailAddress:emailTextField.text]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:NSLocalizedString (@"提示",@"")
                                  message:NSLocalizedString (@"您填写的邮箱格式不对",@"")
                                  delegate:self 
                                  cancelButtonTitle:NSLocalizedString (@"确定",@"")
                                  otherButtonTitles:nil];

        [alertView show];
        [alertView release];
        
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] 
         hidePopProgress:NO andText:IKNOW_REGISTER_FAILED_TEXT];
        
        return;  
    }
    
    [emailTextField resignFirstResponder];
    //向服务器提交信息
    
    iKnowXMPPClient *xmppClient = [[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient];
    BOOL bRes = [xmppClient registerUserWithEmail:emailTextField.text 
                                      andPassword:passwordTextField.text 
                                      andNickName:nickNameTextField.text];
    
    if (bRes) {
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] 
         showPopProgress:nil andText:IKNOW_WILL_REGISTER_TEXT];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:NSLocalizedString (@"提示",@"")
                                  message:IKNOW_XMPP_WAIT 
                                  delegate:self 
                                  cancelButtonTitle:NSLocalizedString (@"确定",@"")
                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }

}

/* ###################
 
    UITextFieldDelegate回调
 
   ###################
 */
//判断邮箱输入长度
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    //判断邮箱是否太长
    if (textField == emailTextField && textField.text.length >= EMAIL_MAX_LENGTH && range.length == 0) {
        return NO;
    }
    
    if (textField == emailTextField) {
        
        if ([string isEqual:@"@"]) {
            emailPromptTableView.hidden = YES;
            emailPromptBgView.hidden = YES;
            return YES;
        }
        
        NSString *str = textField.text;
        NSRange range2 = [str rangeOfString:@"@"];
        
        if (range2.location == NSNotFound) {
            emailPromptTableView.hidden = NO;
            emailPromptBgView.hidden = NO;
            [emailPromptTableView reloadData];
        }
        else {
            emailPromptTableView.hidden = YES;
            emailPromptBgView.hidden = YES;
        }
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    emailPromptTableView.hidden = YES;
    emailPromptBgView.hidden = YES;
}

//用户按下完成按钮后隐藏键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self registerUserAction:nil];
    return YES;
}


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [emailArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"emailPromptCell2";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = LIGHT_TEXT_COLOR;
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", emailTextField.text, [emailArray objectAtIndex:indexPath.row]];
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    emailTextField.text = [NSString stringWithFormat:@"%@%@", emailTextField.text, [emailArray objectAtIndex:indexPath.row]];
    tableView.hidden = YES;
    emailPromptBgView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([EnglishFunAppDelegate setNavImage:@"NavBar_ios5.png"]){
        [self.navBar setNeedsDisplay];
    }
    
    iKnowXMPPClient *xmppClient = [[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient];
    xmppClient.xmppViewRegisterDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    iKnowXMPPClient *xmppClient = [[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient];
    xmppClient.xmppViewRegisterDelegate = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [emailTextField becomeFirstResponder];
}

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
     [super viewDidLoad];
     
     self.navBar.tintColor = NAV_BAR_ITEM_COLOR;
     if ([self.navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
         [ self.navBar setBackgroundImage:[UIImage imageNamed:@"NavBar_ios5.png"] forBarMetrics:UIBarMetricsDefault];
     }
     
     self.navBar.layer.shadowColor = [[UIColor blackColor] CGColor];
     self.navBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
     self.navBar.layer.shadowRadius = 3.0f;
     self.navBar.layer.shadowOpacity = 0.8f;
     
     if (emailArray == nil) {
         emailArray = [[NSArray alloc] initWithObjects:@"@qq.com",
                       @"@gmail.com", @"@163.com", @"@126.com" ,@"@sina.com", 
                       @"@sohu.com", @"@hotmail.com", nil];
     }
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    iKnowXMPPClient *xmppClient = [[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient];
    xmppClient.xmppViewRegisterDelegate = nil;
    
    self.nickNameTextField = nil;
    self.passwordTextField = nil;
    self.emailTextField = nil;
    
    self.activityIndicator = nil;
    
    [emailPromptTableView release];
    [emailPromptBgView release];
    [emailArray release];
    [navBar release];
    
    [super dealloc];
}


@end

    //
//  UserLoginViewController.m
//  iKnow
//
//  Created by 何京涛 on 11-7-5.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "UserLoginViewController.h"
#import "iKnowXMPPClient.h"
#import "XMPPiKnowUserModule.h"


@implementation UserLoginViewController


@synthesize activityIndicator;
@synthesize emailTextField, passwordTextField, registerButton, 
    emailPromptTableView, emailPromptBgView;

@synthesize navBar;

- (XMPPiKnowUserModule *)getUserModule
{
    return [[[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient] xmppiKnowUserModule];
}

- (IBAction)close:(id)sender
{
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        
        if (self.presentedViewController) {
            [[self presentedViewController] dismissModalViewControllerAnimated:YES];
        }
        else {
            [self dismissModalViewControllerAnimated:YES];
        }
    }
    else {
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
    }
}

- (void)_login
{
    iKnowXMPPClient *xmppClient = [[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient];
    
    BOOL bRes = NO;
    if ([iKnowXMPPClient isOfficialName:emailTextField.text]) {
        bRes = [xmppClient loginAdministrator:emailTextField.text 
                                  andPassword:passwordTextField.text];
    }
    else {
        bRes = [xmppClient loginWithEmail:emailTextField.text 
                              andPassword:passwordTextField.text];
    }

    if (bRes) 
    {
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] 
         showPopProgress:self.view.window andText:IKNOW_WILL_LOGIN_TEXT];
    }
    else 
    {
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

//用户登录
- (IBAction)login:(id)sender
{
    //验证邮箱格式
    if (![StringUtils isEmailAddress:emailTextField.text]) {
        
        if (![iKnowXMPPClient isOfficialName:emailTextField.text]) {
            UIAlertView *alertView = [[UIAlertView alloc] 
                                      initWithTitle:NSLocalizedString (@"提示",@"")
                                      message:NSLocalizedString (@"您填写的邮箱格式不对",@"")
                                      delegate:nil 
                                      cancelButtonTitle:NSLocalizedString (@"确定",@"")
                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            
            return;
        }
        else {
            [passwordTextField resignFirstResponder];
            [emailTextField resignFirstResponder];
            
            return [self _login];
        }
    }
    //官方账户，我们直接忽略掉用户名邮箱判断,密码长度限制
        
    //验证密码长度，密码有可能为空
    if ((passwordTextField.text.length > 0 && passwordTextField.text.length < PASSWORD_MIN_LENGTH) || passwordTextField.text.length > PASSWORD_MAX_LENGTH) {
            
        UIAlertView *alertView = [[UIAlertView alloc] 
                                    initWithTitle:NSLocalizedString (@"提示",@"")
                                    message:[NSString stringWithFormat:NSLocalizedString (@"密码长度需要在%d～%d之间",@""), PASSWORD_MIN_LENGTH, PASSWORD_MAX_LENGTH]                                  
                                    delegate:nil 
                                    cancelButtonTitle:NSLocalizedString (@"确定",@"")
                                    otherButtonTitles:nil];
        [alertView show];
        [alertView release];
            
        return;
    }
    
    [passwordTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    
    [self _login];
}

- (IBAction)registerUser:(id)sender {
    
    UserRegisterViewController *viewController = [[UserRegisterViewController alloc] init];
    viewController.resultDelegate = self;
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
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
    //判断密码是否太长
    if (textField == passwordTextField && textField.text.length >= PASSWORD_MAX_LENGTH && range.length == 0) {
        return NO;
    }
    
    if (emailPromptTableView == nil) {
        //CGRect rc = [self.view convertRect:emailTextField.frame fromView:emailTextField];
        CGRect rc = emailTextField.frame;
        rc.size.height = 150;
        rc.origin.x = emailTextField.frame.origin.x;
        rc.origin.y = rc.origin.y + 40;
        rc.size.width -= 10;
        rc.size.height -= 10;
        
        emailPromptTableView = [[UITableView alloc] initWithFrame:rc style:UITableViewStylePlain];
        emailPromptTableView.delegate = self;
        emailPromptTableView.dataSource = self;
        
        if (emailPromptBgView == nil) {
            CGRect rc = emailPromptTableView.frame;
            rc.origin.x -= 10;
            rc.size.width += 20;
            rc.origin.y -= 10;
            rc.size.height += 20;
            
            emailPromptBgView = [[UIImageView alloc] initWithFrame:rc];
            emailPromptBgView.image = [UIImage imageNamed:@"img_grid_bg.png"];
            [self.view addSubview:emailPromptBgView];
        }
        //emailPromptTableView.backgroundView = emailPromptBgView;  
        emailPromptTableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:emailPromptTableView];
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

-(void) BubbleTableViewBeginTouches{
    emailPromptTableView.hidden = YES;
    emailPromptBgView.hidden = YES;
    
    [emailTextField resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    emailPromptTableView.hidden = YES;
    emailPromptBgView.hidden = YES;
    
    [emailTextField resignFirstResponder];
}

//用户按下完成按钮后隐藏键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:emailTextField]) {
        [passwordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:passwordTextField]){
        [self login:nil];
    }
    
    return YES;
}

- (void)RegisterViewControllerResult:(BOOL)bRegistered {
    if (bRegistered) {
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:NSLocalizedString (@"提示",@"")
                                  message:NSLocalizedString (@"注册成功",@"")
                                  delegate:nil 
                                  cancelButtonTitle:NSLocalizedString (@"确定",@"")
                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        [self close:nil];
    }
}

- (void)loginFinished {
    
    [self close:nil];
    
    //请求完整的用户个人信息在用户第一次登录时
    [[self getUserModule] queryUserInfoSync];
    
    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] 
     hidePopProgress:YES andText:NSLocalizedString (@"登录成功",@"")];
}

- (void)loginError:(NSString *)errorStr 
{    
    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] 
     hidePopProgress:NO andText:[errorStr length] ? errorStr : NSLocalizedString (@"登录失败",@"")];
}

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
    
    static NSString *CellIdentifier = @"emailPromptCell";
    
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    emailTextField.text = [NSString stringWithFormat:@"%@%@", emailTextField.text, [emailArray objectAtIndex:indexPath.row]];
    tableView.hidden = YES;
    emailPromptBgView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([EnglishFunAppDelegate setNavImage:@"NavBar.png"]){
        [self.navBar setNeedsDisplay];
    }
    
    [[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient].xmppViewLoginDelegate = self;
    [emailTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient].xmppViewLoginDelegate = nil;
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
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.emailTextField = nil;
    self.passwordTextField = nil;
    
    self.emailPromptBgView = nil;
    self.emailPromptTableView = nil;
}


- (void)dealloc {
    [[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient].xmppViewLoginDelegate = nil;
    
    [emailTextField release];
    [passwordTextField release];
    [registerButton release];
    self.activityIndicator = nil;
    
    self.emailPromptTableView = nil;
    self.emailPromptBgView = nil;
    
    [navBar release];
    [emailArray release];
    [super dealloc];
}


@end

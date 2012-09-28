//
//  SearchWebViewController.m
//  iKnow
//
//  Created by cg on 12-4-11.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import "SearchWebViewController.h"

#define GOOGLE_SEARCH @"http://www.google.com/search?q="
#define BAIDU_SEARCH @"http://www.baidu.com/s?wd="

#define ACTIVITYVIEWX 280
#define ACTIVITYVIEWY 12
#define ACTIVITYVIEWWEIGHT 20
#define ACTIVITYVIEWHEIGHT 20

@implementation SearchWebViewController

@synthesize searchWebView;
@synthesize navigationBar;
@synthesize contentUrl;
@synthesize goBackButton;
@synthesize goForwardButton;
@synthesize safariUrl;
@synthesize refreshButton;

- (void)dealloc {
    
    [searchWebView release];
    [navigationBar release];
    [contentUrl release];
    [activityIndictorView release];
    [goBackButton release];
    [goForwardButton release];
    [safariUrl release];
    [refreshButton release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    searchWebView.scalesPageToFit = YES;
    self.searchWebView.delegate = self;
    
    NSString *stringurl = [contentUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:stringurl];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [searchWebView loadRequest:request];  
    
    [request release];
    
    self.navigationBar.tintColor = NAV_BAR_ITEM_COLOR;
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar_ios5.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    activityIndictorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndictorView.frame = CGRectMake(
                                            ACTIVITYVIEWX, 
                                            ACTIVITYVIEWY, 
                                            ACTIVITYVIEWWEIGHT, 
                                            ACTIVITYVIEWHEIGHT);
    activityIndictorView.hidden = YES;
    activityIndictorView.backgroundColor = [UIColor clearColor];
    activityIndictorView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:activityIndictorView];
    
    self.goBackButton.enabled = NO;
    self.goForwardButton.enabled = NO;
    self.refreshButton.enabled = NO;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.searchWebView = nil;
    self.navigationBar = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Action

- (IBAction)back:(id)sender {
    
    [self.searchWebView stopLoading];
    
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        
        if (self.presentedViewController) {
            [[self presentedViewController] dismissModalViewControllerAnimated:YES];
        }
        else {
            [self dismissModalViewControllerAnimated:YES];
        }
    } else {
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)goBack:(id)sender {
    
    [self.searchWebView goBack];
}

- (IBAction)goForward:(id)sender {
    
    [self.searchWebView goForward];
}

- (IBAction)refresh:(id)sender {
    
    [self.searchWebView reload];
}

- (IBAction)openSafair:(id)sender {
    UIActionSheet *action = [[UIActionSheet alloc] 
                             initWithTitle:nil
                             delegate:self 
                             cancelButtonTitle:NSLocalizedString(@"取消", @"")
                             destructiveButtonTitle:NSLocalizedString(@"用Safari打开", @"")
                             otherButtonTitles:nil];
    
    [action showInView:self.view];
    [action release];
}

#pragma mark UIActionSheetDelegate 

- (void) actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex { 

    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:safariUrl]];
    }
}

#pragma mark UIWebViewDelegate 

- (void)webViewDidStartLoad:(UIWebView *)webView {

    self.refreshButton.enabled = NO;
    
    activityIndictorView.hidden = NO;
    [activityIndictorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    self.refreshButton.enabled = YES;
    
    if (searchWebView.canGoForward ) {
        goForwardButton.enabled = YES;
    }else {
        goForwardButton.enabled = NO;
    }
    
    if (searchWebView.canGoBack ) {
        goBackButton.enabled = YES;
    }else {
        goBackButton.enabled = NO;
    }
    
    activityIndictorView.hidden = YES;
    [activityIndictorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    activityIndictorView.hidden = YES;
    [activityIndictorView stopAnimating];
    
    if ([[error localizedDescription] length] > 0) {
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:nil 
                                                                          info:NSLocalizedString(@"网络链接失败", @"")];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *href = [[request URL] absoluteString];
    self.safariUrl = href;
    
    return YES;
}

@end

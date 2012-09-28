//
//  ROWebNavigationViewController.m
//  RenrenSDKDemo
//
//  Created by xiawh on 11-11-14.
//  Copyright (c) 2011年 renren－inc. All rights reserved.
//
#import "ROWebDialogViewController.h"
#import "ROBaseDialogViewController.h"
#import "ROWebNavigationViewController.h"
#import "ROUtility.h"
#import "ROMacroDef.h"
#import "ROResponse.h"
@interface ROWebNavigationViewController(Private)

- (BOOL)isAuthDialog;
    
- (void)dismissWithError:(NSError*)error animated:(BOOL)animated;
    
- (void)dialogDidSucceed:(NSURL *)url;
    
- (void)dialogDidCancel:(NSURL *)url;

@end

@implementation ROWebNavigationViewController
@synthesize webView = _webView;
@synthesize serverURL = _serverURL;
@synthesize response = _response;
@synthesize params = _params;
@synthesize delegate = _delegate;
@synthesize indicatorView = _indicatorView;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)] autorelease];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.webView];
        //        [self.webView release];
        
        self.indicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        self.indicatorView.hidesWhenStopped = YES;
        self.indicatorView.center = self.webView.center;
        [self.view addSubview:self.indicatorView];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - UIWebViewDelegate Method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSString *query = [url fragment]; // url中＃字符后面的部分。
    if (!query) {
        query = [url query];
    }
    NSDictionary *params = [ROUtility parseURLParams:query];
    NSString *accessToken = [params objectForKey:@"access_token"];
    //    NSString *error_desc = [params objectForKey:@"error_description"];
    NSString *errorReason = [params objectForKey:@"error"];
    if(nil != errorReason) {
        [self dialogDidCancel:nil];
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked)/*点击链接*/{
        BOOL userDidCancel = ((errorReason && [errorReason isEqualToString:@"login_denied"])||[errorReason isEqualToString:@"access_denied"]);
        if(userDidCancel){
            [self dialogDidCancel:url];
        }else {
            NSString *q = [url absoluteString];
            if (![q hasPrefix:self.serverURL]) {
                [[UIApplication sharedApplication] openURL:request.URL];
            }
        }
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) {//提交表单
        NSString *state = [params objectForKey:@"flag"];
        if ((state && [state isEqualToString:@"success"])||accessToken) {
            [self dialogDidSucceed:url];
        }
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.indicatorView stopAnimating];
    //    self.cancelButton.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
        [self dismissWithError:error animated:YES];
    }
}

- (void)show
{
    [super show];
    
    [self.params setObject:kWidgetDialogUA forKey:@"ua"];
    
    NSURL *url = [ROUtility generateURL:self.serverURL params:self.params];
	NSLog(@"start load URL: %@", url);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [self.webView loadRequest:request];
    self.webView.delegate = self;
    [self.indicatorView startAnimating];
    
}

- (void)updateSubviewOrientation 
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [_webView stringByEvaluatingJavaScriptFromString:
         @"document.body.setAttribute('orientation', 90);"];
    } else {
        [_webView stringByEvaluatingJavaScriptFromString:
         @"document.body.removeAttribute('orientation');"];
    }
}

- (void)dialogDidSucceed:(NSURL *)url {
	NSString *q = [url absoluteString];
	if([self isAuthDialog]) {
        NSString *token = [ROUtility getValueStringFromUrl:q forParam:@"access_token"];
        NSString *expTime = [ROUtility getValueStringFromUrl:q forParam:@"expires_in"];
        NSDate   *expirationDate = [ROUtility getDateFromString:expTime];
        NSDictionary *responseDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:token,expirationDate,nil]
                                                                forKeys:[NSArray arrayWithObjects:@"token",@"expirationDate",nil]];
        self.response = [ROResponse responseWithRootObject:responseDic];
        
        if ((token == (NSString *) [NSNull null]) || (token.length == 0)) {
            [self dialogDidCancel:nil];
        } else {
            if ([self.delegate respondsToSelector:@selector(authDialog:withOperateType:)])  {
                [self.delegate authDialog:self withOperateType:RODialogOperateSuccess];
            }
        }
    }else {
        NSString *flag = [ROUtility getValueStringFromUrl:q forParam:@"flag"];	
        if ([flag isEqualToString:@"success"]) {
            NSString *query = [url fragment];
            if (!query) {
                query = [url query];
            }
            NSDictionary *params = [ROUtility parseURLParams:query];
            self.response = [ROResponse responseWithRootObject:params];
            if ([self.delegate respondsToSelector:@selector(widgetDialog:withOperateType:)]) {
                [self.delegate widgetDialog:self withOperateType:RODialogOperateSuccess];
            }
        }
    }
    [self close];
    
}

- (void)dismissWithError:(NSError*)error animated:(BOOL)animated {
    self.response = [ROResponse responseWithError:[ROError errorWithNSError:error]];
    if ([self isAuthDialog]) {
        if ([self.delegate respondsToSelector:@selector(authDialog:withOperateType:)]){
            [self.delegate authDialog:self withOperateType:RODialogOperateFailure];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(widgetDialog:withOperateType:)]) {
            
            [self.delegate widgetDialog:self withOperateType:RODialogOperateFailure];
        }
    }
    
    [self close];
}

- (void)dialogDidCancel:(NSURL *)url {
    if ([self isAuthDialog]) {
        if ([self.delegate respondsToSelector:@selector(authDialog:withOperateType:)]){
            [self.delegate authDialog:self withOperateType:RODialogOperateCancel];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(widgetDialog:withOperateType:)]){
            [self.delegate widgetDialog:self withOperateType:RODialogOperateCancel];
        }
    }
    
    [self close];
}

- (BOOL)isAuthDialog
{
    return [_serverURL isEqualToString:kAuthBaseURL];
}

- (void)selfChangeOption:(ROBaseNavigationViewController *)newController
{
    [newController otherChangeOption:self];
}

- (void)dealloc
{
    self.webView = nil;
    self.serverURL = nil;
    self.response = nil;
    self.params = nil;
    self.indicatorView = nil;
    [super dealloc];
}
@end

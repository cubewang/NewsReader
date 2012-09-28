//
//  CUSinaShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUSinaShareClient.h"
#import "ASIFormDataRequest.h"

#import "CUShareOAuthView.h"

#import "WBAuthorize.h"
#import "WBRequest.h"
#import "WBSDKGlobal.h"

#define kWBAuthorizeURL     @"https://api.weibo.com/oauth2/authorize"
#define kWBAccessTokenURL   @"https://api.weibo.com/oauth2/access_token"

//< For Sina
#define kSinaKeyCodeLead @"获取到的授权码"
#define kSinaPostImagePath @"http://api.t.sina.com.cn/statuses/upload.json"
#define kSinaPostPath @"http://api.t.sina.com.cn/statuses/update.json"

//view

@interface  CUSinaShareClient()

- (void)post:(NSString *)text andImage:(UIImage *)image;

@end

@implementation CUSinaShareClient

#pragma mark -  life

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if (self = [super init]) {
        if (engine == nil){
            engine = [[WBEngine alloc] initWithAppKey:theAppKey appSecret:theAppSecret];
            [engine setRootViewController:nil];
            [engine setDelegate:self];
            [engine setRedirectURI:@"http://"];
            [engine setIsUserExclusive:NO];            
            
            WBAuthorize *auth = [[WBAuthorize alloc] initWithAppKey:theAppKey 
                                                          appSecret:theAppSecret];
            [auth setRootViewController:nil];
            [auth setDelegate:engine];
            [auth setRedirectURI:engine.redirectURI];
            
            engine.authorize = auth;
            
            [auth release];
        }
    }
    
    return self;
}

- (void)dealloc
{
    engine.delegate = nil;
    [engine release];
    
    [super dealloc];
}

#pragma mark -  CUShareClientData

- (BOOL)isCUAuth
{
    return [engine isLoggedIn] && ![engine isAuthorizeExpired];
}

- (NSString *)requestToken
{
    if (![self isCUAuth]) {
        return nil;
    }
    
    return engine.accessToken;
}

- (void)CULogout
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    [engine logOut];
    return;
}

- (void)CUSendWithText:(NSString *)text
{
    return [self CUSendWithText:text andImage:nil];
}

- (void)CUSendWithText:(NSString *)text andImage:(UIImage *)image
{
    if ([text length] == 0) {
        return;
    }
    
    return [self post:text andImage:image];
}

//需要高级授权
- (void)CUSendWithText:(NSString *)text andImageURLString:(NSString *)imageURLString
{
    return [self post:text andImageURLString:imageURLString];
}

#pragma mark -  CUShareClient


- (NSURLRequest *)CULoginURLRequest
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:engine.appKey, @"client_id",
                            @"code", @"response_type",
                            engine.redirectURI, @"redirect_uri", 
                            @"mobile", @"display", nil];
    NSString *urlString = [WBRequest serializeURL:kWBAuthorizeURL
                                           params:params
                                       httpMethod:@"GET"];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];

    return request;
}

#pragma mark -  common method

- (void)post:(NSString *)text andImage:(UIImage *)image
{
    [engine sendWeiBoWithText:text image:image];
}

- (void)post:(NSString *)text andImageURLString:(NSString *)imageURLString
{
    if ([text length] == 0 && [imageURLString length] == 0) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    
	[params setObject:([text length] ? text : @"") forKey:@"status"];
	
    if ([imageURLString length] != 0)
    {
		[params setObject:imageURLString forKey:@"url"];
        
        [engine loadRequestWithMethodName:@"statuses/upload_url_text.json"
                               httpMethod:@"POST"
                                   params:params
                             postDataType:kWBRequestPostDataTypeMultipart
                         httpHeaderFields:nil];
    }
    else
    {
        [engine loadRequestWithMethodName:@"statuses/upload_url_text.json"
                               httpMethod:@"POST"
                                   params:params
                             postDataType:kWBRequestPostDataTypeMultipart
                         httpHeaderFields:nil];
    }
}

#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    UIActivityIndicatorView *indicatorView = [self.viewClient getActivityIndicatorView];;
    [indicatorView sizeToFit];
	[indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    UIActivityIndicatorView *indicatorView = [self.viewClient getActivityIndicatorView];
	[indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    UIActivityIndicatorView *indicatorView = [self.viewClient getActivityIndicatorView];
    [indicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
    
    if (range.location != NSNotFound)
    {
        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
        
        [engine.authorize authorizeWebView:nil didReceiveAuthorizeCode:code];
    }
    
    return YES;
}

#pragma mark -  WBEngineDelegate

// If you try to log in with logIn or logInUsingUserID method, and
// there is already some authorization info in the Keychain,
// this method will be invoked.
// You may or may not be allowed to continue your authorization,
// which depends on the value of isUserExclusive.
- (void)engineAlreadyLoggedIn:(WBEngine *)engine
{

}

// Log in successfully.
- (void)engineDidLogIn:(WBEngine *)engine
{
    [self CUNotifyAuthSucceed:self];
}

// Failed to log in.
// Possible reasons are:
// 1) Either username or password is wrong;
// 2) Your app has not been authorized by Sina yet.
- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
    [self CUNotifyAuthFailed:self withError:error];
}

// Log out successfully.
- (void)engineDidLogOut:(WBEngine *)engine
{
    
}

// When you use the WBEngine's request methods,
// you may receive the following four callbacks.
- (void)engineNotAuthorized:(WBEngine *)engine
{
    [self CUNotifyShareFailed:self withError:nil];
}

- (void)engineAuthorizeExpired:(WBEngine *)engine
{
    [self CUNotifyAuthFailed:self withError:nil];
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    [self CUNotifyShareFailed:self withError:error];
}

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    [self CUNotifyShareSucceed:self];
}

@end

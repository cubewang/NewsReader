//
//  CURenrenShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-14.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "SFHFKeychainUtils.h"
#import "CURenrenShareClient.h"
#import "ROMacroDef.h"
#import "ROUtility.h"

@class SFHFKeychainUtils;

#define kWBURLSchemePrefix              @"WB_renren_"

#define kWBKeychainServiceNameSuffix    @"_WeiBoServiceName_renren"
#define kWBKeychainUserID               @"WeiBoUserID_renren"
#define kWBKeychainAccessToken          @"WeiBoAccessToken_renren"
#define kWBKeychainExpireTime           @"WeiBoExpireTime_renren"
#define kWBKeychainSecret_Key           @"WeiBoSecretKEY_renren"

@interface CURenrenShareClient ()
@property (nonatomic, retain) NSMutableDictionary *sendParams;
@end

@implementation CURenrenShareClient
@synthesize sendParams;

#pragma mark -
#pragma mark viewController

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    self = [super init];
    if (self) {
        // Custom initialization
        renren = [[Renren sharedRenren] retain];
        renren.appId = theAppKey;
        renren.appKey = theAppSecret;
    }
    
    return self;
}

- (void)dealloc
{
    renren.renrenDelegate = nil;
    [renren release];
    [sendParams release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark CUShareClientData

- (BOOL)isCUAuth
{
    return [renren isSessionValid];
}

- (void)CULogout
{
    [renren logout:nil];
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

- (void)CUSendWithText:(NSString *)text andImageURLString:(NSString *)imageURLString
{
    return [self post:text andImageURLString:imageURLString];
}

#pragma mark -
#pragma mark CUShareClient

- (NSURLRequest *)CULoginURLRequest
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *serverURL = nil;
    
    if (![self isCUAuth]) {
        serverURL = kAuthBaseURL;
        
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* graphCookies = [cookies cookiesForURL:
                                 [NSURL URLWithString:@"http://graph.renren.com"]];
        
        for (NSHTTPCookie* cookie in graphCookies) {
            [cookies deleteCookie:cookie];
        }
        NSArray* widgetCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://widget.renren.com"]];
        
        for (NSHTTPCookie* cookie in widgetCookies) {
            [cookies deleteCookie:cookie];
        }
        if (![renren isSessionValid]) {
            renren.renrenDelegate = self;
            renren.permissions = [NSArray arrayWithObject:@"publish_feed"];
            
            [parameters setValue:renren.appKey forKey:@"client_id"];
            [parameters setValue:kRRSuccessURL forKey:@"redirect_uri"];
            [parameters setValue:@"token" forKey:@"response_type"];
            [parameters setValue:@"touch" forKey:@"display"];
            if (nil != renren.permissions) {
                NSString *permissionScope = [renren.permissions componentsJoinedByString:@","];
                [parameters setValue:permissionScope forKey:@"scope"];
            }
            
            [parameters setObject:kWidgetDialogUA forKey:@"ua"];
        }
    }
    else {
        //share
        serverURL = [kDialogBaseURL stringByAppendingString:@"feed"];
        [parameters setObject:renren.appKey forKey:@"app_id"];
        [parameters setObject:@"touch" forKey:@"display"];
        
        if ([parameters objectForKey:@"redirect_uri"] == nil) {
            [parameters setObject:kRRSuccessURL forKey:@"redirect_uri"];
        }
        
        if ([renren isSessionValid]) {
            [parameters setValue:[renren.accessToken stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                          forKey:@"access_token"];
        }
    }
    
    if ([serverURL length] == 0) {
        return nil;
    }
    
    NSURL *url = [ROUtility generateURL:serverURL params:parameters];
    NSLog(@"start load URL: %@", url);
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
    
    return request;
}

#pragma mark - UIWebViewDelegate Method

- (void)webViewDidStartLoad:(UIWebView *)webView {
    UIActivityIndicatorView *activeIndicator = [self.viewClient getActivityIndicatorView];
    [activeIndicator sizeToFit];
    [activeIndicator startAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSLog(@"%@", url);
    
    NSString *query = [url fragment]; // url中＃字符后面的部分。
    if (!query) {
        query = [url query];
    }
    NSDictionary *params = [ROUtility parseURLParams:query];
    NSString *accessToken = [params objectForKey:@"access_token"];
    //    NSString *error_desc = [params objectForKey:@"error_description"];
    NSString *errorReason = [params objectForKey:@"error"];
    if(nil != errorReason) {
        //[self dialogDidCancel:nil];
        [self CUNotifyShareCancel:self];
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked)/*点击链接*/{
        BOOL userDidCancel = ((errorReason && [errorReason isEqualToString:@"login_denied"])||[errorReason isEqualToString:@"access_denied"]);
        if(userDidCancel){
            //[self dialogDidCancel:url];
            [self CUNotifyAuthFailed:self withError:nil];
        }else {
            NSString *q = [url absoluteString];
            if (![q hasPrefix:kAuthBaseURL]) {
                [[UIApplication sharedApplication] openURL:request.URL];
            }
        }
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) {//提交表单
        NSString *state = [params objectForKey:@"flag"];
        if ((state && [state isEqualToString:@"success"]) || accessToken) {
            [self dialogDidSucceed:url];
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //[self.indicatorView stopAnimating];
    //    self.cancelButton.hidden = YES;
    UIActivityIndicatorView *view = [self.viewClient getActivityIndicatorView];
    [view stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
        [self CUNotifyAuthFailed:self withError:error];
    }
}
#pragma mark - common method
- (BOOL)sendWithDictionary:(NSMutableDictionary *)dic
{
    if ([dic count] == 0 || ![self isCUAuth]) {
        return NO;
    }
    
    NSMutableDictionary *aParams = [NSMutableDictionary dictionaryWithDictionary:dic];
    [aParams setObject:@"feed.publishFeed" forKey:@"method"];
    
    [renren requestWithParams:aParams andDelegate:self];
    
    return YES;
}

- (BOOL)isAuthDialog
{
    return YES;//[_serverURL isEqualToString:kAuthBaseURL];
}

- (void)dialogDidSucceed:(NSURL *)url {
	
	NSString *q = [url absoluteString];
    NSString *token = [ROUtility getValueStringFromUrl:q forParam:@"access_token"];
    NSString *expTime = [ROUtility getValueStringFromUrl:q forParam:@"expires_in"];
    NSDate   *expirationDate = [ROUtility getDateFromString:expTime];
        
    renren.accessToken = token;
    renren.expirationDate = expirationDate;
    renren.secret=[ROUtility getSecretKeyByToken:token];
    renren.sessionKey=[ROUtility getSessionKeyByToken:token];
    
    if ((token == (NSString *) [NSNull null]) || (token.length == 0)) {
        [self dialogDidCancel:nil];
    } 
    else 
    {
        [renren saveUserSessionInfo];
        [renren getLoggedInUserId];
        
        [self CUNotifyAuthSucceed:self];
    }
    
    return;
}

- (void)dialogDidCancel:(NSURL *)url {
    [self CUNotifyShareCancel:self];
}

- (void)post:(NSString *)text andImage:(UIImage *)image
{
    NSAssert(0,@"not implement");
    return;
}   

- (void)post:(NSString *)text andImageURLString:(NSString *)imageURLString
{
    if ([text length] == 0) {
        return [self CUNotifyShareFailed:self withError:nil];
    } 
    
    NSMutableDictionary* params = [NSMutableDictionary 
                                   dictionaryWithObjectsAndKeys:
                                   @"feed.publishFeed",@"method",//api参数表中的参数
                                   nil];
    [params setObject:@" " forKey:@"name"]; // 狗屎的连接，这里我们用这个绕过去
    [params setObject:@"http://192.168.1.108.com/" forKey:@"url"];
    [params setObject:text forKey:@"description"];
    
    if ([imageURLString length]) {
        [params setObject:imageURLString forKey:@"image"];
    }
        
    [renren requestWithParams:params andDelegate:self];
}   

#pragma mark - RenrenDelegate

/**
 * 接口请求成功，第三方开发者实现这个方法
 * @param renren 传回代理服务器接口请求的Renren类型对象。
 * @param response 传回接口请求的响应。
 */
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response
{
    [self CUNotifyShareSucceed:self];
}

/**
 * 接口请求失败，第三方开发者实现这个方法
 * @param renren 传回代理服务器接口请求的Renren类型对象。
 * @param response 传回接口请求的错误对象。
 */
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error
{
    [self CUNotifyShareFailed:self withError:nil];
}

@end

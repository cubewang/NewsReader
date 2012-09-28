//
//  CUShareClient.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-20.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CUShareOAuthView.h"

typedef enum _CUShareClientType
{
    SINACLIENT = 0,
    RENRENCLIENT = 1,
    TTWEIBOCLIENT = 2
}
CUShareClientType;

@protocol CUShareClientData <UIWebViewDelegate>

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;

- (BOOL)isCUAuth;
- (void)CUOpenAuthViewInViewController:(UIViewController *)vc;
- (void)CULogout;

- (void)CUSendWithText:(NSString *)text;
- (void)CUSendWithText:(NSString *)text andImage:(UIImage *)image;
- (void)CUSendWithText:(NSString *)text andImageURLString:(NSString *)imageURLString;

@optional
- (NSString *)requestToken;

- (void)addDelegate:(id)aDelegate;
- (void)removeDelegate:(id)aDelegate;

@end

@class CUShareClient;
@protocol CUShareClientDelegate <NSObject>

@optional
- (void)CUShareFailed:(CUShareClient *)client withError:(NSError *)error;
- (void)CUShareSucceed:(CUShareClient *)client;
- (void)CUShareCancel:(CUShareClient *)client;

- (void)CUAuthSucceed:(CUShareClient *)client;
- (void)CUAuthFailed:(CUShareClient *)client withError:(NSError *)error;

@end

@class GCDMulticastDelegate;
@interface CUShareClient : NSObject
<UIWebViewDelegate>
{
    id<CUShareClientDelegate> delegate;
    
    CUShareOAuthView *viewClient;
    
    GCDMulticastDelegate <CUShareClientDelegate> *multicastMessageDelegate;
}

@property (nonatomic, assign) id<CUShareClientDelegate> delegate;
@property (nonatomic, retain) CUShareOAuthView *viewClient;

- (void)addDelegate:(id)aDelegate;
- (void)removeDelegate:(id)aDelegate;

- (void)CUOpenAuthViewInViewController:(UIViewController *)vc;

- (void)CUNotifyShareFailed:(CUShareClient *)client withError:(NSError *)error;
- (void)CUNotifyShareSucceed:(CUShareClient *)client;
- (void)CUNotifyShareCancel:(CUShareClient *)client;
- (void)CUNotifyAuthSucceed:(CUShareClient *)client;
- (void)CUNotifyAuthFailed:(CUShareClient *)client withError:(NSError *)error;

@end

//
//  CUShareClient.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-20.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUShareClient.h"
#import "CUShareOAuthView.h"
#import "GCDMulticastDelegate.h"

@interface CUShareClient ()

@end

@implementation CUShareClient

@synthesize delegate;
@synthesize viewClient;

#pragma mark - life

- (id)init
{
    if (self = [super init]) {
        multicastMessageDelegate = (GCDMulticastDelegate <CUShareClientDelegate> *)[[GCDMulticastDelegate alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    self.viewClient = nil;
    self.delegate = nil;
    
    [multicastMessageDelegate removeAllDelegates];
    
    [multicastMessageDelegate release];
    
    [super dealloc];
}

#pragma mark - common method

- (void)addDelegate:(id)aDelegate {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");
    
    [multicastMessageDelegate addDelegate:aDelegate 
                            delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id)aDelegate {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");
    
    [multicastMessageDelegate removeDelegate:aDelegate];
}


- (void)CUOpenAuthViewInViewController:(UIViewController *)vc;
{
    self.viewClient = [[[CUShareOAuthView alloc] init] autorelease];
    self.viewClient.loginRequest = [self CULoginURLRequest];
    self.viewClient.webView.delegate = self;
    [self.viewClient.webView loadRequest:[self CULoginURLRequest]];
    
    [self performSelector:@selector(show:) withObject:vc afterDelay:0.1];
}

- (void)CUNotifyShareFailed:(CUShareClient *)client withError:(NSError *)error
{
    [multicastMessageDelegate CUShareFailed:client withError:error];
    
    [self.viewClient performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

- (void)CUNotifyShareSucceed:(CUShareClient *)client
{
    [multicastMessageDelegate CUShareSucceed:client];
    
    [self.viewClient performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

- (void)CUNotifyShareCancel:(CUShareClient *)client
{
    [multicastMessageDelegate CUShareCancel:client];
    
    [self.viewClient performSelector:@selector(close:) withObject:nil afterDelay:.20f];
}

- (void)CUNotifyAuthSucceed:(CUShareClient *)client
{
    [multicastMessageDelegate CUAuthSucceed:client];
    
    [self.viewClient performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

- (void)CUNotifyAuthFailed:(CUShareClient *)client withError:(NSError *)error
{
    [multicastMessageDelegate CUAuthFailed:client withError:error];
    
    [self.viewClient performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

#pragma mark - private

- (void)show:(UIViewController *)vc
{
    [vc presentModalViewController:viewClient animated:YES];
}

#pragma mark - override me

- (NSURLRequest *)CULoginURLRequest
{
    return nil;
}

@end

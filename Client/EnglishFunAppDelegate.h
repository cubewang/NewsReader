//
//  EnglishFunAppDelegate.h
//  iKnow
//
//  Created by Cube on 11-4-21.
//  Copyright 2011 iKnow Team. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Client.h"
#import "DDLog.h"
#import "Reachability.h"
#import "CustomAlertView.h"
#import "MainViewController.h"

#import "IIViewDeckController.h"

#define IKNOW_TAG @"VOA Special"
#define APP_TITLE IKNOW_TAG

#define TAG_ARRAY @"World", @"USA", @"Business", @"Education", @"Health", @"Entertainment", @"Science and Technology", @"American Mosaic", @"Explorations", @"In the News", @"People in America", @"Science in the News", @"This is America", @"Words and Their Stories", @"American Stories"


@class iKnowXMPPClient;
@class MessageManager;
@class CustomBadge;
@class LeftViewController;
@class GuideViewController;

@interface EnglishFunAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;

    Client *client;
    
    iKnowXMPPClient *_xmppClient;
    
    //network monitor
    Reachability* internetReach;
    
    NSString *deviceToken;
    
    GuideViewController *guideViewController;
    
    UIImageView *splashView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) Client *client;
@property (nonatomic, retain) iKnowXMPPClient *xmppClient;

@property (retain, nonatomic) MainViewController *mainViewController;
@property (retain, nonatomic) UINavigationController *centerViewController;
@property (retain, nonatomic) IIViewDeckController* deckController;

@property (nonatomic, retain) NSString *deviceToken;

+ (UILabel*)createNavTitleView:(NSString *)title;
+ (BOOL)setNavImage:(NSString *)imageName;
+ (EnglishFunAppDelegate *)sharedAppDelegate;
+ (NSString *)deviceUserAgent;

+ (NSString *)getImagePathInDocument;
+ (NSString *)getAudoPathInDocument;
+ (BOOL)UrlCacheHit:(NSString *)url;

- (Client *)getClient;
- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix;
- (NSString *)pathForASIHTTPDownLoadCache;

- (iKnowXMPPClient *)getXMPPClient;
- (MessageManager *)getMessageManager;
- (CustomBadge *)getCustomBadge;

//开始登录或者注册
- (void)loginOrRegisterUser:(UIViewController *)aViewController;

@end

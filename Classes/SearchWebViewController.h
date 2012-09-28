//
//  SearchWebViewController.h
//  iKnow
//
//  Created by cg on 12-4-11.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchWebViewController : UIViewController<
UIWebViewDelegate,UIActionSheetDelegate> {
    
    IBOutlet UIWebView *searchWebView;
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UIBarItem *goBackButton;
    IBOutlet UIBarItem *goForwardButton;
    IBOutlet UIBarItem *refreshButton;
   
    UIActivityIndicatorView *activityIndictorView;
    NSString *contentUrl;
    NSString *safariUrl;
}

@property (nonatomic, retain) UIWebView *searchWebView;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) NSString *contentUrl;
@property (nonatomic, retain) UIBarItem *goBackButton;
@property (nonatomic, retain) UIBarItem *goForwardButton;
@property (nonatomic, retain) NSString *safariUrl;
@property (nonatomic, retain) UIBarItem *refreshButton;

- (IBAction)back:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)openSafair:(id)sender;

@end

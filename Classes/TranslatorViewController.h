//
//  TranslatorViewController.h
//  EnglishFun
//
//  Created by cg on 12-7-17.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TranslatorViewController : UIViewController {
    
    NSString *displayContent;
}


@property (nonatomic,retain) UIWebView *webView;
@property (nonatomic,retain) NSString *displayContent;
@property (nonatomic, retain) UIButton *rightItem;
@property (nonatomic, retain) UINavigationBar *navBar;

@end

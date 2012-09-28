//
//  TranslatorViewController.m
//  EnglishFun
//
//  Created by cg on 12-7-17.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import "TranslatorViewController.h"
#import "BingTranslator.h"


@interface TranslatorViewController () {
    
    IBOutlet UIWebView *webView;
    IBOutlet UIButton *rightItem;
    IBOutlet UINavigationBar *navBar;
}

@end

@implementation TranslatorViewController

@synthesize webView;
@synthesize displayContent;
@synthesize rightItem;
@synthesize navBar;

- (void)dealloc {
    
    self.webView = nil;
    self.displayContent = nil;
    self.navBar = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.tintColor = NAV_BAR_ITEM_COLOR;
    if ([self.navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navBar setBackgroundImage:[UIImage imageNamed:@"mainViewNavBar_iPad.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    [self.rightItem setTitle:NSLocalizedString(@"返回", @"") forState:UIControlStateNormal];
    
    NSString *basePath = [[NSString alloc] initWithFormat:@"%@%@%@%@", MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH];
    
    [self.webView loadHTMLString:displayContent baseURL:[NSURL URLWithString:basePath]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)back:(id)sender {
     [self dismissModalViewControllerAnimated:YES];
}

@end

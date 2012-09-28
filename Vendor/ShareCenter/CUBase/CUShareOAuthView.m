//
//  CUShareOAuthView.m
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CUShareOAuthView.h"
#import "CUConfig.h"

int kActiveIndicatorTag = 10;

CGRect ApplicationFrame(UIInterfaceOrientation interfaceOrientation) {
	
	CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
    
	bounds.origin.x = 0;
	return bounds;
}

@interface  CUShareOAuthView()

@property (nonatomic, readwrite) UIInterfaceOrientation orientation;
@property (nonatomic, retain) UINavigationBar *navBar;
@end

@implementation CUShareOAuthView

@synthesize webView;
@synthesize orientation;
@synthesize loginRequest;
@synthesize navBar;
@synthesize tintColor;

#pragma mark -  life

- (id)init
{
    if (self = [super init]) {
        CGRect rc = ApplicationFrame(self.orientation);

        rc.size.height -= 44;
        rc.origin.y = 44;
        
        self.webView = [[[UIWebView alloc] initWithFrame:rc] autorelease];
	        
        [self.view addSubview: self.webView];
    }
    
    return self;
}

- (void)dealloc
{
    self.webView = nil;
    self.loginRequest = nil;
    self.navBar = nil;
    self.tintColor = nil;
    
    [super dealloc];
}

#pragma mark -  UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rc = ApplicationFrame(self.orientation);
    
    self.view = [[[UIView alloc] initWithFrame: rc] autorelease];
    self.navBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)] autorelease];
	
    self.navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
#ifdef NAV_BAR_ITEM_COLOR
    self.navBar.tintColor = NAV_BAR_ITEM_COLOR;
#endif
    
#ifdef NAVBAR_TOOLBAR_IMAGE_NAME
    if ([self.navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navBar setBackgroundImage:[UIImage imageNamed:NAVBAR_TOOLBAR_IMAGE_NAME] 
                          forBarMetrics:UIBarMetricsDefault];
    }
#endif
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    CGRect frame = ApplicationFrame(self.orientation);
    frame.origin.y = 44;
    frame.size.height -= 44;
    
    [self.view addSubview: navBar];
    
    UIActivityIndicatorView *activeIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activeIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin 
                                            | UIViewAutoresizingFlexibleBottomMargin
                                            | UIViewAutoresizingFlexibleLeftMargin 
                                            | UIViewAutoresizingFlexibleRightMargin;
    activeIndicator.tag = kActiveIndicatorTag;
    activeIndicator.hidden = YES;
    activeIndicator.frame = CGRectMake(CGRectGetMidX(self.webView.bounds) - 20.0f,
                                       CGRectGetMidY(self.webView.bounds) - 20.0f,
                                       40.0f, 40.0f);
    [self.webView addSubview:activeIndicator];
    [activeIndicator release];
	
    UINavigationItem *navItem = [[[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"登录", @"")] autorelease];
    
    navItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回", @"")
                                                                  style:UIBarButtonItemStylePlain target:self 
                                                                 action:@selector(cancel:)] autorelease];
    
    [navBar pushNavigationItem: navItem animated: NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown 
    || toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - common method

- (void)cancel:(id)sender {
    [self performSelector:@selector(close:) withObject:nil afterDelay:.2f];
}

- (UIActivityIndicatorView *)getActivityIndicatorView
{
    return (UIActivityIndicatorView *)[self.webView viewWithTag:kActiveIndicatorTag];
}

- (void)close:(id)sender
{
    [[self getActivityIndicatorView] stopAnimating];
    
    self.webView.delegate = nil;
    
    [self dismissModalViewControllerAnimated:YES];
}

@end

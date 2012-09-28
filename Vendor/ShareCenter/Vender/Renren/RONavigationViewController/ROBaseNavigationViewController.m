//
//  ROBaseNavigationViewController.m
//  RenrenSDKDemo
//
//  Created by xiawh on 11-11-11.
//  Copyright (c) 2011年 renren－inc. All rights reserved.
//

#import "ROBaseNavigationViewController.h"

@interface ROBaseNavigationViewController (Private) 

- (void)addObservers;
- (void)removeObservers;

- (CGRect)calcFrameBefore;
- (CGRect)calcFrameAfter;
- (CGAffineTransform)transformForOrientation;

@end

@implementation ROBaseNavigationViewController
@synthesize navigationBar = _navigationBar;
@synthesize orientation = _orientation;
@synthesize lastViewController = _lastViewController;

- (id)init
{
    self = [super init];
    if (self) {
        self.view = [[[UIView alloc] initWithFrame:[self calcFrameBefore]] autorelease];
        _navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
        
        _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:_navigationBar];
        
        UINavigationItem *navItem = [[[UINavigationItem alloc] initWithTitle:@"人人网-开放平台"] autorelease];
        navItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
        
        [_navigationBar pushNavigationItem: navItem animated: NO];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)change:(ROBaseNavigationViewController *)newController
{
    self.orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    newController.orientation = self.orientation;
    newController.view.transform = [newController transformForOrientation];
    newController.view.frame = [newController calcFrameAfter];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[UIApplication sharedApplication].keyWindow cache:YES];
    
    [[UIApplication sharedApplication].keyWindow addSubview:newController.view];
    [UIView commitAnimations];
    
    [self performSelectorOnMainThread:@selector(selfChangeOption:) withObject:newController waitUntilDone:YES];
}

- (void)viewAnimationShow
{
    self.view.transform = [self transformForOrientation];
    self.view.frame = [self calcFrameBefore];
        
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    self.view.frame = [self calcFrameAfter];
    [UIView commitAnimations];
}

- (void)viewAnimationHide
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeSuperviewFrowWindow)];
    self.view.frame = [self calcFrameBefore];
	[UIView commitAnimations];
}

- (void)removeSuperviewFrowWindow
{
    [self.view removeFromSuperview];
}

- (void)addObservers 
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)removeObservers 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)close
{
    self.orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    
    [self removeObservers];
    [self viewAnimationHide];
    [self release];
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    
    self.orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    [self addObservers];
    [self viewAnimationShow];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)selfChangeOption:(ROBaseNavigationViewController *)newController
{
    
}

- (void)otherChangeOption:(ROBaseNavigationViewController *)newController
{
    
}

- (CGAffineTransform)transformForOrientation
{
    if (self.orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    } else if (self.orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
    } else if (self.orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

- (CGRect)calcFrameBefore
{
	CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    CGRect resultFrame = CGRectZero;
	if (self.orientation == UIDeviceOrientationLandscapeLeft) {
		resultFrame.origin.x = -bounds.size.width;
        resultFrame.origin.y = 0.0f;
	} else if (self.orientation == UIDeviceOrientationLandscapeRight) {
        resultFrame.origin.x = bounds.size.width;
        resultFrame.origin.y = 0.0f;
    } else if (self.orientation == UIDeviceOrientationPortrait) {
        resultFrame.origin.x = 0.0f;
        resultFrame.origin.y = bounds.size.height;
    } else if (self.orientation == UIDeviceOrientationPortraitUpsideDown) {
        resultFrame.origin.x = 0.0f;
        resultFrame.origin.y = -bounds.size.height;
    } else {
        resultFrame.origin.x = bounds.origin.x;
        resultFrame.origin.y = bounds.origin.y;
    }
    resultFrame.size.width = bounds.size.width;
    resultFrame.size.height = bounds.size.height;
	return resultFrame;
}

- (CGRect)calcFrameAfter 
{
	return [[UIScreen mainScreen] applicationFrame];
}

- (void)deviceOrientationDidChange:(void*)object
{
    UIDeviceOrientation orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation != self.orientation) {
        self.orientation = orientation;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.view.transform = [self transformForOrientation];
        self.view.frame = [self calcFrameAfter];
        [UIView commitAnimations];
    }
}

- (void)dealloc
{
    self.navigationBar = nil;
    self.lastViewController = nil;
    [super dealloc];
}

@end

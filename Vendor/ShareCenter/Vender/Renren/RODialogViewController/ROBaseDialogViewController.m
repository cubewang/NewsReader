//
//  ROBaseDialogViewController.m
//  RenrenSDKDemo
//
//  Created by xiawh on 11-8-30.
//  Copyright 2011年 renren-inc. All rights reserved.
//

#import "ROBaseDialogViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ROUtility.h"
 

#define kPadding 10

@interface ROBaseDialogViewController(private)

- (BOOL)IsDeviceIPad;
- (CGAffineTransform)transformForOrientation;
- (void)addObservers;
- (void)removeObservers;

@end

@implementation ROBaseDialogViewController
@synthesize backgroundView = _backgroundView;
@synthesize cancelButton = _cancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _showingKeyboard = NO;
        _orientation = UIDeviceOrientationUnknown;
        
        self.backgroundView = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
        self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
        
        self.view.backgroundColor = [UIColor clearColor];
        
        UIView *skinView = [[UIView alloc] initWithFrame:CGRectMake(0, 
                                                                    0, 
                                                                    self.view.frame.size.width, 
                                                                    self.view.frame.size.height)];
        skinView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        skinView.backgroundColor = [UIColor blackColor];
        skinView.alpha = 0.4f;
        [self.view addSubview:skinView];
        [skinView release];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame = CGRectMake(0, 
                                             0, 
                                             self.view.frame.size.width, 
                                             self.view.frame.size.height);

        [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.cancelButton];
        
        [self sizeToFitOrientation:YES];
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

- (void)viewAnimationShow
{
    self.view.alpha = 0.0;
    self.view.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    self.view.alpha = 1.0;
    self.view.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
    [UIView commitAnimations];
}

- (void)bounce1AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    self.view.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    self.view.transform = [self transformForOrientation];
    [UIView commitAnimations];
}

- (void)viewAnimationHide
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeSuperviewFrowWindow)];
    self.view.alpha = 0.0f;
	[UIView commitAnimations];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (CGAffineTransform)transformForOrientation 
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

- (BOOL) IsDeviceIPad 
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
#endif
    return NO;
}

- (void)sizeToFitOrientation:(BOOL)transform 
{
    if (transform) {
        self.view.transform = CGAffineTransformIdentity;
    }
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    CGPoint center = CGPointMake(frame.origin.x + ceil(frame.size.width/2),
                                 frame.origin.y + ceil(frame.size.height/2));
    
    CGFloat scale_factor = 1.0f;
    if ([self IsDeviceIPad]) {
        // On the iPad the dialog's dimensions should only be 60% of the screen's
        scale_factor = 0.6f;
    }
    
    CGFloat width = floor(scale_factor * frame.size.width);
    CGFloat height = floor(scale_factor * frame.size.height);
    
    _orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
        self.view.frame = CGRectMake(kPadding, kPadding, height, width);
        self.cancelButton.frame = CGRectMake(0, 
                                             0, 
                                             self.view.frame.size.width, 
                                             self.view.frame.size.height);
    } else {
        self.view.frame = CGRectMake(kPadding, kPadding, width, height);
        self.cancelButton.frame = CGRectMake(0, 
                                             0, 
                                             self.view.frame.size.width, 
                                             self.view.frame.size.height);
    }
    self.view.center = center;
    
    if (transform) {
        self.view.transform = [self transformForOrientation];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [self sizeToFitOrientation:YES];
    [[UIApplication sharedApplication].keyWindow insertSubview:self.backgroundView belowSubview:self.view];
    
    [self viewAnimationShow];
    [self addObservers];
}

- (void)close
{
    [self viewAnimationHide];
    [self removeObservers];
    [self release];
}

- (void)removeSuperviewFrowWindow
{
    [self.view removeFromSuperview];
    [self.backgroundView removeFromSuperview];
}

- (void)addObservers 
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillHideNotification" object:nil];
}

- (BOOL)shouldRotateToOrientation:(UIDeviceOrientation)orientation {
    if (orientation == _orientation) {
        return NO;
    } else {
        return orientation == UIDeviceOrientationLandscapeLeft
        || orientation == UIDeviceOrientationLandscapeRight
        || orientation == UIDeviceOrientationPortrait
        || orientation == UIDeviceOrientationPortraitUpsideDown;
    }
}

- (void)deviceOrientationDidChange:(void*)object
{
    UIDeviceOrientation orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
    if (!_showingKeyboard && [self shouldRotateToOrientation:orientation]) {
        [self updateSubviewOrientation];
        
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [self sizeToFitOrientation:YES];
        [UIView commitAnimations];
    }
}

- (void)keyboardWillShow:(NSNotification*)notification 
{
    _showingKeyboard = YES;
}

- (void)keyboardWillHide:(NSNotification*)notification 
{
    _showingKeyboard = NO;
}

- (void)updateSubviewOrientation 
{

}

- (void)cancel {
    [self close];
}

- (CGRect)fitOrientationFrame
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(kPadding, 
                          kPadding*3, 
                          self.view.frame.size.height - kPadding * 2, 
                          self.view.frame.size.width - kPadding *4);
    } else {
        return CGRectMake(kPadding, 
                          kPadding*8, 
                          self.view.frame.size.width - kPadding * 2, 
                          self.view.frame.size.height - kPadding *18);
    }
}

- (void)dealloc
{
    self.backgroundView = nil;
    self.cancelButton = nil;
    [super dealloc];
}

@end

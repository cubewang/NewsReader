//
//  CustomAlertView.m
// 
//
//  Created by cg on 11-10-12.
//  Copyright 2012 iKnow Team. All rights reserved.
//

#import "CustomAlertView.h"

@implementation CustomAlertView
@synthesize backgroundView;

- (id)initWithCancelbutton:(NSString*)cancelName 
               OtherButton:(NSString*)otherButton 
                  Delegate:(id)_delegate 
                 SuperView:(UIView*)_superView
{
	
    self = [super initWithFrame:CGRectZero];
    self.backgroundColor = [UIColor clearColor];
        
    //set delegate
    delegate = _delegate;
    superView = _superView;
    
    //set imageView 
    UIImageView *voteAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(48, 5, 160, 130)];
     
    voteAvatarImageView.image = [UIImage imageNamed:@"vote_avatar.png"];
    [voteAvatarImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:voteAvatarImageView];
    
    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(49, 53, 160, 130)];
    backgroundLabel.textColor = [UIColor whiteColor];
    backgroundLabel.textAlignment = UITextAlignmentCenter;
    backgroundLabel.font = [UIFont systemFontOfSize:16.0];
    backgroundLabel.backgroundColor = [UIColor clearColor]; 
    backgroundLabel.text = NSLocalizedString(@"给我评个分吧～", @"");
    
    [self addSubview:backgroundLabel];
    
    
    UILabel *cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 144, 83, 28)];
    cancelLabel.textColor = [UIColor whiteColor];
    cancelLabel.textAlignment = UITextAlignmentCenter;
    cancelLabel.font = [UIFont systemFontOfSize:12];
    cancelLabel.backgroundColor = [UIColor clearColor];
    cancelLabel.text = NSLocalizedString(@"以后再说", @"");

    [backgroundLabel release];
    [voteAvatarImageView release];
    
    //set cancelbtn
    UIButton *cancelBtn;
    UIButton *otherBtn;
    if (cancelName != nil) 
    {
        cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [cancelBtn setTitle:cancelName forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"vote_later.png"] forState:UIControlStateNormal];
        cancelBtn.frame = CGRectMake(40, 145, 83, 28);
        [cancelBtn setContentMode:UIViewContentModeScaleAspectFit];
        [cancelBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.tag = 100;
    }
    
    //set otherbutton
    if (otherButton != nil) {
        otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        otherBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [otherBtn setTitle:otherButton forState:UIControlStateNormal];
        [otherBtn setBackgroundImage:[UIImage imageNamed:@"vote_now.png"] forState:UIControlStateNormal];
        [otherBtn setContentMode:UIViewContentModeScaleAspectFit];
        [otherBtn setFrame:CGRectMake(140, 145, 83, 28)];
        [otherBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        otherBtn.tag = 101;
        
        [self setFrame:CGRectMake(0, 0, 260, 200)];
        [self addSubview:otherBtn];
        
        UILabel *otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 144, 83, 28)];
        otherLabel.textColor = [UIColor whiteColor];
        otherLabel.textAlignment = UITextAlignmentCenter;
        otherLabel.font = [UIFont systemFontOfSize:12];
        otherLabel.backgroundColor = [UIColor clearColor];
        otherLabel.text = NSLocalizedString(@"现在就去", @"");
        
        [self addSubview:otherLabel];
        
        [otherLabel release];
    }
    else 
    {
        [self setFrame:CGRectMake(0, 0, 260, 160)];

    }
    
    self.layer.cornerRadius = 10.0;
     
    [self addSubview:cancelBtn];
    
    [self addSubview:cancelLabel];
    [cancelLabel release];
    //setbackground
    self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    backgroundView.layer.cornerRadius = 10.0;
    [self addSubview:backgroundView];
    [self sendSubviewToBack:backgroundView];

    [self setCenter:superView.center];
    
    return self;
}

-(void)alertShow
{
    alertShowView = [[UIView alloc] initWithFrame:superView.frame];
    alertShowView.backgroundColor = [UIColor blackColor];
    alertShowView.alpha = 0.5;
    
    [superView addSubview:alertShowView];
    
    // Bounce to 1% of the normal size
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.0f];
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    
    [UIView commitAnimations];
    
    // Return back to 100%
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.15f];
    self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    
    [UIView commitAnimations];
    
    [superView addSubview:self];
}

-(void)buttonClick:(id)sender
{
    [[self superview] setAlpha:1.0];
    [alertShowView removeFromSuperview];
    [alertShowView release];
    [self removeFromSuperview];
    
    if (delegate) 
    {
        NSInteger index = [sender tag] - 100;
        [delegate CustomAlertView:self buttonClickedAtIndex:index];
    }
}

-(void)setAlertBackgroundImage:(NSString *)imagename
{
    [backgroundView setImage:[UIImage imageNamed:imagename]];
}

- (void)dealloc {
    [super dealloc];
    [backgroundView release];
}


@end

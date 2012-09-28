//
//  ZTextField.m
//  TestForInput
//
//  Created by curer on 11-10-16.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "ZTextField.h"


@implementation ZTextField

@synthesize textView;
@synthesize backgroundImage;
@synthesize parentView;
@synthesize delegate;
@synthesize keyboardRect;
@synthesize brotherView;

@synthesize textImage;
@synthesize buttonImage;
@synthesize buttonImagePress;

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}

- (void)setView:(UIView *)aParentView
{
    CGRect rcScreen = [aParentView frame];
    self = [super initWithFrame:CGRectMake(0, rcScreen.size.height - 40, 320, 40)];
    
    if (self) {
        
        //parentView = [aParentView retain];
        self.backgroundImage = [UIImage imageNamed:@"messageTextBg.png"];
        self.buttonImage = [UIImage imageNamed:@"messageTextSend.png"];
        self.textImage = [UIImage imageNamed:@"messageText.png"];
        
        
        UIView *containerView = self;
        textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
        textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        textView.minNumberOfLines = 1;
        textView.maxNumberOfLines = 4;
        textView.returnKeyType = UIReturnKeyDefault; 
        textView.font = [UIFont systemFontOfSize:15.0f];
        textView.delegate = self;
        textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *entryImageView = [[UIImageView alloc] init];
        entryImageView.frame = CGRectMake(5, 0, 248, 40);
        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        if (textImage) {
            entryImageView.image = [textImage stretchableImageWithLeftCapWidth:13 
                                                                        topCapHeight:22];
        }
        else {
            entryImageView.image = [[UIImage imageNamed:@"MessageEntryInputField.png"] 
                                    stretchableImageWithLeftCapWidth:13 
                                    topCapHeight:22];
        }
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        
        if (backgroundImage) {
            imageView.image = [backgroundImage stretchableImageWithLeftCapWidth:4 
                                                                   topCapHeight:22];
        }
        else {
            imageView.image = [[UIImage imageNamed:@"MessageEntryBackground.png"] 
                               stretchableImageWithLeftCapWidth:4 
                               topCapHeight:22];
        }

        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        // view hierachy
        [containerView addSubview:imageView];
        [containerView addSubview:textView];
        [containerView addSubview:entryImageView];
        
        [entryImageView release];
        [imageView release];
        
        UIImage *sendBtnBackground = nil;
        UIImage *selectedSendBtnBackground = nil;
        
        if (buttonImage) {
            sendBtnBackground = [buttonImage stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        }
        else {
            sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        }
        
        if (buttonImagePress) {
            selectedSendBtnBackground = [buttonImagePress stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        }
        else {
            selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        }
        
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 8, 63, 27);
        doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [doneBtn setTitle:@"发送" forState:UIControlStateNormal];
        
        [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
        doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
        doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        
        [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
        [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
        [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
        [containerView addSubview:doneBtn];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillShow:) 
                                                     name:UIKeyboardWillShowNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillHide:) 
                                                     name:UIKeyboardWillHideNotification 
                                                   object:nil];        
    }
}

- (void)dealloc
{
    textView.delegate = nil;
    delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];
    
    [backgroundImage release];
    [textView release];

    [brotherView release];
    [textImage release];
    [buttonImage release];
    [buttonImagePress release];
    
    [super dealloc];
}

#pragma mark delegate

-(void)resignTextView
{
    //[textView resignFirstResponder];
    
    if ([delegate respondsToSelector:@selector(ZTextFieldButtonDidClicked:)]) {
        [delegate ZTextFieldButtonDidClicked:self];
    }
    
    self.textView.text = @"";
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    //keyboardBounds = [self.parentView convertRect:keyboardBounds toView:nil];
    keyboardBounds = [self.superview convertRect:keyboardBounds toView:nil];
    keyboardRect = keyboardBounds;
    
    // get a rect for the textView frame
    CGRect containerFrame = self.frame;
    containerFrame.origin.y = self.superview.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.frame = containerFrame;
    
    if (self.brotherView) 
    {
        CGRect viewFrame = self.brotherView.frame;
        viewFrame.size.height -= keyboardBounds.size.height;
        self.brotherView.frame = viewFrame;
    }
    
    // commit animations
    [UIView commitAnimations];
    
    if ([delegate respondsToSelector:@selector(ZTextFieldKeyboardPopup:)]) {
        [delegate ZTextFieldKeyboardPopup:self];
    }
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.frame;
    containerFrame.origin.y = self.superview.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.frame = containerFrame;
    
    if (self.brotherView) 
    {
        CGRect viewFrame = self.brotherView.frame;
        viewFrame.size.height += keyboardRect.size.height;
        self.brotherView.frame = viewFrame;
    }
    
    // commit animations
    [UIView commitAnimations];
    
    if ([delegate respondsToSelector:@selector(ZTextFieldKeyboardDrop:)]) {
        [delegate ZTextFieldKeyboardDrop:self];
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.frame = r;
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    return [self.textView becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [self.textView resignFirstResponder];
}


@end

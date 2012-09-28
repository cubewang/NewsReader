//
//  CustomAlertView.h
//  
//
//  Created by cg on 12-3-28.
//  Copyright 2012 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@protocol CustomAlertViewDelegate

-(void)CustomAlertView:(id)customAlertView buttonClickedAtIndex:(NSInteger)index;

@end

@interface CustomAlertView : UIView {
	UIImageView *backgroundView;
	id<CustomAlertViewDelegate>delegate;
	UIView *superView;
	UIView *alertShowView;
}

@property(assign,nonatomic)UIImageView *backgroundView;

- (id)initWithCancelbutton:(NSString*)cancelName OtherButton:(NSString*)otherButton Delegate:(id)delegate SuperView:(UIView*)superView;
-(void)setAlertBackgroundImage:(NSString *)imagename;

-(void)alertShow;

@end

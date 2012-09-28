//
//  DropDownHeaderView.h
//  iKnow
//
//  Created by curer on 11-8-2.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DropDownHeaderView : UIView {
    UIView  *showView;
}

@property (nonatomic, retain) UIView *showView;

- (void) addView:(UIView *)view;

- (void)DDRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView; 

@end

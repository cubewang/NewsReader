//
//  GuideViewController.h
//  PageScrollSample
//
//  Created by taiki on 11/07/12.
//  Copyright 2011 http://twitter.com/yashigani. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GuideViewController : UIViewController <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    BOOL isChangeAction;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;

@property (nonatomic, assign) BOOL isChangeAction;

@end

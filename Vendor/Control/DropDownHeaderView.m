    //
//  DropDownHeaderView.m
//  iKnow
//
//  Created by curer on 11-8-2.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "DropDownHeaderView.h"

#define RefreshViewHight 30


@implementation DropDownHeaderView

@synthesize showView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    }
    
    return self;
}

- (void) addView:(UIView *)view{
    if (view) {
        [self addSubview:view];
    }
}

//手指屏幕上不断拖动调用此方法
- (void)DDRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
	
    if (scrollView.contentOffset.y < 0 && scrollView.contentOffset.y > -RefreshViewHight) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0.0f);
    }
    else if (scrollView.contentOffset.y <= -RefreshViewHight){
        if (scrollView.contentOffset.y != -RefreshViewHight) {
            scrollView.contentInset = UIEdgeInsetsMake(RefreshViewHight, 0, 0, 0.0f);
        }
    }
    else if (scrollView.contentInset.top != 0) {
        scrollView.contentInset = UIEdgeInsetsZero;
    }
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)DDRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -RefreshViewHight) {
        [UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(RefreshViewHight, 0, 0, 0.0f);
        
        [UIView commitAnimations];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [showView release];
    
    [super dealloc];
}


@end

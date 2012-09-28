//
//  TagDetailsController.h
//  iKnow
//
//  Abstract: 标签详细视图控制器
//
//  Created by Cube on 11-10-8.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"


@interface TagDetailsController : BaseTableViewController {

    NSString *articleTag;
    BOOL hasSubscribed;
    
    UIViewController *_popupViewController;
}

@property (nonatomic, copy) NSString *articleTag;
@property (nonatomic) BOOL hasSubscribed;

@property (nonatomic, retain) UIViewController* popupViewController;

@end

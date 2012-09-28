//
//  ROCheckDialogViewController.h
//  RenrenSDKDemo
//
//  Created by xiawh on 11-10-17.
//  Copyright 2011年 renren-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ROBaseDialogViewController.h"
 
 

@protocol RenrenCheckDialogDelegate <NSObject>

@optional
//- (void)renrenRepairOrder:(ROPayOrderInfo *)order andPresentController:(id)viewController;
@end

@interface ROCheckDialogViewController : ROBaseDialogViewController <UITableViewDelegate,UITableViewDataSource >{
    UITableView *_orderView;
    NSMutableArray *_result;
    id<RenrenCheckDialogDelegate> _delegate;
}
@property (nonatomic,retain)UITableView *orderView;
@property (nonatomic,retain)NSMutableArray *result;
@property (nonatomic,assign)id<RenrenCheckDialogDelegate> delegate;

 
@end

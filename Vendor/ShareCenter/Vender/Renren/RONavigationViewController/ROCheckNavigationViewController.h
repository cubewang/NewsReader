//
//  ROCheckNavigationViewController.h
//  RenrenSDKDemo
//
//  Created by xiawh on 11-11-14.
//  Copyright (c) 2011年 renren－inc. All rights reserved.
//

#import "ROBaseNavigationViewController.h"

@interface ROCheckNavigationViewController : ROBaseNavigationViewController <UITableViewDataSource,UITableViewDelegate>{
    UITableView *_orderView;
    NSMutableArray *_result;
   // id<RenrenCheckDialogDelegate> _delegate;
}
@property (nonatomic,retain)UITableView *orderView;
@property (nonatomic,retain)NSMutableArray *result;
//@property (nonatomic,assign)id<RenrenCheckDialogDelegate> delegate;

//- (void)repairOrder:(ROCheckOrderCell*)cell;

- (id)initWithResult:(NSMutableArray *)result;
@end

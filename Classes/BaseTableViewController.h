//
//  BaseTableViewController.h
//  iKnow
//
//  Abstract: 基础列表视图控制器，提供基本的单元格风格的表格视图
//
//  Created by Cube on 11-5-4.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parser.h"
#import "RTTableViewCell.h"
#import "EGORefreshTableHeaderView.h"
#import "VisualDownloader.h"


#define SECTION_LENGTH 20 //TableView每次Load的Item数目

@interface BaseTableViewController : UIViewController <ParserDelegate, EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource>
{
    Parser *parser;
    
    NSMutableArray *articleItems; // 文章列表
    NSMutableArray *articleItemsCached; 
    int articleCountBeforeLoading; //分段请求前的文章数，用于记录是否请求完所有服务器的文章
    
    BOOL failedToLoad;
    
    UIActivityIndicatorView *activityIndicator;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    NSDate *_lastUpDate;
    
    NSIndexPath *selectID;
    
    id delegate;
    
    //是否允许显示作者面板，由父控制器具体控制，默认不允许
    BOOL allowShowAuthorPanel;
}

// Reset and reparse
- (void)refresh;

// Properties
@property (nonatomic, retain) NSMutableArray *articleItems;
@property (nonatomic, retain) Parser *parser;
@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) IBOutlet UITableView* baseTableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, retain) NSDate *lastUpDate;
@property (nonatomic, retain) NSIndexPath *selectID;

@property (nonatomic, retain) VisualDownloader *textPictureDownloader;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end

@protocol BaseTableViewControllerDelegate

- (void)baseTableViewDidScroll:(BaseTableViewController *)baseTableViewController;
- (void)baseTableViewController:(BaseTableViewController *)baseTableViewController 
         viewForHeaderInSection:(NSInteger)section; 
@end
//
//  MainViewController.h
//  EnglishFun
//
//  Created by curer on 11-12-22.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"

#import "VisualDownloader.h"

#import "TagTableViewCell.h"

@interface MainViewController_iPad : BaseTableViewController {
}

@property (nonatomic, copy) NSString *tagTobeSet;
@property (nonatomic, copy) NSString *tagCurrentUsed;

@property (nonatomic, retain) VisualDownloader *audioDownloader;

@property (nonatomic, retain) NSArray *tagList;
@property (nonatomic, retain) IBOutlet UITableView *tagTableView;
@property (nonatomic, retain) TagTableViewCell *tableViewCell;
@property (nonatomic, retain) UINib *tableViewCellNib;
@property (nonatomic, retain) IBOutlet UIButton *settingButton;
@property (nonatomic, retain) IBOutlet UIButton *favoriteButton;
@property (nonatomic, retain) IBOutlet UIButton *wordButton;

- (void)setArticleTag:(NSString *)tag;

- (IBAction)showDownloader;
- (IBAction)showSetting;
- (IBAction)showWord;
- (IBAction)showFavorite;

@end

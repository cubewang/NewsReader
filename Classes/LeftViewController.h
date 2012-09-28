//
//  LeftViewController.h
//  EnglishFun
//
//  Created by curer on 11-12-25.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeftViewCell;

@interface LeftViewController : UIViewController {
    IBOutlet UITableView *tableView;
    
    IBOutlet UILabel *nickNameLabel;
    IBOutlet UIImageView *avatarImageView;
    IBOutlet UILabel *homeLabel;
    IBOutlet UILabel *myFavorites;
    IBOutlet UILabel *myWord;
    IBOutlet UILabel *setting;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UILabel *nickNameLabel;
@property (nonatomic, retain) UIImageView *avatarImageView;

- (IBAction)showMainViewController;
- (IBAction)showSetting;
- (IBAction)showWord;
- (IBAction)showFavorite;

- (IBAction)userAvatorButtonDidClicked:(id)sender;

- (void)refresh;

@end

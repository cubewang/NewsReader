//
//  SettingViewController_iPad.h
//  EnglishFun
//
//  Created by curer on 12-1-4.
//  Copyright 2012 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasswordViewController_iPad.h"

@class VisualDownloader;


@interface SettingViewController_iPad : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate> {
    UITextField *nickTextField;
    
    UIImageView *suggestionView;
    
    NSString *nickName;
    BOOL bChangeNickname;
    
    UITableView *tableView;
    
    VisualDownloader *textPictureDownloader;
    VisualDownloader *audioDownloader;
    
    long long fileSizeInBytes;
    
    IBOutlet UIButton *backButton;
    IBOutlet UINavigationBar *navBar;
    IBOutlet UILabel *titleLabel;
    PasswordViewController_iPad *passwordViewController_iPad;
}

@property (nonatomic, retain) UITextField *nickTextField;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIImageView *suggestionView;

@property (nonatomic, retain) VisualDownloader *textPictureDownloader;
@property (nonatomic, retain) VisualDownloader *audioDownloader;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, retain) UILabel *titleLabel;

- (IBAction)closeAction:(id)sender;

@end




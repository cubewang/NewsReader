//
//  SettingViewController.h
//  EnglishFun
//
//  Created by curer on 12-1-4.
//  Copyright 2012 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VisualDownloader;


@interface SettingViewController : UIViewController<UITextFieldDelegate> {
    UITextField *nickTextField;
    
    UIImageView *suggestionView;
    
    NSString *nickName;
    BOOL bChangeNickname;
    
    UITableView *tableView;
    
    VisualDownloader *textPictureDownloader;
    VisualDownloader *audioDownloader;
    
    long long fileSizeInBytes;
}

@property (nonatomic, retain) UITextField *nickTextField;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIImageView *suggestionView;

@property (nonatomic, retain) VisualDownloader *textPictureDownloader;
@property (nonatomic, retain) VisualDownloader *audioDownloader;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIButton *backButton;

- (IBAction)close:(id)sender;

@end


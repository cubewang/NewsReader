//
//  WebViewController_iPad.h
//  EnglishFun
//
//  Created by cg on 12-8-1.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Downloader.h"
#import "ContentFormatterFactory.h"
#import "ContentInfo.h"
#import "VisualDownloader.h"
#import "WordCardViewController.h"
#import "CommentViewController.h"
#import "Parser.h"
#import "BingTranslator.h"
#import "ArticleDownloader.h"
#import "WordDownloader.h"

@interface WebViewController_iPad : UIViewController 
<UIActionSheetDelegate, UIWebViewDelegate, 
DownloaderDelegate, UIGestureRecognizerDelegate> 
{
    //文章数据相关
    Article *article;   //当前文章
    NSArray *articleList; // 文章列表
    NSUInteger articlePosition; //当前文章所在列表中的位置
    UIImage *_coverImage;
    BOOL isArticleFavorite;
    
    //当加载文章失败后是否返回上一个页面，
    //原则是从哪里来回哪里去。
    BOOL closeWhenFailed;
    
    //显示图片动画时我们不允许返回
    BOOL willAnimateImage;
	
	//是否要销毁Controller
    BOOL willDestroyController;
    
    Downloader *downloader; //内容页面下载功能组件
    
    //音频相关
    AVAudioPlayer *player;
    NSString *audioPath;
    NSTimer *timer;
    VisualDownloader* audioDownloader;
    
    //内容解析
    ContentInfo* contentInfo;
    
    //在线查词
    NSString *selectedWord;
    Word *_word;
    NSMutableArray *wordParserList;
    
    IBOutlet UINavigationBar* navBar;
    IBOutlet UIWebView *webView;
    IBOutlet UISlider *scrubber;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *wordLabel;
    IBOutlet UILabel *accetationLabel;
    
    IBOutlet UIButton *deleteButton;
    
    IBOutlet UIButton *pageDownButton;
    IBOutlet UIButton *pageUpButton;
    IBOutlet UIButton *favoriteButton;
    IBOutlet UIButton *audioButton;
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *pauseButton;
    IBOutlet UIButton *commentBarItem;
    
    IBOutlet UIView *audioPlayingToolbar;
    IBOutlet UIView *articleOperationView;
    IBOutlet UIView *wordPanelView;
    IBOutlet UIView *downloadingConfirmedView;
    IBOutlet UILabel *doesDownlodeAudioLabel;
    IBOutlet UIButton *yesButton;
    IBOutlet UIButton *noButton;
	
	//内容图片
	UIImageView *contentImageView;
}

@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) NSArray *articleList;
@property (nonatomic, assign) NSUInteger articlePosition;
@property (nonatomic, retain) UIImage *coverImage;

@property (nonatomic, retain) Downloader *downloader;

@property (nonatomic, retain) VisualDownloader* audioDownloader;
@property (retain) AVAudioPlayer *player;
@property (retain) NSString *audioPath;

@property (nonatomic, retain) ContentInfo* contentInfo;

@property (nonatomic, retain) NSMutableArray *wordParserList;
@property (nonatomic, copy) NSString *selectedWord;
@property (nonatomic, retain) Word *word;


@property (nonatomic, retain) UINavigationBar* navBar;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UISlider *scrubber;
@property (nonatomic, retain) UILabel *wordLabel;
@property (nonatomic, retain) UILabel *accetationLabel;
@property (nonatomic, retain) UILabel *doesDownlodeAudioLabel;

@property (nonatomic, retain) UIButton *pageDownButton;
@property (nonatomic, retain) UIButton *pageUpButton;

@property (nonatomic, retain) UIButton *favoriteButton;
@property (nonatomic, retain) UIButton *audioButton;
@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic, retain) UIButton *pauseButton;
@property (nonatomic, retain) UIButton *commentBarItem;
@property (nonatomic, retain) UIButton *yesButton;
@property (nonatomic, retain) UIButton *noButton;
@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIButton *translationButton;

@property (nonatomic, retain) UIView *audioPlayingToolbar;
@property (nonatomic, retain) UIView *articleOperationView;
@property (nonatomic, retain) UIView *wordPanelView;
@property (nonatomic, retain) UIView *downloadingConfirmedView;

@property (nonatomic, retain) UIImageView *contentImageView;

@property (nonatomic, retain) IBOutlet UIButton *backButton;

- (IBAction) closeContent;
- (IBAction) openComment;

- (IBAction) deleteArticle;

- (IBAction) pause: (id) sender;
- (IBAction) play: (id) sender;
- (IBAction) scrubbbingDone: (id) sender;
- (IBAction) scrub: (id) sender;
- (IBAction) downloadButtonClicked: (id) sender;
- (IBAction) cancelButtonClicked: (id) sender;
- (IBAction) favoriteButtonClicked:(UIButton *)sender;
- (IBAction) shareButtonClicked:(UIButton *)sender;
- (IBAction) chapterButtonClicked:(UIButton *)sender;
- (IBAction) audioButtonClicked:(UIButton *)sender;
- (IBAction) pageButtonClicked:(UIButton *)sender;
- (IBAction) delayDidWordPanelShow:(id) sender;
- (IBAction) worldPanelViewDidClicked:(id)sender;
- (void) showEmail;
- (IBAction) bingTranslator:(id)sender;
- (BOOL) deleteFavorite;

@end

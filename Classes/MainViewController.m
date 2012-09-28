    //
//  MainViewController.m
//  EnglishFun
//
//  Created by curer on 11-12-22.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "MainViewController.h"
#import "ArticleDownloader.h"

#define ARTICLE_DOWNLOADER_KEY       @"text"
#define OFFLINE_DOWNLOAD_TIME_KEY   @"offlineDownloadTime"


@implementation MainViewController

@synthesize tagTobeSet, tagCurrentUsed;

@synthesize audioDownloader;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    if (self.tagTobeSet == nil) {
        self.tagCurrentUsed = IKNOW_TAG;
    }
    else {
        self.tagCurrentUsed = self.tagTobeSet;
    }
    
    [super viewDidLoad];
    
    [self setNavigationBar];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setNavigationBar
{
    self.navigationController.navigationBar.tintColor = NAV_BAR_ITEM_COLOR;
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar_ios5.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationController.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.navigationController.navigationBar.layer.shadowRadius = 3.0f;
    self.navigationController.navigationBar.layer.shadowOpacity = 0.8f;
    
    //设置导航条文字
    UILabel* label = [EnglishFunAppDelegate createNavTitleView:APP_TITLE];
    self.navigationItem.titleView = label;
    [label release];
    
    UIButton *buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 30)];
    [buttonLeft setImage:[UIImage imageNamed:@"ButtonMenu"] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithCustomView:buttonLeft]; 
    
	self.navigationItem.leftBarButtonItem = itemLeft;
    [itemLeft release];
    
    UIButton *buttonRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 30)];
    [buttonRight setImage:[UIImage imageNamed:@"offlineDownload"] forState:UIControlStateNormal];
    [buttonRight addTarget:self action:@selector(showDownloader) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithCustomView:buttonRight];
    
	self.navigationItem.rightBarButtonItem = itemRight;
    [itemRight release];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    
    self.tagTobeSet = nil;
    self.tagCurrentUsed = nil;
    self.audioDownloader = nil;
    
    [super dealloc];
}

- (void)setArticleTag:(NSString *)tag
{
    if (tag != nil)
    {
        self.tagTobeSet = tag;
        
        //设置导航条文字
        UILabel* label = [EnglishFunAppDelegate createNavTitleView:tag];
        self.navigationItem.titleView = label;
        [label release];
        
        [self enforceRefresh];
    }
}

#pragma mark article

- (BOOL)getArticleList:(NSInteger)startPosition length:(NSInteger)length useCacheFirst:(BOOL)useCacheFirst
{
    if (self.tagTobeSet != nil && ![self.tagCurrentUsed isEqualToString:self.tagTobeSet])
    {
        self.tagCurrentUsed = self.tagTobeSet;
    }
    
    self.parser = [iKnowAPI getArticleList:nil 
                                  tagArray:[NSArray arrayWithObject:self.tagCurrentUsed]
                             startPosition:startPosition 
                                    length:length 
                                  delegate:self 
                             useCacheFirst:useCacheFirst];
    
    return self.parser != nil;
}

#pragma mark -
#pragma mark ParserDelegate

- (void)parserDidFinish:(Parser *)theParser {
    
    [super parserDidFinish:theParser];
}

- (void)parser:(Parser *)aParser didFailWithError:(NSString *)error {
    
    [super parser:aParser didFailWithError:error];
}

#pragma mark basetableViewcontroller method

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
    //super method
    /*
     if (_lastUpDate == nil) {
     self.lastUpDate = [NSDate date];
     }
     return _lastUpDate;*/
    
    self.lastUpDate = [[NSUserDefaults standardUserDefaults] 
                       objectForKey:@"LastestViewControllerUpdateTime"];
    
    if (_lastUpDate == nil) {
        //
        self.lastUpDate = [NSDate date];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.lastUpDate 
                                                  forKey:@"LastestViewControllerUpdateTime"];
    }
    
    return _lastUpDate;   
}

- (void)refresh
{
    [super refresh];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] 
                                              forKey:@"LastestViewControllerUpdateTime"];
    
}

- (void)showLeft
{
    [self.viewDeckController toggleLeftView];
}

- (void)showDownloader
{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"离线下载", @"")
                                                   message:NSLocalizedString(@"需要下载文章中附带的音频么", @"")
                                                  delegate:self 
                                         cancelButtonTitle:NSLocalizedString(@"取消", @"") 
                                         otherButtonTitles:NSLocalizedString(@"下载", @""),NSLocalizedString(@"不下载", @""),nil];
    view.tag = 1;
    [view show];
    [view release];
}

#pragma mark alertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        
        if (buttonIndex == 1) {
            [self downloadOffline:YES];
        }
        else if (buttonIndex == 2) {
            [self downloadOffline:NO];
        }
    }
    
    return;
}

- (void)downloadOffline:(BOOL)bAudio
{
    [[ArticleDownloader shareInstance] reset];
    [ArticleDownloader shareInstance].delegate = self;
    [ArticleDownloader shareInstance].bDownLoadAudio = bAudio;
    
    if (self.textPictureDownloader == nil) {
        self.textPictureDownloader = [[VisualDownloader alloc] init];
        [self.textPictureDownloader release];
    }
    
    [self.textPictureDownloader createProgressAlertWithMessage:NSLocalizedString(@"正在离线文章列表", @"")];
    self.textPictureDownloader.delegate = self;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 
                                             0), ^{
        
        BOOL bSuccess = NO;
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSArray *tagList = [NSArray arrayWithObjects:IKNOW_TAG, TAG_ARRAY, nil];
        
        for (NSString *tag in tagList) {
            
            [ArticleDownloader shareInstance].userInfo = 
            [NSDictionary dictionaryWithObject:[NSString stringWithFormat:NSLocalizedString(@"正在下载 %@", @""), tag] forKey:ARTICLE_DOWNLOADER_KEY];
            
            bSuccess = [[ArticleDownloader shareInstance] downloadSync:tag];
        }
        
        [pool drain];
        
        if (bSuccess) {
            //反转 audioList
            NSArray *arr = [[[ArticleDownloader shareInstance].audioList reverseObjectEnumerator] allObjects];
            [ArticleDownloader shareInstance].audioList = [NSMutableArray arrayWithArray:arr];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textPictureDownloader close];
            
            if (bAudio) {
                [self downloadAudio];
            }
            
            if (bSuccess) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] 
                                                          forKey:OFFLINE_DOWNLOAD_TIME_KEY];
            }
            
            [self.baseTableView reloadData];
        });
    });
}

- (void)downloadAudioItem:(NSString *)url andText:(NSString *)text
{
    if ([url length] == 0 || [text length] == 0) {
        return;
    }
    
    NSString* localFilePath;
    localFilePath = [AUDIO_CACHE_FOLDER stringByAppendingPathComponent:[[StringUtils md5:url] lowercaseString]];
    
    if ([[url lowercaseString] hasSuffix:@".mp3"]) {
        localFilePath = [NSString stringWithFormat:@"%@.mp3", localFilePath];
    }
    
    if (localFilePath != nil) 
    {
        if(![[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) 
        {
            self.audioDownloader = [[VisualDownloader alloc]init];
            audioDownloader.title = text;
            audioDownloader.fileURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            audioDownloader.fileName = localFilePath;
            audioDownloader.delegate = self;
            audioDownloader.tag = 2;
            [audioDownloader start];
            
            [self.audioDownloader release];
            
            [[ArticleDownloader shareInstance].audioList removeLastObject];
        }
        else {
            [[ArticleDownloader shareInstance].audioList removeLastObject];
            [self downloadAudio];
        }
    }
}

- (void)downloadAudio
{
    int iCount = [[ArticleDownloader shareInstance].audioList count];
    if (iCount) {
        NSArray *urlList = [ArticleDownloader shareInstance].audioList;
        
        NSString *titleText = [NSString stringWithFormat:NSLocalizedString(@"剩余%d个音频下载", @""), iCount];
        
        [self downloadAudioItem:[urlList lastObject] andText:titleText];
    }
}

#pragma mark ArticleDownloader

- (void) visualDownloaderCancel
{
    [[ArticleDownloader shareInstance] cancel];
    [self.textPictureDownloader.progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)visualDownloaderDidFinish:(NSString *)fileName 
                         download:(VisualDownloader *)aDownloader
{
    if (aDownloader.tag ==2 && [[ArticleDownloader shareInstance].audioList count]) 
    {
        [self downloadAudio];
    }
}

@end

//
//  WebViewController.m
//  iKnow
//
//  Created by Cube on 11-5-1.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "UserLoginViewController.h"
#import "WebViewController.h"
#import "iFavorite.h"
#import "ASIDownloadCache.h"
#import "UIImageView+WebCache.h"

#import "Article.h"
#import "LocalSubstitutionCache.h"
#import "BingTranslator.h"
#import "ReleatedViewController.h"
#import <MessageUI/MessageUI.h>

#import "ShareViewController.h"
#import "SearchWebViewController.h"

#import "FavoriteHelper.h"
#import "TranslatorViewController.h"


static const int ddLogLevel = LOG_FLAG_ERROR;


@implementation WebViewController

@synthesize article, articleList, articlePosition, coverImage = _coverImage;
@synthesize downloader;
@synthesize audioDownloader, playBarButton, pauseBarButton, player, audioPath;

@synthesize contentInfo;

@synthesize selectedWord, word = _word, wordParserList;


@synthesize navBar, webView, activityIndicator, scrubber, wordLabel, accetationLabel;
@synthesize pageDownButton, pageUpButton;
@synthesize favoriteButton, audioButton, commentBarItem;

@synthesize audioPlayingToolbar;
@synthesize articleOperationView;
@synthesize downloadingConfirmedView;
@synthesize wordPanelView;

@synthesize contentImageView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.navBar.tintColor = NAV_BAR_ITEM_COLOR;
    if ([self.navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [ self.navBar setBackgroundImage:[UIImage imageNamed:@"NavBar_ios5.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.navBar.layer.shadowRadius = 3.0f;
    self.navBar.layer.shadowOpacity = 0.8f;

    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    webView.delegate = self;
    
    [downloadingConfirmedView insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_bar.png"]] autorelease] atIndex:0];
    closeWhenFailed = YES;
    
    //设置手势
    [self setupWebViewGesture];
    
    self.wordParserList = [[NSMutableArray alloc] init];
    [wordParserList release];
    
    NSString *articleId = article.Id;
    if ([articleId length] == 0 && articlePosition >= 0 && articlePosition < [articleList count]) {
        self.article = (Article *)[articleList objectAtIndex:articlePosition];
        articleId = self.article.Id;
    }
    
    //设置使用自定义Cache机制
    LocalSubstitutionCache *cache = [[[LocalSubstitutionCache alloc] init] autorelease];
    [cache setMemoryCapacity:4 * 1024 * 1024];
    [cache setDiskCapacity:10 * 1024 * 1024];
    [NSURLCache setSharedURLCache:cache];

    [self loadArticle:articleId];

    XMPPJID *myJID = [iKnowXMPPClient getJID];
    
    if ([iKnowXMPPClient isAdministratorName:[myJID user]])
    {
        deleteButton.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([EnglishFunAppDelegate setNavImage:@"NavBar.png"]){
        [self.navigationController.navigationBar setNeedsDisplay];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
     
    self.navBar = nil;
    self.pageDownButton = nil;
    self.pageUpButton = nil;
    self.pauseBarButton = nil;
    self.playBarButton = nil;
}

//开始登录或者注册
- (void)loginOrRegisterUser
{
    UserLoginViewController *viewController = [[UserLoginViewController alloc] init];
    
    viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
}

- (void)resetControls
{
    isArticleFavorite = FALSE;
    [favoriteButton setImage:[UIImage imageNamed:@"favorite_off.png"] forState:UIControlStateNormal];
    
    [audioPlayingToolbar setHidden:YES];
    [audioPlayingToolbar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_toolbar.png"]] autorelease] 
                   atIndex:0];
    audioButton.enabled = NO;
    
    downloadingConfirmedView.hidden = YES;
    
    self.player = nil;
    self.audioPath = nil;
}

- (void)loadArticle:(NSString *)articleId
{
    if ([articleId length] == 0)
        return;
    
    [downloader cancel];
    self.downloader = [iKnowAPI getContent:article.Id delegate:self useCacheFirst:YES];
    
    if (activityIndicator)
    {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
    }
    
    [self resetControls];
    
    if ([[FavoriteHelper instance] isFavorite:article.Id])
    {
        [favoriteButton setImage:[UIImage imageNamed:@"favorite_on.png"] forState:UIControlStateNormal];
        isArticleFavorite = TRUE;
    }
    
    //set comment number
    if ([article.CommentCount isEqualToString:@"0"]) {
        commentBarItem.title = NSLocalizedString(@"暂无评论", @"");
    }
    else if ([article.CommentCount length] == 0) {
        commentBarItem.title = NSLocalizedString(@"查看评论", @"");
    }
    else {
        commentBarItem.title = [NSString stringWithFormat:NSLocalizedString(@"%@条评论", @""), article.CommentCount];
    }
}


- (void)setupWebViewGesture
{
    //取词长按手势
    UILongPressGestureRecognizer *longPressGestureRecognizer = 
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    
    [self.webView addGestureRecognizer:longPressGestureRecognizer];
    [longPressGestureRecognizer setDelegate:self];
    [longPressGestureRecognizer release];
}


- (void)didFailWithLoadingArticle:(BOOL)articleIsDeleted
{
    [activityIndicator stopAnimating];
    activityIndicator.hidden = YES;
    
    if (articleIsDeleted) {
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:self.webView info:NSLocalizedString(@"文章已被刪除", @"")];
    }
    else {
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showNetworkFailed:self.webView];
    }
    
    if (closeWhenFailed)
        [self performSelector:@selector(closeContent) withObject:nil afterDelay:1.0];
}


#pragma mark -
#pragma mark DownloaderDelegate

- (void)downloader:(Downloader *)downloader didFailWithError:(NSString *)error{
    
    [self didFailWithLoadingArticle:NO];
    
    return;
}

- (void)downloader:(Downloader *)downloader didDownloadData:(NSData *)data {

    if (data == nil)
        return;

    self.contentInfo = [[ContentFormatterFactory example] formatContent:nil contentData:data articleTitle:self.article.Name];
    
    if (self.contentInfo == nil || [self.contentInfo.formattedString length] < 5) {
        [self didFailWithLoadingArticle:YES];
        
        return;
    }
    
    DDLogInfo(@"%@", contentInfo.formattedString);
    
    NSString *basePath = [[NSString alloc] initWithFormat:@"%@%@%@%@", MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH];
    
    [webView loadHTMLString:contentInfo.formattedString baseURL:[NSURL URLWithString:basePath]];
    
    [basePath release];
    
    if (activityIndicator)
    {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
    }
    
    //如果有音频内容
    if(contentInfo.audioList.count > 0)
    {
        //获取音频链接
        NSDictionary* audioDictionary = [contentInfo.audioList objectAtIndex:0];

        if (audioDictionary != nil) 
        {
            NSString* url = [audioDictionary valueForKey:@"downUrl"];
            
            //根据音频链接生成本地文件路径
            NSString* localFilePath;
            localFilePath = [AUDIO_CACHE_FOLDER stringByAppendingPathComponent:[[StringUtils md5:url] lowercaseString]];
            
            if ([[url lowercaseString] hasSuffix:@".mp3"]) {
                localFilePath = [NSString stringWithFormat:@"%@.mp3", localFilePath];
            }
        
            //判断本地是否已存在文件
            if([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) 
            {
                //播放本地文件
                self.audioPath = localFilePath; //TODO!!!
                [self prepareAudio];
            } 
            else 
            {
                downloadingConfirmedView.hidden = NO;
                
                //4秒后自动隐藏
                [self performSelector:@selector(delayDidDownloadPanelShow:) 
                           withObject:nil 
                           afterDelay:4];
            }
        }        
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType != UIWebViewNavigationTypeLinkClicked)
        return YES;
    
    //防止页面已经返回仍然收到UIWebView的回调
    if (willDestroyController)
    {
        return NO;
    }
    
    //分析链接
   NSString *href = [[request URL] absoluteString];
    
    if ([href length] == 0) {
        return NO;
    }
    
    if ([href hasPrefix:@"iKnow://"]) {
        
        NSString *hrefSub = [href substringFromIndex:8];
        NSRange range = [hrefSub rangeOfString:@":"];
        if (range.location == NSNotFound) {
            return NO;
        }
        
        NSRange cmdRange;
        cmdRange.location = 0;
        cmdRange.length = range.location;
        
        NSString *command = [hrefSub substringWithRange:cmdRange];
        
        //如果是图片，显示图片查看页面
        if ([command isEqualToString:@"photo"]) {
            NSRange imageURLRange;
            imageURLRange.length = [hrefSub length] - range.location - 1;
            imageURLRange.location = range.location + 1;
            
            NSString *imageURL = [hrefSub substringWithRange:imageURLRange];
            if ([imageURL length] > 0) {
                willAnimateImage = YES;
                [self showContentImage:imageURL];
            }
        }
    }
    else { //如果是内容链接，打开链接页面
       
        SearchWebViewController *searchViewController = [[SearchWebViewController alloc] init];
        searchViewController.contentUrl = href;
        [self presentModalViewController:searchViewController animated:YES];
        
        [searchViewController release];
    }
    
    return NO;  
}

#define CONTENT_IMAGE_WIDTH  320
#define CONTENT_IMAGE_HEIGHT 480

//显示内容图片
-(void)showContentImage:(NSString *)imageUrl {
    
    //黑色背景
    UIView *backgroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 
                                                                     0, 
                                                                     CONTENT_IMAGE_WIDTH, 
                                                                     CONTENT_IMAGE_HEIGHT)];
    [backgroudView setBackgroundColor:[UIColor colorWithRed:0 
                                               green:0 
                                                blue:0 
                                               alpha:1]];
    backgroudView.alpha = 0.0;
    [self.view.window addSubview:backgroudView];
    [backgroudView release];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //创建关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self action:@selector(closeContentImage:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setFrame:CGRectMake(0,
                                     0, 
                                     CONTENT_IMAGE_WIDTH, 
                                     CONTENT_IMAGE_HEIGHT)];
    [backgroudView addSubview:closeButton];
    
    //创建图像视图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 
                                                                           0, 
                                                                           CONTENT_IMAGE_WIDTH, 
                                                                           CONTENT_IMAGE_HEIGHT)];
    [imageView setCenter:backgroudView.center];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    NSString* localFilePath = [LocalSubstitutionCache pathForURL:imageUrl];
    UIImage *image = [UIImage imageWithContentsOfFile:localFilePath];
    if (image)
    {
        imageView.image = image;
    }
    else 
    {
        [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
    }
    
    [backgroudView addSubview:imageView];
    
    //保存一份以备save to disk使用
    self.contentImageView = imageView;
    [imageView release];
    
    //创建保存按钮
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setImage:[UIImage imageNamed:@"save_to_disk.png"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveContentImage:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setFrame:CGRectMake(CONTENT_IMAGE_WIDTH - 32,
                                    CONTENT_IMAGE_HEIGHT - 32 * 2,
                                    32,
                                    32)];
    [backgroudView addSubview:saveButton];
    
    backgroudView.alpha = 1.0;
    [UIView commitAnimations];
}

-(void)closeContentImage:(UIButton *)button {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.4];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[button superview] removeFromSuperview];
    
    [UIView commitAnimations];
    
    willAnimateImage = NO;
}

-(void)saveContentImage:(UIButton *)button {

    UIImageWriteToSavedPhotosAlbum(self.contentImageView.image, 
                                   self, 
                                   @selector(image:didFinishSavingWithError:contextInfo:), 
                                   nil);
}

-(void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    
    if (error != nil)
    {
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:self.webView info:NSLocalizedString(@"保存失败", @"")];
    }
    else
    {
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:self.webView info:NSLocalizedString(@"已保存至相册", @"")];
    }
}

#pragma mark * UI Actions

- (IBAction)deleteArticle
{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" 
                                                   message:@"确认删除这篇文章？" 
                                                  delegate:self
                                         cancelButtonTitle:@"确定" 
                                         otherButtonTitles:@"取消",nil];
    
    [view show];
    [view release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        BOOL result = [iKnowAPI deleteArticleWithArticleID:self.article.Id];
        
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:self.view info:result ? @"删除成功" : @"删除失败"];
        
        if (result && closeWhenFailed)
            [self performSelector:@selector(closeContent) withObject:nil afterDelay:1.0];
    }
}

- (IBAction)closeContent
{
    //正在显示图片动画，为了防止WebViewController被销毁后动画仍然在进行（导致崩溃）
    if (willAnimateImage)
        return;
    
    willDestroyController = YES;
    
    [self dismissModalViewControllerAnimated:YES];
    [self.player stop];
}

- (IBAction)openComment
{
    // Show comments
    CommentViewController *commentViewController = [[CommentViewController alloc] init];
    commentViewController.articleId = article.Id;
    commentViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //UIModalTransitionStyleCoverVertical/UIModalTransitionStyleCrossDissolve/UIModalTransitionStyleFlipHorizontal
    [self presentModalViewController:commentViewController animated:YES];
    
    [commentViewController release];
}

- (void)setBarButton: (BOOL) isPlaying
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:audioPlayingToolbar.items];
    
    if ([items count] == 0 || pauseBarButton == nil || playBarButton == nil)
        return;
    
    [items removeObjectAtIndex:0];
    [items insertObject:(isPlaying ? pauseBarButton : playBarButton) atIndex:0];
    
    [audioPlayingToolbar setItems:items animated:NO];
}

- (void)updateMeters
{
    if (self.player == nil)
        return;
    
    scrubber.value = (self.player.currentTime / self.player.duration);
}

- (IBAction)pause: (id) sender
{
    if (self.player) [self.player pause];
    
    [self setBarButton:NO];
    scrubber.enabled = NO;
}

- (IBAction)play: (id) sender
{
    if (self.player) [self.player play];
    
    [self setBarButton:YES];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1f 
                                             target:self 
                                           selector:@selector(updateMeters) 
                                           userInfo:nil 
                                            repeats:YES];
    scrubber.enabled = YES;
}

- (IBAction)scrubbbingDone: (id) sender
{
    [self play:nil];
}

- (IBAction)scrub: (id) sender
{
    // Pause the player
    [self.player pause];
    
    // Calculate the new current time
    self.player.currentTime = scrubber.value * self.player.duration;
}

- (IBAction)downloadButtonClicked: (id) sender
{
    downloadingConfirmedView.hidden = YES;
    
    NSDictionary* audioDictionary = [contentInfo.audioList objectAtIndex:0];
    NSString* url = [audioDictionary valueForKey:@"downUrl"];
    
    if (audioDictionary != nil) 
    {
        NSString* localFilePath;
        localFilePath = [AUDIO_CACHE_FOLDER stringByAppendingPathComponent:[[StringUtils md5:url] lowercaseString]];
        
        if ([[url lowercaseString] hasSuffix:@".mp3"]) {
            localFilePath = [NSString stringWithFormat:@"%@.mp3", localFilePath];
        }

        self.audioDownloader = [[VisualDownloader alloc]init];
        audioDownloader.title = NSLocalizedString(@"正在下载", @"");
        audioDownloader.fileURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        audioDownloader.fileName = localFilePath;
        audioDownloader.delegate = self;
        [audioDownloader start];
        
        [self.audioDownloader release];
        
        downloadingConfirmedView.hidden = YES;
    }
}

- (IBAction)cancelButtonClicked: (id) sender
{
    downloadingConfirmedView.hidden = YES;
}

- (void)visualDownloaderDidFinish:(NSString *)fileName 
                         download:(VisualDownloader *)aDownloader
{
    // 返回的fileName为保存的路径
    
    if (self.audioPath == nil)
    {
        self.audioPath = fileName;
        [self prepareAudio];
    }
}

- (void)visualDownloaderDidFail: (NSString *) reason
{
    DDLogError(@"Download audio failed!");
}

- (NSString *)formatTime: (int) num
{
    int secs = num % 60;
    int min = num / 60;
    
    if (num < 60) return [NSString stringWithFormat:@"0:%02d", num];
    
    return [NSString stringWithFormat:@"%d:%02d", min, secs];
}

- (BOOL)prepareAudio
{
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.audioPath]) return NO;
    
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.audioPath] error:&error];
    if (!newPlayer)
    {
        DDLogError(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
    self.player = newPlayer;
    [newPlayer release];
    
    [self.player prepareToPlay];
    
    [audioPlayingToolbar setHidden:NO];
    
    self.playBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(play:)];
    self.pauseBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pause:)];

    [self.playBarButton release];
    [self.pauseBarButton release];
    
    self.player.meteringEnabled = YES;
    self.player.delegate = self;
    [self setBarButton:NO];
    
    audioButton.enabled = YES;

    return YES;
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(customMenuAction:))
        return YES;
    
    return NO;
}

- (IBAction)pageButtonClicked:(UIButton *)sender {
    
    if (sender == pageDownButton) 
    {
        //如果已经到达最后一页
        if (articlePosition + 1 >= [articleList count]) {
            pageDownButton.enabled = NO;
            return;
        }
        else {
            pageDownButton.enabled = YES;
            pageUpButton.enabled = YES;
            articlePosition++;
        }
        
        self.article = (Article *)[articleList objectAtIndex:articlePosition];
        self.coverImage = nil;
        
        [self.webView loadHTMLString:@"" baseURL:nil];
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:self.view 
                                                                     info:[NSString stringWithFormat:@"%d/%d", articlePosition + 1, [articleList count]]];
        [self loadArticle:self.article.Id];
    }
    else if (sender == pageUpButton)
    {
        //如果已经到达第一页
        if (articlePosition == 0) {
            pageUpButton.enabled = NO;
            return;
        }
        else {
            pageDownButton.enabled = YES;
            pageUpButton.enabled = YES;
            articlePosition--;
        }
        
        self.article = (Article *)[articleList objectAtIndex:articlePosition];
        self.coverImage = nil;
        
        [self.webView loadHTMLString:@"" baseURL:nil];
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:self.view 
                                                                     info:[NSString stringWithFormat:@"%d/%d", articlePosition + 1, [articleList count]]];
        [self loadArticle:self.article.Id];
    }
    
    //当翻页按钮被点击后我们不会关闭当前页面，用户可以继续导航到上一篇或下一篇文章
    closeWhenFailed = NO;
}

- (IBAction)delayDidWordPanelShow:(id)sender
{
    //隐藏取词Bar
    wordPanelView.alpha = 1.0;
    
    [UIView beginAnimations:nil 
                    context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    
    wordPanelView.alpha = 0.0;
    
    [UIView commitAnimations];
}

- (IBAction)delayDidDownloadPanelShow:(id)sender
{
    //隐藏Download Bar
    downloadingConfirmedView.hidden = YES;
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSString* selection = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"翻译verb", @"") action:@selector(customMenuAction:)];
    [menuController setMenuItems:[NSArray arrayWithObjects:resetMenuItem, nil]];
    [menuController setMenuVisible:YES animated:YES];
    [resetMenuItem release];
    
    //去掉左右空格
    selection = [selection stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *wordArray = [selection componentsSeparatedByString:@" "];
    if ([wordArray count] > 1) {
        
        //翻译句子
        return;
    }

    //选择的内容为空
    if (selection.length == 0)
    {
        self.selectedWord = @"";
        self.word = nil;
        wordLabel.text = @"";
        accetationLabel.text = @"";
        
        [self delayDidWordPanelShow:nil];
        
        return;
    }
    
    //显示取词Bar
    if (wordPanelView.hidden || wordPanelView.alpha < 0.1)
    {
        wordPanelView.hidden = NO;
        wordPanelView.alpha = 0.0;
    
        [UIView beginAnimations:nil 
                        context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.3];
    
        wordPanelView.alpha = 1.0;
    
        [UIView commitAnimations];
    }
    
    //防止重发查询
    if (_word != nil && [selection isEqualToString:_word.Key])
    {
        if (_word.AcceptationList != nil && [_word.AcceptationList count] > 0)
        {
            NSString *key = [[_word.AcceptationList allKeys] objectAtIndex:0];
            accetationLabel.text = [_word.AcceptationList valueForKey:key];
        }
        else {
            accetationLabel.text = NSLocalizedString(@"未查到释义", @"");
        }

        [self performSelector:@selector(delayDidWordPanelShow:) 
                   withObject:nil 
                   afterDelay:3];
        
        return;
    }
    
    for (Parser *parser in wordParserList) {
        [parser cancel];
    }
    
    Parser *parser = [iKnowAPI queryWordOnline:selection delegate:self useCacheFirst:YES];
    if (parser) {
        [wordParserList addObject:parser];
        
        self.selectedWord = selection;
        wordLabel.text = self.selectedWord;
        accetationLabel.text = NSLocalizedString(@"查找中...", @"");
    }
}

- (void)customMenuAction:(id)sender
{
    if (_word)
    {
        WordCardViewController *wordCardViewController = [[WordCardViewController alloc] init];
        wordCardViewController.word = _word;
        wordCardViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve; //UIModalTransitionStyleCoverVertical/UIModalTransitionStyleCrossDissolve/UIModalTransitionStyleFlipHorizontal
        [self presentModalViewController:wordCardViewController animated:NO];
        
        [wordCardViewController release];
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
        shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer 
{
    return YES;
}


- (void)parser:(Parser *)parser didFailWithError:(NSString *)error {
    
    if ([selectedWord length]) {
        wordLabel.text = self.selectedWord;
        accetationLabel.text = NSLocalizedString(@"单词查找失败", @"");
        self.word = nil;
    }
    else {
        wordLabel.text = @"";
        accetationLabel.text = @"";
    }
    
    [self delayDidWordPanelShow:nil];
}

- (void)parserDidFinish:(Parser *)parser {
    
    if (_word == nil)
    {
        accetationLabel.text = NSLocalizedString(@"未查到释义", @"");
        
        [self performSelector:@selector(delayDidWordPanelShow:) 
                   withObject:nil 
                   afterDelay:3];
        return;
    }
    
    if (_word.Key == nil)
        _word.Key = (selectedWord ? selectedWord : @"");
    
    wordLabel.text = _word.Key;
    
    if ( _word.AcceptationList != nil && [_word.AcceptationList count] > 0)
    {
        NSString *key = [[_word.AcceptationList allKeys] objectAtIndex:0];
        accetationLabel.text = [_word.AcceptationList valueForKey:key];
    }
    else {
        accetationLabel.text = NSLocalizedString(@"未查到释义", @"");
    }
    
    [self performSelector:@selector(delayDidWordPanelShow:) 
               withObject:nil 
               afterDelay:3];
}

- (void)parser:(Parser *)parser didParseWord:(Word *)parsedWord {

    if (parsedWord) self.word = parsedWord;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (IBAction)favoriteButtonClicked:(UIButton *)sender
{
    if (![Client userHasRegistered]) {
        [self loginOrRegisterUser];
        
        return;
    }
        
    if (!isArticleFavorite)
    {
        [favoriteButton setImage:[UIImage imageNamed:@"favorite_on.png"] forState:UIControlStateNormal];
        
        if (article)
        {
            [[FavoriteHelper instance] addFavorite:article];
            isArticleFavorite = TRUE;
        }
    }
    else {
        [favoriteButton setImage:[UIImage imageNamed:@"favorite_off.png"] forState:UIControlStateNormal];
        [self deleteFavorite];
    }
}


- (IBAction)shareButtonClicked:(UIButton *)sender
{   
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"分享内容", @"")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"取消", @"") 
                                               destructiveButtonTitle:nil  
                                                    otherButtonTitles: NSLocalizedString(@"分享到新浪微博", @""),NSLocalizedString(@"分享到人人网", @""),NSLocalizedString(@"分享到腾讯微博", @""),NSLocalizedString(@"邮件分享", @""),nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if (buttonIndex == 4) {
        return;
    }
    
    if (buttonIndex == 3) {
        return [self showEmail];
    }
    
    NSString *sharedTextExcludeUrl = [NSString stringWithFormat:@"【%@】%@",
                                      SAFE_STRING(article.Name), SAFE_STRING(article.Description)];
    
    NSString *imagePath = nil;
    if ([article.SourceImageUrl length]) {
        imagePath = [LocalSubstitutionCache pathForURL:self.article.SourceImageUrl];
    }
    
    UIImage *shareImage = [[[UIImage alloc] initWithContentsOfFile:imagePath] autorelease];
    
    NSString *ShareArticleUrl = [NSString stringWithFormat:@"http://192.168.1.108/post/%@", article.Id];
    
    NSString *shortText = nil;
    
    if (buttonIndex == 1) {
        shortText = [StringUtils trimString:sharedTextExcludeUrl toCharCount:(80 * 2)];
    }
    
    if (buttonIndex == 2 || buttonIndex == 0) {
        shortText = [StringUtils trimString:sharedTextExcludeUrl toCharCount:(140 * 2)];
    }
    
    NSString *sharedText = [NSString stringWithFormat:@"%@%@", shortText, ShareArticleUrl];
    ShareViewController *shareVC = [[ShareViewController alloc] initWithShareText:sharedText 
                                                                         andImage:shareImage 
                                                                          andType:buttonIndex];
    
    shareVC.postImageURL = article.SourceImageUrl;
    shareVC.shareArticleName = article.Name;
    shareVC.article = article;
    
    [self presentModalViewController:shareVC animated:YES];
    
    [shareVC release];  
}

-(void)showEmail
{
    // This sample can run on devices running iPhone OS 2.0 or later  
    // The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
    // So, we must verify the existence of the above class and provide a workaround for devices running 
    // earlier versions of the iPhone OS. 
    // We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
    // We launch the Mail application on the device, otherwise.
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.navigationBar.tintColor = NAV_BAR_ITEM_COLOR;
    picker.mailComposeDelegate = self;
    
    if ([picker.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [picker.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar_ios5.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    [picker setSubject:[NSString stringWithFormat:@"%@", article.Name]];
    
    // Fill out the email body text
    NSString *emailBody = nil;//contentInfo.formattedString;

    emailBody = [NSString stringWithFormat:@"<html><body style='font-size:17px'><p style='text-align:center'><b>%@</b></p><hr/><p>%@</p><p>原文地址：%@</p></body></html>",
                 article.Name, article.Description, [iKnowAPI getShareArticlePath:article.Id]];
    
    [picker setMessageBody:emailBody isHTML:YES];
    
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{    
    NSString *message = nil;
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //message = @"邮件取消";
            break;
        case MFMailComposeResultSaved:
            //message = @"邮件保存";
            break;
        case MFMailComposeResultSent:
            message = NSLocalizedString(@"邮件已经发送", @"");
            break;
        case MFMailComposeResultFailed:
            message = NSLocalizedString(@"邮件发送失败", @"");
            break;
        default:
            message = NSLocalizedString(@"邮件发送失败", @"");
            break;
    }
    
    if (message) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", @"")
                                                        message:message 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"知道了", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:self.view 
                                                                 info:NSLocalizedString(@"没有找到邮箱", @"")];
    /*
	NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
	NSString *body = @"&body=It is raining in sunny California!";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];*/
}


- (IBAction)chapterButtonClicked:(UIButton *)sender
{
    ReleatedViewController *viewController = [[ReleatedViewController alloc] initWithArticle:self.article];
    viewController.delegate = self;
    
    [self presentModalViewController:viewController animated:YES];
    
    [viewController release];
}

- (IBAction)audioButtonClicked:(UIButton *)sender
{
    if (audioPlayingToolbar.hidden) {
        [audioPlayingToolbar setHidden:NO];
        [audioButton setImage:[UIImage imageNamed:@"listen"] forState:UIControlStateNormal];
    }
    else {
        [audioPlayingToolbar setHidden:YES];
        [audioButton setImage:[UIImage imageNamed:@"listen_on"] forState:UIControlStateNormal];
    }

}

- (IBAction) worldPanelViewDidClicked:(id)sender
{
    if ([accetationLabel.text isEqualToString:NSLocalizedString(@"未查到释义", @"")])
    {
        return;
    }
    
    [self customMenuAction:nil];
}

- (IBAction) bingTranslator:(id)sender {

    NSString *articleId = article.Id;
   
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString (@"翻译中，请稍候...",@"");
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        BingTranslator *translator = [[[BingTranslator alloc] init] autorelease]; 
       
        NSString *translatorString = [translator getTranslatorContent:contentInfo.formattedString articleId:articleId];
        
        if (translatorString == nil) {
            hud.labelText = NSLocalizedString (@"抱歉，Google翻译发生故障",@"");
            
            sleep(1);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (translatorString != nil) {
                TranslatorViewController *viewController = [[TranslatorViewController alloc] init];
                viewController.displayContent = translatorString;
                [self presentModalViewController:viewController animated:YES];
                [viewController release];
            }
        });
    });
}

- (BOOL)deleteFavorite
{
    BOOL result = [[FavoriteHelper instance]deleteFavorite:article.Id];
    
    if (result) {
        isArticleFavorite = FALSE;
    }
    
    return result;
}

#pragma mark releatedArticle

- (void)releatedArticle:(Article *)aArticle;
{
    self.article = aArticle;
    self.coverImage = nil;
    
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self loadArticle:self.article.Id];
}

- (void)dealloc {

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSURLCache setSharedURLCache:nil];
    
    self.article = nil;
    self.articleList = nil;
    self.coverImage = nil;
    
    if (self.downloader) {
        [self.downloader cancel];
        self.downloader = nil;
    }
    
    self.audioDownloader = nil;
    self.playBarButton = nil;
    self.pauseBarButton = nil;
    self.player = nil;
    self.audioPath = nil;
    
    self.contentInfo = nil;
    
    for (Parser *parser in wordParserList) {
        [parser cancel];
    }
    self.wordParserList = nil;
    self.selectedWord = nil;
    self.word = nil;
    
    self.navBar = nil;
    self.webView = nil;
    self.activityIndicator = nil;
    self.scrubber = nil;
    self.wordLabel = nil;
    self.accetationLabel = nil;
    
    self.pageDownButton = nil;
    self.pageUpButton = nil;
    
    self.favoriteButton = nil;
    self.audioButton = nil;
    self.commentBarItem = nil;
    
    self.audioPlayingToolbar = nil;
    self.articleOperationView = nil;
    self.downloadingConfirmedView = nil;
    self.wordPanelView = nil;
    
    self.contentImageView = nil;
    
    [super dealloc];
}


@end

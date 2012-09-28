    //
//  BaseTableViewController.m
//  iKnow
//
//  Created by Cube on 11-5-4.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "BaseTableViewController.h"
#import "WebViewController.h"
#import "GlobalDef.h"
#import "ASIDownloadCache.h"
#import "TagDetailsController.h"
#import "FavoriteHelper.h"
#import "ArticleDownloader.h"
#import "WebViewController_iPad.h"

static const int ddLogLevel = LOG_FLAG_ERROR;

#define ARTICLE_DOWNLOADER_KEY       @"text"


@implementation BaseTableViewController

@synthesize articleItems, parser;
@synthesize baseTableView, activityIndicator;

@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize lastUpDate = _lastUpDate;
@synthesize selectID;

@synthesize delegate;

@synthesize textPictureDownloader;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    failedToLoad = NO;
    articleCountBeforeLoading = 0;
    
    CGRect rc = self.view.frame;
    rc.origin.y = 0;
    rc.size.height -= 44;
    
    self.baseTableView = [[[UITableView alloc] initWithFrame:rc 
                                                      style:UITableViewStylePlain] autorelease];
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    [self.view addSubview:self.baseTableView];
    
    self.baseTableView.scrollsToTop = YES;
    
    // Configure the table view.
    self.baseTableView.rowHeight = 70;
    self.baseTableView.backgroundColor = CELL_BACKGROUND;
    self.baseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.baseTableView.userInteractionEnabled = YES;
    self.baseTableView.alpha = 1;
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] 
                                           initWithFrame: CGRectMake(0.0f, -60, SCREEN_WIDTH, 60)];
        view.delegate = self;
        
        [self.baseTableView insertSubview:view atIndex:0];
        self.refreshHeaderView = view;
        [view release];
    }
    
    [_refreshHeaderView refreshLastUpdatedDate];
    
    //如果parser有值说明已经发起了网络请求
    activityIndicator.hidesWhenStopped = YES;
    if (self.parser != nil)
    {
        if (activityIndicator && [activityIndicator isAnimating])
        {
            self.activityIndicator.hidden = YES;
            [self.activityIndicator stopAnimating];
        }
        
        return;
    }
    
    if (articleItems == nil) {
        articleItems = [[NSMutableArray alloc] init];
    }
    
    if (articleItemsCached == nil) {
        articleItemsCached = [[NSMutableArray alloc] init];
    }
    
    BOOL result = [self getArticleList:0 length:SECTION_LENGTH useCacheFirst:YES];
    
    if (result && activityIndicator && ![activityIndicator isAnimating])
    {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (failedToLoad)
    {
        [self refresh];
    }
    else {
        NSTimeInterval sec = [self.lastUpDate timeIntervalSinceNow];
        if (sec <= - 60 * 60) {
            [self enforceRefresh];
        }
    }
}

- (void)enforceRefresh
{
    [_refreshHeaderView enforceRefresh:self.baseTableView];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.baseTableView = nil;
    self.refreshHeaderView = nil;
}

- (void)showArticleList {

    [self.baseTableView reloadData];
    
    if (activityIndicator)
    {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}

//是否允许显示标签详细页面，默认允许。优化交互，
//在某些情况下不允许从标签详细页面进入标签详细页面。
//子类可以覆载该方法
- (BOOL)showTagDetails:(NSString*)tag {
    
    return YES;
}

#pragma mark -
#pragma mark ParserDelegate

- (void)parserDidStart:(Parser *)parser {
    
}

- (void)parser:(Parser *)parser didParseArticle:(Article *)article {
    
    if (!article)
        return;
    
    NSDictionary *userInfo = nil;
    
    int width = [[UIScreen mainScreen] scale] * 200;
    
    article.ImageUrl = [iKnowAPI getThumbImageServerPath:article.ImageUrl thumbWidh:width];
    
    article.AvatarImageUrl = [iKnowAPI getThumbImageServerPath:article.AvatarImageUrl 
                                                     thumbWidh:[[UIScreen mainScreen] scale] * 80];
    
    if (userInfo == nil) 
    {
        if ([article.UserName length] == 0) 
        {
            article.UserName = DEFAULT_NAME;
        }
    }
    else 
    {
        article.UserName = [userInfo objectForKey:@"nickName"];
        
        if ([article.UserName length] == 0) {
            article.UserName = DEFAULT_NAME;
        }
    }

    [articleItemsCached addObject:article];
}


- (void)parserDidFinish:(Parser *)parser {
    
    _reloading = YES;
    
    if ([articleItemsCached count] == 0) //articleItems没有内容
    {
        if (activityIndicator)
        {
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
        }
        
        self.articleItems = [articleItemsCached copy];
        [self.articleItems release];
        [articleItemsCached removeAllObjects];
        if (failedToLoad)
        {
            failedToLoad = NO;
        }

        [self.baseTableView reloadData];
        [self doneLoadingTableViewData];
        
        return;
    }
    
    //如果articleItems没有增长，说明已经请求完所有服务器的文章
    if (articleCountBeforeLoading == [articleItemsCached count] 
        && articleCountBeforeLoading == [articleItems count]) 
    {
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:self.view info:NSLocalizedString(@"沒有更多內容了", @"")];
    }
    
    self.articleItems = [articleItemsCached copy];
    [self.articleItems release];
    [self showArticleList];
    
    if (failedToLoad)
    {
        failedToLoad = NO;
    }
    
    [self doneLoadingTableViewData];
}

- (void)parser:(Parser *)parser didFailWithError:(NSString *)error {

    DDLogError(@"Finished Parsing With Error: %@", error);
    
    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showNetworkFailed:self.view];

    //因为网络错误而使用了Cached Response的我们只提示用户，不做其它处理
    if ([error isEqualToString:@"Use Cached Response"])
        return;
    
    failedToLoad = YES;
    
    [activityIndicator stopAnimating];
    activityIndicator.hidden = NO;

    [self doneLoadingTableViewData];
    [self.baseTableView reloadData];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	
    [_refreshHeaderView egoRefreshScrollViewDidScroll:(UITableView *)scrollView];
    
    if ([delegate respondsToSelector:@selector(baseTableViewDidScroll:)]) {
        [delegate baseTableViewDidScroll:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    [self refresh];
}

- (void)delayDidFinishedLoading
{
    //  model should call this when its done loading
	_reloading = NO;
    
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.baseTableView];
}

- (void)doneLoadingTableViewData {
	
    [self performSelector:@selector(delayDidFinishedLoading) 
               withObject:nil 
               afterDelay:.5];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    //this maybe overwrite by subclass
    if (_lastUpDate == nil) {
        self.lastUpDate = [NSDate date];
    }
	return _lastUpDate;
}


#pragma mark -
#pragma mark UI Action

//文章标签按钮事件处理
- (IBAction)tagButtonClicked:(id)sender {
    
    /*
    if (![Client userHasRegistered]) {
        return [self loginOrRegisterUser];
    }*/
    
    UIButton *button = (UIButton*)sender;
    NSString *tag = [button titleForState:UIControlStateNormal];
    
    if ([tag length] == 0 || ![self showTagDetails:tag])
        return;
    
    // Show tag detail
    TagDetailsController *detailController = [[TagDetailsController alloc] init];
    detailController.articleTag = tag;
    detailController.popupViewController = self;
    
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailController animated:YES];
    
    [detailController release];
}

//收藏按钮点击事件处理，根据tag取得被点击的文章id
- (IBAction)favoriteButtonClicked:(id)sender {
    
    UIButton *clickedButton = (UIButton*)sender;
    
    Article *article = [articleItems count] > clickedButton.tag ? [articleItems objectAtIndex:clickedButton.tag] : nil;
    if (article == nil)
        return;
    
    if (article.isFavorite) 
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 
                                                 0), ^{
            
            if ([[FavoriteHelper instance]deleteFavorite:article.Id])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [clickedButton setImage:[UIImage imageNamed:@"read_later_off"] forState:UIControlStateNormal];
                    article.isFavorite = NO;
                });
            }
        });
    }
    else 
    {
        [[ArticleDownloader shareInstance] reset];
        [ArticleDownloader shareInstance].delegate = self;
        
        if (self.textPictureDownloader == nil) {
            self.textPictureDownloader = [[VisualDownloader alloc] init];
            [self.textPictureDownloader release];
        }
        
        [self.textPictureDownloader createProgressAlertWithMessage:NSLocalizedString(@"正在离线这篇文章", @"")];
        
        [ArticleDownloader shareInstance].userInfo = 
        [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"正在下载"] forKey:@"Article"];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 
                                                 0), ^{
            
            [self downloadArticleFinished:20 withSum:100];
            
            [[ArticleDownloader shareInstance] downloadArticle:article];
            
            [self downloadArticleFinished:100 withSum:100];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.textPictureDownloader close];
            });
            
            if ([[FavoriteHelper instance] addFavorite:article]) 
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [clickedButton setImage:[UIImage imageNamed:@"read_later"] forState:UIControlStateNormal];
                    article.isFavorite = YES;
                });
            }
        });
    }
}

#pragma mark ArticleDownloader

- (void)downloadArticleFinished:(NSInteger)index 
                        withSum:(NSInteger)sum
{
    dispatch_async(dispatch_get_main_queue(), ^{
        float rate = (float)index / sum;
        self.textPictureDownloader.progressView.progress = rate;
        
        NSString *str = [[ArticleDownloader shareInstance].userInfo 
                         objectForKey:ARTICLE_DOWNLOADER_KEY];
        if ([str length]) {
            self.textPictureDownloader.label.text = 
            [NSString stringWithFormat:@"%@ %.2f％", str,100*rate];
        }
        else {
            self.textPictureDownloader.label.text = 
            [NSString stringWithFormat:@"%.2f％", 100*rate];
        }
    });
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (articleItems.count == 0) 
        return 0;
    
    return articleItems.count + 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == [articleItems count]) {
        
        UITableViewCell *cell = [[[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleDefault 
                 reuseIdentifier:nil] autorelease];
        
        cell.textLabel.text = NSLocalizedString(@"显示下20条", @"");
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.backgroundColor = [UIColor blueColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake(90.0f, 23.0f, 25.0f, 25.0f);
        activityView.hidesWhenStopped = YES;
        activityView.tag = 200;
        [cell addSubview:activityView];
        [activityView release];
        
        // set selection color 
        UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame]; 
        backgroundView.backgroundColor = SELECTED_BACKGROUND;
        cell.selectedBackgroundView = backgroundView; 
        [backgroundView release];
        
        return cell;
    }
    
    static NSString *cellIdentifier = @"RTTableViewCell";
    
    RTTableViewCell *articleTableViewCell = (RTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (articleTableViewCell == nil)
    {
        articleTableViewCell = [[RTTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	// set selection color 
        UIView *backgroundView = [[UIView alloc] initWithFrame:articleTableViewCell.frame]; 
        backgroundView.backgroundColor = SELECTED_BACKGROUND;
        articleTableViewCell.selectedBackgroundView = backgroundView; 
        [backgroundView release];
    }
    
    // Configure the cell.
    Article *article = [articleItems count] == 0 ? nil : [articleItems objectAtIndex:indexPath.row];
    if (article) {
        [articleTableViewCell setDataSource:article];
        [articleTableViewCell setFavorite:article.isFavorite 
                                          tagId:indexPath.row 
                                         target:self 
                                         action:@selector(favoriteButtonClicked:)];
        [articleTableViewCell setArticleTags:article.Tags 
                                      target:self 
                                      action:@selector(tagButtonClicked:)];
    }
    
    //is cache hit
    NSString *requestedUrl = [iKnowAPI getContentPath:article.Id];
    if ([EnglishFunAppDelegate UrlCacheHit:requestedUrl]) {
        articleTableViewCell.nameLabel.textColor 
            = [UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1.0];
    }
    
    return articleTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= [articleItems count])
        return 60;
    
    Article *article = [articleItems count] == 0 ? nil : [articleItems objectAtIndex:indexPath.row];
    if (article) {
        return [RTTableViewCell rowHeightForObject:article];
    }
    else {
        return 0.0;
    }
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect
    [self.baseTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == [articleItems count]) {
        
        if (parser && parser.parsing)
            return;
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            
            [(UIActivityIndicatorView *)[cell viewWithTag:200] startAnimating];
            cell.textLabel.text = NSLocalizedString(@"加载中...", @"");
        }

        //请求articleItems后面SECTION_LENGTH长度的文章列表
        [self getArticleList:[articleItems count] length:SECTION_LENGTH useCacheFirst:NO];
        
        articleCountBeforeLoading = [articleItems count];
        
        return;
    }
    
    RTTableViewCell *cell = (RTTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    // Show detail
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        WebViewController *webViewController = [[WebViewController alloc] init];
        webViewController.articleList = articleItems;
        webViewController.articlePosition = indexPath.row;
        webViewController.coverImage = cell.coverImageView.image;
        self.selectID = indexPath;
        webViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
        [self presentModalViewController:webViewController animated:YES];
        
        [webViewController release];
    }
    else {
        WebViewController_iPad *webViewController_iPad = [[WebViewController_iPad alloc] initWithNibName:@"WebView_iPad" bundle:nil];
        
        webViewController_iPad.articleList = articleItems;
        webViewController_iPad.articlePosition = indexPath.row;
        webViewController_iPad.coverImage = cell.coverImageView.image;
        self.selectID = indexPath;
  
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[self.view.superview layer] addAnimation:animation forKey:@"WebView_iPad"];
        
        [self presentModalViewController:webViewController_iPad animated:NO];
    
        [webViewController_iPad release];
    }
}

// Reset and reparse
- (void)refresh {
    
    if (articleItemsCached)
    {
        [articleItemsCached removeAllObjects];
        articleCountBeforeLoading = 0;
    }
    
    if ([self getArticleList:0 length:SECTION_LENGTH useCacheFirst:NO]) {
        
        if (activityIndicator && ![activityIndicator isAnimating])
        {
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];
        }
        
        self.lastUpDate = [NSDate date];
    }
}

- (BOOL)getArticleList:(NSInteger)startPosition length:(NSInteger)length useCacheFirst:(BOOL)useCacheFirst
{
    return YES;
}


- (void)dealloc {
    delegate = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    self.activityIndicator = nil;
    self.articleItems = nil;
    self.selectID = nil;
    
    [parser cancel];
    self.parser = nil;
    
    [articleItemsCached release];
    
    [_lastUpDate release];
    
    self.textPictureDownloader = nil;
    
    [super dealloc];
}


@end

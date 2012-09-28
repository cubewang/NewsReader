    //
//  MainViewController.m
//  EnglishFun
//
//  Created by curer on 11-12-22.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "MainViewController_iPad.h"
#import "ArticleDownloader.h"

#import "SettingViewController_iPad.h"
#import "FavoritesViewController_iPad.h"
#import "WordsViewController_iPad.h"


#define ARTICLE_DOWNLOADER_KEY       @"text"
#define OFFLINE_DOWNLOAD_TIME_KEY   @"offlineDownloadTime"


@implementation MainViewController_iPad

@synthesize tagTobeSet, tagCurrentUsed;

@synthesize audioDownloader;

@synthesize tagList, tableViewCell, tableViewCellNib, tagTableView;

@synthesize settingButton,favoriteButton,wordButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    if (self.tagTobeSet == nil) {
        self.tagCurrentUsed = IKNOW_TAG;
    }
    else {
        self.tagCurrentUsed = self.tagTobeSet;
    }
    
    [super viewDidLoad];
    
    CGRect rc = self.baseTableView.frame;
    rc.origin.x = 200;
    rc.origin.y = 44;
    rc.size.width -= 200;
    self.baseTableView.frame = rc;
    
    self.tagList = [NSArray arrayWithObjects:IKNOW_TAG, TAG_ARRAY, nil];
    self.tableViewCellNib = [UINib nibWithNibName:@"TagTableViewCell" bundle:nil];
    self.tagTableView.scrollsToTop = NO;
    
    [self.settingButton setTitle:NSLocalizedString(@"设置", @"") forState:UIControlStateNormal];
    [self.favoriteButton setTitle:NSLocalizedString(@"收藏", @"") forState:UIControlStateNormal];
    [self.wordButton setTitle:NSLocalizedString(@"生词本 For iPad", @"") forState:UIControlStateNormal];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    
    self.tagTobeSet = nil;
    self.tagCurrentUsed = nil;
    self.audioDownloader = nil;
    
    self.tagList = nil;
    
    self.settingButton = nil;
    self.favoriteButton = nil;
    self.wordButton = nil;
    
    RELEASE_SAFELY(tableViewCell);
    RELEASE_SAFELY(tableViewCellNib);
    
    self.tagTableView = nil;
    
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

- (void)showSetting
{
    SettingViewController_iPad *viewController = [[SettingViewController_iPad alloc] initWithNibName:@"SettingView_iPad" 
                                                                                              bundle:nil];											      
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:viewController animated:YES];
    
    [viewController release];
}

- (void)showWord
{
    WordsViewController_iPad *viewController = [[WordsViewController_iPad alloc] initWithNibName:@"WordsView_iPad" 
                                                                                          bundle:nil];
    
    viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:viewController animated:YES];
    
    [viewController release];
}

- (void)showFavorite
{
    FavoritesViewController_iPad *viewController = [[FavoritesViewController_iPad alloc] initWithNibName:@"FavoritesView_iPad" 
                                                                                                  bundle:nil];
    
    viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:viewController animated:YES];
    
    [viewController release];
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
            
            [[EnglishFunAppDelegate getLeftViewController] refresh];
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

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.baseTableView) {
        
        return [super numberOfSectionsInTableView:tableView];
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.baseTableView) {
        
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    
    switch (section) {
        case 0: return [tagList count];
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if (aTableView == self.baseTableView) {
        
        return nil;
    }
    
    if (0 == section)
        return NSLocalizedString (@"全部栏目",@"");
    else {
        return @"";
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.baseTableView) {
        
        return 0.0;
    }
    
    return 32.0 + 10.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.baseTableView) {
        
        return nil;
    }
    
    NSString *title = [self tableView:self.tagTableView titleForHeaderInSection:section];
    
    UIImageView *headBgView = [[[UIImageView alloc] init] autorelease];
    headBgView.frame = CGRectMake(0, 5, 120, 32);
    headBgView.image = [[UIImage imageNamed:@"tableViewSection_bg_iPad.png"] 
                        stretchableImageWithLeftCapWidth:2 
			topCapHeight:2];
     
    UIView *sectionView = [[UIView alloc] initWithFrame:headBgView.frame];
    [sectionView addSubview:headBgView];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:headBgView.frame] autorelease];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    
    [sectionView addSubview:label];
    
    return [sectionView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (tableView == self.baseTableView) {
        
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.baseTableView) {
        
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    static NSString *CellIdentifier = @"TagTableViewCell";
    
    TagTableViewCell *cell = (TagTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:CellIdentifier
                                                      owner:nil options:nil];
        
        for (id item in nibs) {
            if ([item isKindOfClass:[UITableViewCell class]]) {
                cell = item;
                break;
            }
        }
    }
    
    [cell setBackgroundImage:nil];
    [cell setIcon:nil];
    
    // Configure the data for the cell.
    NSString *tag = @"";
    
    if (indexPath.section == 0) {
        tag = [tagList count] == 0 ? @"" : [tagList objectAtIndex:indexPath.row];
    }
    
    [cell setName:tag];
    
    // set selection color 
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
    [imageView setImage:[UIImage imageNamed:@"select_iPad"]];
    cell.selectedBackgroundView = imageView;
    
    [imageView release];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.baseTableView) {
        
        return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    
    [self setArticleTag:[self.tagList objectAtIndex:indexPath.row]];
    
    // Deselect
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

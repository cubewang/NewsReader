//
//  SettingViewController_iPad.m
//  EnglishFun
//
//  Created by curer on 12-1-4.
//  Copyright 2012 iKnow Team. All rights reserved.
//

#import "SettingViewController_iPad.h"
#import "MainViewController.h"
#import "LeftViewController.h"
#import "XMPPiKnowUserModule.h"
#import "MemberCoreDataObject.h"
#import "SettingCell.h"
#import "VisualDownloader.h"

#import "SDImageCache.h"
#import "ASIDownloadCache.h"

#import "ArticleDownloader.h"
#import "GuideViewController.h"
#import "PasswordViewController_iPad.h"

#define TABLEVIEW_SECTION0_IMAGE_PATH               @"setting_section.png"
#define TABLEVIEW_SECTION1_IMAGE_PATH               @"recommendation_section.png"
#define TABLEVIEW_CELL_SUGGESTION_IMAGE_PATH        @"iKnow.png"

#define ARTICLE_DOWNLOADER_KEY       @"text"
#define OFFLINE_DOWNLOAD_TIME_KEY   @"offlineDownloadTime"

#define SETTINGITEMCOUNT    5

@implementation SettingViewController_iPad

@synthesize nickTextField;
@synthesize nickName;
@synthesize tableView;
@synthesize suggestionView;

@synthesize textPictureDownloader;
@synthesize audioDownloader;
@synthesize titleLabel;
@synthesize backButton;
@synthesize navBar;


- (XMPPiKnowUserModule *)getUserModule
{
    return[[[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient] xmppiKnowUserModule];
}

- (IBAction)closeAction:(id)sender {
    
    BOOL bAnimation = sender != nil;
    
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        
        if (self.presentedViewController) {
            [[self presentedViewController] dismissModalViewControllerAnimated:bAnimation];
        }
        else {
            [self dismissModalViewControllerAnimated:bAnimation];
        }
    }
    else {
        [[self parentViewController] dismissModalViewControllerAnimated:bAnimation];
    }
}


- (void)showChangePassword
{
    passwordViewController_iPad = [[PasswordViewController_iPad alloc]initWithNibName:@"PasswordView_iPad" 
                                                                                               bundle:nil];
    passwordViewController_iPad.modalPresentationStyle = UIModalPresentationFormSheet;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    
    [passwordViewController_iPad.view.layer addAnimation:transition forKey:@"PasswordView_iPad"];
    
    [self.view addSubview:passwordViewController_iPad.view];
}

- (void)Loginout
{
    [[[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient] loginout];
}


- (void)clearData
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = nil;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
        [[SDImageCache sharedImageCache] cleanDisk];
        
        hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
        hud.mode = MBProgressHUDModeCustomView;
        
        sleep(.8f);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            fileSizeInBytes = 0;
            
            [self.tableView reloadData];
        });
    });
}

- (void)sumCacheFileSize
{
    long long n = [StringUtils getFileSize:[[SDImageCache sharedImageCache] getDiskCachePath]];
    long long n2 = [StringUtils getFileSize:[[ASIDownloadCache sharedCache] storagePath]];
    
    n += n2;
    
    fileSizeInBytes = n;
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

- (void)downloadOffline:(BOOL)bAudio
{
    [[ArticleDownloader shareInstance] reset];
    [ArticleDownloader shareInstance].delegate = self;
    [ArticleDownloader shareInstance].bDownLoadAudio = bAudio;
    
    if (self.textPictureDownloader == nil) {
        self.textPictureDownloader = [[VisualDownloader alloc] init];
        [self.textPictureDownloader release];
    }
    
    [self.textPictureDownloader createProgressAlertWithMessage:NSLocalizedString(@"正在离线列表中的文章", @"")];
    self.textPictureDownloader.delegate = self;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 
                                             0), ^{
        
        BOOL bSuccess = NO;
        
        [ArticleDownloader shareInstance].userInfo = 
        [NSDictionary dictionaryWithObject:NSLocalizedString(@"正在下载", @"")
                                    forKey:ARTICLE_DOWNLOADER_KEY];
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        bSuccess = [[ArticleDownloader shareInstance] downloadSync:IKNOW_TAG];
        
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
            
            [self sumCacheFileSize];
            
            if (bSuccess) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] 
                                                          forKey:OFFLINE_DOWNLOAD_TIME_KEY];
            }
            
            [self.tableView reloadData];
        });
    });
}

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.tintColor = NAV_BAR_ITEM_COLOR;
    if ([self.navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [ self.navBar setBackgroundImage:[UIImage imageNamed:@"settingBar_ipad.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.navBar.layer.shadowRadius = 3.0f;
    self.navBar.layer.shadowOpacity = 0.8f;
    
    [self.backButton setTitle:NSLocalizedString(@"返回", @"") forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"设置", @"");
    
    CGRect rc = self.view.frame;
    rc.origin.y = 44;
    rc.size.height -= 44;
    self.view.frame = rc;
    
    
    [[self getUserModule] addDelegate:self delegateQueue:dispatch_get_main_queue()];

    self.tableView = [[[UITableView alloc] initWithFrame:rc 
                                                   style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    // Configure the table view.
    self.view.backgroundColor = self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.userInteractionEnabled = YES;
    self.tableView.alpha = 1;
    
    if (self.suggestionView == nil) {
        self.suggestionView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iKnow_iPad"]] autorelease];
        self.suggestionView.frame = CGRectMake(30, 0, 480, 145);
        
        UITextView *recommendText = [[UITextView alloc] initWithFrame:CGRectMake(120,15,300,100)];
        
        recommendText.textAlignment = UITextAlignmentLeft;
        recommendText.backgroundColor = [UIColor clearColor];
        recommendText.textColor = [UIColor blackColor];
        recommendText.font = [UIFont systemFontOfSize:15.0];
        
        recommendText.text =NSLocalizedString(@"推荐iKnow",@"");

        [self.suggestionView addSubview:recommendText];
        
        [recommendText release];
    }
    [self sumCacheFileSize];
}
    

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {

        return 1;
    }
    else if (section == 1) {
        return 4;
    } 
    else if (section == 2) {
        return 2;
    }else {
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   if (section == 2)
    {
        return [UIImage imageNamed:TABLEVIEW_SECTION1_IMAGE_PATH].size.height;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        if (indexPath.row == 1) {
            return 142;
        }else {
            return 40;
        }
    }
    else {
        return 40;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SettingCell";
    
    SettingCell *cell = (SettingCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SettingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                
        if (indexPath.row == 0 && indexPath.section == 0) {
            CGRect rc = cell.frame;
            rc.size.width -= 180;
            rc.size.height = 20;
            rc.origin.x += 100;
            
            rc.origin.y += 10;
            
            self.nickTextField = [[UITextField alloc] initWithFrame:rc];
            self.nickTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.nickTextField.returnKeyType = UIReturnKeyDone;
            self.nickTextField.placeholder = NSLocalizedString(@"点击设置昵称", @"");
            self.nickTextField.delegate = self;
            
            [cell.contentView addSubview:self.nickTextField];
        }
        
        cell.detailTextLabel.backgroundColor = CELL_BACKGROUND;
        cell.textLabel.backgroundColor = CELL_BACKGROUND;
    }
    
    NSDictionary *userInfo = [[self getUserModule] queryLocalUserInfo];
    
    if (indexPath.section == 0 ) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"昵称", @"");
            self.nickTextField.text = [userInfo objectForKey:@"nickName"];
            self.nickName = self.nickTextField.text;
        }
    }    
    if (indexPath.section == 1) 
    {
        if (indexPath.row == 0){
            if ([Client userHasRegistered]) {
                cell.textLabel.text = NSLocalizedString(@"退出登录", @"");
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100,5,200,30)];
                label.text = [userInfo objectForKey:@"email"];
                label.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview :label];;
                [label release];
        
            }
            else {
                cell.textLabel.text = NSLocalizedString(@"登录", @"");
            }
        }
        else if (indexPath.row == 1){
            cell.textLabel.text = NSLocalizedString(@"清除缓存", @"");
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(120,5,100,30)];
            label.text =  [NSString stringWithFormat:@"%lld M", fileSizeInBytes / (1014 *1024)];
            label.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview :label];;
            [label release];
        }
        else if (indexPath.row == 2) {
            if ([Client userHasRegistered]) {
                cell.textLabel.text = NSLocalizedString(@"修改密码", @"");
                cell.textLabel.textColor = [UIColor blackColor];
                cell.userInteractionEnabled = YES;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
            }
            else {
                cell.textLabel.text = NSLocalizedString(@"修改密码", @"");
                cell.textLabel.textColor = [UIColor grayColor];
                cell.userInteractionEnabled = NO;
            }
    
        }
        else if (indexPath.row == 3){
            cell.textLabel.text = NSLocalizedString(@"离线下载", @"");
            NSDate *date = [[NSUserDefaults standardUserDefaults] 
                            objectForKey:OFFLINE_DOWNLOAD_TIME_KEY];
            if (date) {
                NSString *time = [StringUtils intervalSinceTime:date 
                                                        andTime:[NSDate date]];
                cell.detailTextLabel.text = time;
            }
        }
    }     
    else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"精品推荐",@"");
            cell.userInteractionEnabled = NO;
        }
        else {
            [cell addSubview:self.suggestionView];
        }
    }
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    backgroundView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = backgroundView; 
    
    [backgroundView release];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.nickTextField.text = self.nickName;
    [self.nickTextField resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            [self clearData];
        }
        else if (indexPath.row == 2) {
            if ([Client userHasRegistered])
            {
                [self showChangePassword];
            }
        }
        else if (indexPath.row == 0) {
            if ([Client userHasRegistered]) {
                
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", @"")
                                                               message:NSLocalizedString(@"确定退出登录么？退出登录将不能云收藏，评论为匿名", @"")
                                                              delegate:self 
                                                     cancelButtonTitle:NSLocalizedString(@"取消", @"")
                                                     otherButtonTitles:NSLocalizedString(@"退出登录", @""),nil];
                
                [view show];
                [view release];
            }
            else {
                [[EnglishFunAppDelegate sharedAppDelegate] loginOrRegisterUser:self];
            }
        }
        else if (indexPath.row == 3) {
            
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"离线下载", @"")
                                                           message:NSLocalizedString(@"需要下载文章中附带的音频么", @"")
                                                          delegate:self 
                                                 cancelButtonTitle:NSLocalizedString(@"取消", @"") 
                                                 otherButtonTitles:NSLocalizedString(@"下载", @""),NSLocalizedString(@"不下载", @""),nil];
            view.tag = 1;
            [view show];
            [view release];
        }
    else if (indexPath.row == 5) {
        GuideViewController *guiderViewController = [[GuideViewController alloc] init];
        guiderViewController.isChangeAction = YES;
        
        [self presentModalViewController:guiderViewController animated:YES];
        
        [guiderViewController release];
        }
    }
    else {
        //goto iKnow英语 appstore
       
        if (indexPath.row == 1) {
           
            NSString *buyString = NSLocalizedString (@"iKnowurl",@"");
            
            NSURL *url = [NSURL URLWithString:buyString];
            
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

#pragma mark UITextField

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!bChangeNickname) {
        return;
    }
    
    bChangeNickname = NO;
    
    [[self getUserModule] setUserInfoWithObject:self.nickName
                                         andKey:@"nickName"];
    
    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showPopProgress:self.view 
                                                              andText:@""];
    
    return;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (![Client userHasRegistered]) {
        
        [[EnglishFunAppDelegate sharedAppDelegate] loginOrRegisterUser:self];
        
        return NO;
    }
    
    self.nickName = textField.text;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.nickName = textField.text;
    bChangeNickname = YES;
    [textField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [[self getUserModule] removeDelegate:self];
    
    [nickTextField release];
    [nickName release];
    [tableView release];
    [suggestionView release];
    
    self.backButton = nil;
    self.titleLabel = nil;
    self.navBar = nil;
    [passwordViewController_iPad release];
    
    [super dealloc];
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
        
        return;
    }
    
    if (buttonIndex == 1) {
        [self Loginout];
        [self.tableView reloadData];
    }
    
    return;
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

#pragma mark XMPPiKnowUserModule

- (void)xmppiKnowUserModule:(XMPPiKnowUserModule *)sender 
            userInfoChanged:(MemberCoreDataObject *)memberCoreDataObject
{
    if ([memberCoreDataObject.userId isEqualToString:[[iKnowXMPPClient getJID] user]]) {
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] hidePopProgress:YES 
                                                                  andText:@""];
    }
}

- (void)xmppiKnowUserModule:(XMPPiKnowUserModule *)sender 
                queryFinish:(NSDictionary *)userDic
{
    if ([[userDic objectForKey:@"user_id"] isEqualToString:[[iKnowXMPPClient getJID] user]]) {
        [self.tableView reloadData];
    }
}

@end

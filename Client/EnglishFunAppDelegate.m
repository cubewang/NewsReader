//
//  EnglishFunAppDelegate.m
//  iKnow
//
//  Created by Cube on 11-4-21.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "EnglishFunAppDelegate.h"
#import "XMPPiKnowFramework.h"
#import "iKnowXMPPDelegate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MessageManager.h"
#import "XMPPElement+Delay.h"
#import "iKnowXMPPClient.h"
#import "MessageManager.h"
#import "XMPPReconnect.h"
#import "CustomBadge.h"

#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "SDImageCache.h"

#import "MainViewController.h"
#import "MainViewController_iPad.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "UserLoginViewController.h"
#import "GuideViewController.h"
#import "UserLoginViewController_iPad.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

static NSString *navImgPath = @"NavBar.png";

/*
@implementation UINavigationBar (Customization)

- (void)drawRect:(CGRect)rect {    
    // Add a custom background image to the navigation bar
    UIImage *image = [UIImage imageNamed:navImgPath];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end*/



@implementation EnglishFunAppDelegate

@synthesize window;
@synthesize client;
@synthesize deviceToken;
@synthesize xmppClient = _xmppClient;

@synthesize mainViewController;
@synthesize centerViewController;
@synthesize deckController;


+ (BOOL)setNavImage:(NSString *)imageName {
    if (![imageName isEqualToString:navImgPath]) {
        navImgPath = imageName;
        return YES;
    }
    return NO;
}

+ (UILabel*)createNavTitleView:(NSString *)title {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:20.0f];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = NAVIGATION_TEXT_COLOR;
    [label sizeToFit];
    
    return label;
}

+ (NSString *)getImagePathInDocument {
    NSString *localFilePath = [DOCUMENT_FOLDER stringByAppendingPathComponent:@"Image"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:localFilePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    return localFilePath;
}

+ (NSString *)getAudoPathInDocument {
    NSString *localFilePath = [DOCUMENT_FOLDER stringByAppendingPathComponent:@"Auto"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:localFilePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    return localFilePath;
}

+ (NSString *)deviceUserAgent
{ 
    //Mozilla/5.5 (设备名称;操作系统;设备串号;分片率;用户语言) 产品名称/发布日期 ver/版本号
    NSString *system = [NSString stringWithFormat:@"%@%@", [[UIDevice currentDevice] systemName], 
                        [[UIDevice currentDevice] systemVersion]];
    NSString *device = [NSString stringWithFormat:
                        @"Mozilla/5.5 (%@;%@;%@;640*960;zh-cn) %@/20120808 ver/1.6.0.0",
                        [[UIDevice currentDevice] systemName],
                        system,
                        [[UIDevice currentDevice] uniqueIdentifier],
                        @"voaspecial_iPhone"];
    return device;
}

+ (BOOL)UrlCacheHit:(NSString *)url
{
    if ([url length] == 0) {
        return NO;
    }
    /*
    NSDictionary *headers = [[ASIDownloadCache sharedCache] cachedResponseHeadersForURL:url];
	if (!headers) {
		return NO;
	}*/
    
    NSString *path = 
    [[ASIDownloadCache sharedCache] pathToCachedResponseDataForURL:
      [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    return [path length] != 0;
}

#pragma mark -
#pragma mark Application lifecycle

+ (EnglishFunAppDelegate *)sharedAppDelegate
{
    return (EnglishFunAppDelegate *) [UIApplication sharedApplication].delegate;
}


//开始登录或者注册
- (void)loginOrRegisterUser:(UIViewController *)aViewController;
{
    if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ) {
        
        UserLoginViewController *vc = [[UserLoginViewController alloc] init];
        
        vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.deckController presentModalViewController:vc animated:YES];
        [vc release];
    }
    else {
        
        UserLoginViewController_iPad *vc = [[UserLoginViewController_iPad alloc] initWithNibName:@"UserLoginView_iPad"bundle:nil];
        
        vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [aViewController presentModalViewController:vc animated:YES];
        [vc release];
    }
}

- (Client *)getClient;
{
    return client;
}

- (iKnowXMPPClient *)getXMPPClient{
    return _xmppClient;
}

- (MessageManager *)getMessageManager {
    return [[self getXMPPClient] msgManager];
}

- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

- (NSString *)pathForASIHTTPDownLoadCache
{
    NSString *path = [self pathForTemporaryFileWithPrefix:@"iKnow"];
    return [path stringByAppendingPathComponent:@"Download"];
}

//Called by Reachability whenever status changes.
- (void)reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    if (curReach == internetReach) {
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        
        switch (netStatus)
        {
            case NotReachable:
            {
                DDLogInfo(@"internet Reachability no internet");
            }
                break;
                
            default:
            {
                DDLogInfo(@"internet Reachability has internet begin xmppStart");
                [[[_xmppClient xmppiKnowFramework] xmppReconnect] manualStart];
            }
                break;
        }
    }
}

- (void)networkReachability {
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(reachabilityChanged:) 
                                                 name: kReachabilityChangedNotification 
                                               object: nil];
    
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
    [internetReach startNotifier];
}


- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {  
    [splashView removeFromSuperview];  
    [splashView release];  
}

- (void)setPlayAudioBackground {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

-(void)setup
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [self networkReachability];
    
    NSString *device = [EnglishFunAppDelegate deviceUserAgent];
    DDLogInfo(@"%@", device);
    
    [ASIHTTPRequest setDefaultUserAgentString:device];
    
    _xmppClient = [[iKnowXMPPClient alloc] init];
    [_xmppClient setupStream];
    
    // Override point for customization after application launch.
    if (client == nil)
    {
        client = [[Client alloc] init];
    }
    
    //设置音频后台播放
    [self setPlayAudioBackground];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self setupMainView_iPhone];
    }
    else {
        [self setupMainView_iPad];
    }
    
    [self.window makeKeyAndVisible];
    
     if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
    
         if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ) {
             guideViewController = [[GuideViewController alloc] init];
             [self.window addSubview:guideViewController.view];
         }
     }
}

- (void)setupMainView_iPhone
{
    self.mainViewController = [[[MainViewController alloc] init] autorelease];
    
    // Left & Right
    LeftViewController *leftController = [[LeftViewController alloc] init];
    RightViewController * rightController = [[RightViewController alloc] init];
    
    self.centerViewController = [[[UINavigationController alloc] initWithRootViewController:self.mainViewController] autorelease];
    
    self.deckController =  [[[IIViewDeckController alloc] initWithCenterViewController:self.centerViewController
                                                                                    leftViewController:leftController
                                                                                   rightViewController:rightController] autorelease];
    
    [leftController release];
    [rightController release];
    
    self.deckController.leftLedge = 160;
    self.deckController.rightLedge = 90;
    
    self.window.rootViewController = self.deckController;
}

- (void)setupMainView_iPad
{
    self.window.rootViewController = [[MainViewController_iPad alloc] initWithNibName:@"MainView_iPad" 
                                                                               bundle:nil];
}

- (void)loadingAnimation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone) {
        
        // Make this interesting.
        splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];
        splashView.image = [UIImage imageNamed:@"Default.png"];
        [window addSubview:splashView];
        [window bringSubviewToFront:splashView];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:window cache:YES];
        [UIView setAnimationDelegate:self]; 
        [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
        splashView.alpha = 0.0;
        splashView.frame = CGRectMake(-320 * 0.5, -480 * 0.5, 320 * 2, 480 * 2);
        [UIView commitAnimations];
    }
    else {
        splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 768, 1024)];
        splashView.image = [UIImage imageNamed:@"Default_iPad.png"];
        [window addSubview:splashView];
        [self performSelector:@selector(startupAnimationDone:finished:context:) withObject:nil afterDelay:2];
    }
}

- (void)checkUpdate
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do a taks in the background
        NSDictionary *dic = [iKnowAPI checkUpdate];
        
        // Hide the HUD in the main tread 
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dic && ![[dic objectForKey:@"necessary"] isEqualToString:@"-1"]) 
            {
                NSString *message = [dic objectForKey:@"des"];
                message = [message length] ? message : NSLocalizedString(@"当前有新版本可以更新", @"");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"新版本提醒", @"")
                                                                    message:message 
                                                                   delegate:nil 
                                                          cancelButtonTitle:NSLocalizedString(@"知道了", @"")
                                                          otherButtonTitles:nil];
                
                [alertView show];
                [alertView release];
            }
        });
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [self setup];
    
    [self loadingAnimation];
    
    [self checkUpdate];
    
    //第一次打开软件超过120秒，我们设置标志位以便下一次打开软件时显示评分页面
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showVoteViewTag"]) 
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"voteHaveShownTag"]) 
        {
            [self performSelector:@selector(showVoteView) withObject:nil afterDelay:2];
        } 
    }
    else 
    {
        [self performSelector:@selector(setShowVoteViewTag) withObject:nil afterDelay:30];
    }
    
    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    return YES;
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *buyString = NSLocalizedString(@"rate url", @"");
        
        NSURL *url = [NSURL URLWithString:buyString];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    [self.xmppClient xmppDisconnect];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [self.xmppClient xmppConnect];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    NSManagedObjectContext *context = [client getContext];
    
    NSError *error;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
    
    context = [[_xmppClient xmppiKnowStorage] getContext];

    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)aDeviceToken
{
    NSString * tokenAsString = [[[aDeviceToken description] 
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.deviceToken = tokenAsString;
    
    DDLogInfo(@"the device token is: %@", tokenAsString);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    DDLogInfo(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    for (id key in userInfo) {
        DDLogInfo(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    self.client = nil;
    self.deviceToken = nil;
    self.centerViewController = nil;
    
    [window release];
    
    [self.xmppClient release];
    
    [internetReach release];
    [guideViewController release];
    
    [super dealloc];
}

#pragma mark alertViewDelegate

- (void)setShowVoteViewTag {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showVoteViewTag"];
    
}

- (void)showVoteView {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"voteHaveShownTag"];
    
    CustomAlertView *customAlertView =[[CustomAlertView alloc]initWithCancelbutton:@""
                                                                       OtherButton:@"" 
                                                                          Delegate:self
                                                                         SuperView:self.window];
    
    [customAlertView setAlertBackgroundImage:@"vote_bg.png"];
    [customAlertView alertShow];
    [customAlertView release];        
}

-(void)CustomAlertView:(id)customAlertView buttonClickedAtIndex:(NSInteger)index {
    
    if (index == 0) {
        return;
    }
    
    if (index == 1) {
        
        NSString *buyString = NSLocalizedString(@"rate url", @"");
        NSURL *url = [NSURL URLWithString:buyString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end

@implementation UINavigationBar (Customization)

- (void)drawRect:(CGRect)rect {    
    // Add a custom background image to the navigation bar
    UIImage *image = [UIImage imageNamed:@"NavBar.png"];
    [image drawInRect:CGRectMake(0, 
                                 0,  
                                 self.bounds.size.width, 
                                 self.bounds.size.height)];
}

@end


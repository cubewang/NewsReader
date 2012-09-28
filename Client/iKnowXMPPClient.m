//
//  xmppClient.m
//  iKnow
//
//  Created by curer on 11-9-2.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "LeftViewController.h"

#import "XMPPUserCoreDataStorageObject.h"

#import "XMPPiKnowConfig.h"
#import "XMPPiKnowFramework.h"

#import "iKnowXMPPClient.h"
#import "XMPPInclude.h"
#import "XMPPiKnowUser.h"

#import "ASIFormDataRequest.h"
#import "GCDAsyncSocket.h"

#import "MessageManager.h"
#import "NSObject+ZResult.h"
#import "XMPPJID+iKnow.h"
#import "XMPPRoster+follow.h"

NSString *const kXMPPmyJID = @"iKnowXmppJID";
NSString *const kXMPPmyPassword = @"iKnowXmppPassword";
NSString *const kXMPPmyEmail = @"iKnowXmppEmail";
NSString *const kXMPPmyNickName = @"iKnowXmppNickName";

#define XMPP_DEFAULT_PASSWORD    @"defaultpassword"

#ifdef DEBUG
    static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
    static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

#define XMPP_MESSAGE_TIMEOUT  5

@interface iKnowXMPPClient (PrivateAPI)

- (void)xmppSetXmppid:(NSString *)xmppid andPassword:(NSString *)pwd;
- (void)xmppClearXmppid;

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

- (void)clearLocalRosterData;
- (BOOL)registerUserWithID:(NSString *)userID andPassword:(NSString *)pwd;

@end


@implementation iKnowXMPPClient

@synthesize msgManager;

@synthesize xmppRoster;
@synthesize xmppiKnowMessage;
@synthesize xmppiKnowUserModule;

@synthesize xmppiKnowStorage;
@synthesize xmppRosterStorage;
@synthesize xmppiKnowFramework;

@synthesize xmppViewPresenceDelegate;
@synthesize xmppViewRegisterDelegate;
@synthesize xmppViewLoginDelegate;

+ (XMPPJID *)getJID
{
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");
    
    NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    return [XMPPJID jidWithString:jabberID];
}

- (void)xmppSetXmppid:(NSString *)xmppid andPassword:(NSString *)pwd{
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");

    
    [[NSUserDefaults standardUserDefaults] setObject:xmppid forKey:kXMPPmyJID];
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:kXMPPmyPassword]; 
}

- (void)xmppClearXmppid {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyEmail];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyNickName];
}

+ (NSString *)getUserEmail
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPmyEmail];
}

+ (NSString *)getRegisterNickName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPmyNickName];
}

+ (BOOL)isAdministratorName:(NSString *)name
{
    //TODO：根据XMPP个人信息来判断是否管理员
    return 
    [name isEqualToString:@"abd494e958ac9f6151c1079b296753d7"] || // [[StringUtils md5:@"wangkeweinuaa@gmail.com"] lowercaseString]
    [name isEqualToString:@"7754a317ff391473b5c3681cb9dc6937"] || //[[StringUtils md5:@"kmn.11@163.com"] lowercaseString]
    [name isEqualToString:@"d42b922a5ce03e4444cae40f6367e890"] || //[[StringUtils md5:@"sdhjt@hotmail.com"] lowercaseString]
    [name isEqualToString:@"5abc71b8338d169e1a8e51afdff6d8d0"] || //[[StringUtils md5:@"911@qq.com"] lowercaseString]
    [name isEqualToString:@"93e3eba14126e6178c2e24985639b9ce"] || // [[StringUtils md5:@"wuluanjunnuaa@gmail.com"] lowercaseString]
    [name isEqualToString:@"1bd4084625227b87922b8780133fabbc"] ; // [[StringUtils md5:@"lwj@qq.com"] lowercaseString]
}

+ (BOOL)isOfficialName:(NSString *)name
{
    return [name isEqualToString:@"im_content"];
}

- (void)addDelegate:(id)aDelegate {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");
    
    [multicastXMPPiKnowClientDelegate addDelegate:aDelegate 
                            delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id)aDelegate {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");
    
    [multicastXMPPiKnowClientDelegate removeDelegate:aDelegate];
}

- (BOOL)isOnLine
{
    return isOnLine;
}

- (BOOL)userIsOnLine:(NSString *)userID
{
    XMPPJID *jid = [XMPPJID createJIDWithUserID:userID];
    return [xmppRoster userIsOnLine:jid];
}

#pragma mark -
#pragma mark memory

- (id)init{
    self = [super init];
    if (self) {
        
        multicastXMPPiKnowClientDelegate = [[GCDMulticastDelegate alloc] init];
        
        xmppiKnowStorage = [[XMPPiKnowStorage alloc] init];
        msgManager = [[MessageManager alloc] initWithUserInfoCoreDataStorage:xmppiKnowStorage];
        
        xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
        
        xmppiKnowFramework = [[XMPPiKnowFramework alloc] initWithConnectHostName:XMPP_CONNECT_HOST 
                                                                    resourceName:XMPP_RESOURCE 
                                                                           domin:XMPP_DOMIN];
        
        xmppiKnowFramework.delegate = self;
    }
    
    return self;
}

- (void)dealloc {
    
    xmppiKnowFramework.delegate = nil;
    
    [multicastXMPPiKnowClientDelegate removeAllDelegates];
    [multicastXMPPiKnowClientDelegate release];
    [self teardownStream];
    [msgManager release];
    [managedObjectContext_roster release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [xmppiKnowFramework release];
    
    [super dealloc];
}

#pragma mark - coreData

- (NSManagedObjectContext *)managedObjectContext_roster
{
    NSAssert([NSThread isMainThread],
             @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	
    if (managedObjectContext_roster == nil)
    {
        managedObjectContext_roster = [[NSManagedObjectContext alloc] init];
		
        NSPersistentStoreCoordinator *psc = [xmppRosterStorage persistentStoreCoordinator];
        [managedObjectContext_roster setPersistentStoreCoordinator:psc];
		
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
    }
	
    return managedObjectContext_roster;
}

- (void)contextDidSave:(NSNotification *)notification
{
	NSManagedObjectContext *sender = (NSManagedObjectContext *)[notification object];
	
	if (sender != managedObjectContext_roster &&
	    [sender persistentStoreCoordinator] == [managedObjectContext_roster persistentStoreCoordinator])
	{
		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_roster", THIS_FILE, THIS_METHOD);
		
		dispatch_async(dispatch_get_main_queue(), ^{
            
            NSArray* updates = [[notification.userInfo objectForKey:@"updated"] allObjects];
            for (NSInteger i = [updates count]-1; i >= 0; i--)
            {
                NSManagedObject *mo = [[self managedObjectContext_roster] objectWithID:[[updates objectAtIndex:i] objectID]];
                [mo willAccessValueForKey:nil];
                [mo didAccessValueForKey:nil];
            }
            
            [[self managedObjectContext_roster] mergeChangesFromContextDidSaveNotification:notification];  
        });
    }
}

#pragma mark -
#pragma mark iKnowXMPPDelegate

- (BOOL)xmppConnect {
    
    [self setupStream];
    
    NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
    
    if (jabberID == nil || myPassword == nil) {
        return NO;
    }
    
    XMPPStream *xmppStream = [xmppiKnowFramework xmppStream];
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    XMPPJID *jid = [XMPPJID jidWithString:jabberID];
    
    xmppiKnowFramework.xmppJID = jid;
    xmppiKnowFramework.password = myPassword;
    
    return [xmppiKnowFramework connect];
}

- (void)xmppDisconnect {
    
    [self goOffline];
    [[xmppiKnowFramework xmppStream] disconnect];
    //[_chatDelegate didDisconnect];
    
    //TODO: why xmppdemo do this and where should addDelegate?
    //[self.xmppiKnowvCardTempModule removeDelegate:self];
}

- (void)clearData
{
    NSManagedObjectContext *moc = [self managedObjectContext_roster];
    if (moc == nil) {
        return;
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0];
    
    NSArray *allUsers = [[self managedObjectContext_roster] executeFetchRequest:fetchRequest error:nil];
    
    for (XMPPUserCoreDataStorageObject *user in allUsers)
    {
        [[self managedObjectContext_roster] deleteObject:user];
    }
    
    [managedObjectContext_roster save:nil];
}

- (void)clearLocalRosterData {
    
    [[[self xmppRoster] xmppRosterStorage] clearAllUsersAndResourcesForXMPPStream:nil];
    
    [self clearData];
}

- (BOOL)registerUserWithID:(NSString *)userID andPassword:(NSString *)password {
    if ([userID length] == 0 || [password length] == 0) {
        return NO;
    }
    
    XMPPJID *jid = [XMPPJID createJIDWithUserID:userID];
    [self xmppSetXmppid:[jid full] 
            andPassword:password];

    XMPPiKnowResult res = [xmppiKnowFramework registerWithUser:userID 
                                                   andPassword:password];
    
    return res == XMPPiKnowResult_OK;
}

- (BOOL)registerUserWithEmail:(NSString *)email andPassword:(NSString *)pwd
{
    if ([email length] == 0)
    {
        return NO;
    }
    
    NSString *userID = [XMPPJID userWithEmail:email];
    NSString *password = nil;
    
    if ([pwd length] == 0)
        password = XMPP_DEFAULT_PASSWORD;
    else {
        password = pwd;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:kXMPPmyEmail];
    
    return [self registerUserWithID:userID andPassword:password];
}

- (BOOL)registerUserWithEmail:(NSString *)email 
                  andPassword:(NSString *)pwd 
                  andNickName:(NSString *)nickName
{
    [[NSUserDefaults standardUserDefaults] setObject:nickName ? nickName : @"" 
                                              forKey:kXMPPmyNickName];
    return [self registerUserWithEmail:email 
                           andPassword:pwd];
}

- (BOOL)sendMessage:(NSString *)messageStr 
           withUser:(NSString *)chatWithUserID 
            andUUID:(NSString *)uuid
{
    return [xmppiKnowMessage sendTextMessage:messageStr 
                                    withUser:chatWithUserID 
                                     andUUID:uuid];
}


- (BOOL)sendImageMessage:(NSString *)imageName 
                widhUser:(NSString *)userID
                 andUUID:uuid
{
    /*
    NSString *imagePath = [EnglishFunAppDelegate getImagePathInDocument];
    [imagePath stringByAppendingPathComponent:imageName];
    
    return [xmppiKnowMessage sendImageMessage:imagePath 
                                     widhUser:userID 
                                      andUUID:uuid];*/
    return NO;
    // not implement
}

#pragma mark -
#pragma mark XMPP methods

// Configure the xmpp stream
- (void)setupStream
{
    BOOL bRes = [xmppiKnowFramework setupStream];
    if (bRes)
        return;
    
    XMPPStream *xmppStream = [xmppiKnowFramework xmppStream];
    XMPPIQRequest *iqRequestModule = [xmppiKnowFramework iqRequestModule];
    // Setup roster
    // 
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    RELEASE_SAFELY(xmppRoster);
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage 
                                             xmppIQRequest:iqRequestModule];
    
    [xmppRoster setAutoRoster:NO];
    
    RELEASE_SAFELY(xmppiKnowMessage);
    xmppiKnowMessage = [[XMPPiKnowMessage alloc] init];
    
    /*
    RELEASE_SAFELY(xmppPubSub);
    
    xmppPubSub = [[XMPPPubSub alloc] initWithServiceJID:[XMPPJID jidWithString:XMPP_DOMIN]];*/
    
    RELEASE_SAFELY(xmppiKnowUserModule);
    xmppiKnowUserModule = [[XMPPiKnowUserModule alloc] initWithDispatchQueue:dispatch_get_main_queue()
                                                                  andStorage:xmppiKnowStorage];
    
    // Activate xmpp modules
    
    [xmppRoster activate:xmppStream];

    [xmppiKnowMessage activate:xmppStream];
    
    [xmppiKnowUserModule activate:xmppStream];
    [xmppiKnowUserModule activeIQRequest:iqRequestModule];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppiKnowMessage addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppiKnowUserModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)teardownStream
{
    [xmppRoster removeDelegate:self];
    [xmppiKnowMessage removeDelegate:self];
    [xmppiKnowUserModule removeDelegate:self];
    
    [xmppRoster deactivate];
    [xmppiKnowMessage deactivate];
    [xmppiKnowUserModule deactivate];

    RELEASE_SAFELY(xmppRoster);
    RELEASE_SAFELY(xmppiKnowMessage);
    RELEASE_SAFELY(xmppiKnowUserModule);
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[xmppiKnowFramework xmppStream] sendElement:presence];
    
    isOnLine = YES;
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[xmppiKnowFramework xmppStream] sendElement:presence];
    
    isOnLine = NO;
}

- (BOOL)addFollowSync:(NSString *)userID
{
    //invoke in any thread 
    if  ([userID length] == 0)
        return NO;
    
    return [xmppRoster addFollowSync:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", 
                                                             userID, XMPP_DOMIN]]];
}
- (BOOL)removeFollowSync:(NSString *)userID
{
    if ([userID length] == 0)
        return NO;
    
    return [xmppRoster removeFollowSync:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", 
                                                                userID, XMPP_DOMIN]]];
}

- (BOOL)loginAdministrator:(NSString *)adminName andPassword:(NSString *)password 
{
    if ([adminName length] == 0 || [password length] == 0)
        return NO;
    
    if (![iKnowXMPPClient isAdministratorName:adminName])
        return NO;
    
    return [self loginWithEmail:adminName
                    andPassword:password];
}

- (BOOL)loginWithEmail:(NSString *)email andPassword:(NSString *)password 
{
    if ([email length] == 0)
    {
        return NO;
    }
    
    NSString *xmppid = nil;
    
    if ([iKnowXMPPClient isAdministratorName:email])
    {
        xmppid = [[XMPPJID jidWithUser:email 
                               domain:XMPP_DOMIN 
                             resource:XMPP_RESOURCE] full];
    }
    else {
        xmppid = [[XMPPJID jidWithEmail:email] full];
    }
    
    if ([password length] == 0)
    {
        password = XMPP_DEFAULT_PASSWORD;
    }
    
    [self loginout];
    
    [self xmppSetXmppid:xmppid andPassword:password];
    
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:kXMPPmyEmail];
    
    return [self xmppConnect];
}

- (void)loginout {
    
    [xmppiKnowUserModule setUserInfoWithObjectSync:nil 
                                            andKey:@"deviceCode"];
    
    [xmppiKnowFramework loginout];
    
    [ASIHTTPRequest clearSession];
    [self xmppClearXmppid];
    
    [self clearLocalData];
}

- (void)clearLocalData
{
    [self clearLocalRosterData];
    [xmppiKnowStorage clearAllMessage];
}

- (void)bindSessionSync:(BOOL)bRefreshCookie;
{
    __block ASIFormDataRequest *request = nil;
    //invoke in any thread 
    ASIBasicBlock block = ^{
        NSString *jsessionID = nil;
        NSArray *newCookies = [ASIHTTPRequest sessionCookies];
        NSHTTPCookie *cookie = nil;
        for (cookie in newCookies) 
        {
            DDLogVerbose(@"session name %@, value %@", [cookie name], [cookie value]);
            if ([[cookie name] isEqualToString:@"JSESSIONID"])
            {
                jsessionID = [[[cookie value] copy] autorelease];
            }
        }
        
        if ([jsessionID length] == 0)
        {
            id jsonObject = [[request responseString] JSONValue];
            if ([jsonObject isKindOfClass:[NSDictionary class]]) 
            {
                NSDictionary *dic = (NSDictionary *)jsonObject;
                jsessionID = [dic objectForKey:@"sid"];
            }
        }
        
        if ([jsessionID length])
        {
            NSXMLElement *sessionBind = [NSXMLElement elementWithName:@"session_bind" 
                                                                xmlns:@"http://192.168.1.108/xmpp/iq/session_bind"];
            [sessionBind addAttributeWithName:@"sid" stringValue:jsessionID];
            
            NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
            [iq addAttributeWithName:@"type" stringValue:@"set"];
            [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
            [iq addChild:sessionBind];
            
            XMPPElementReceipt *recepit = nil;
            [[xmppiKnowFramework xmppStream] sendElement:iq 
                      andGetReceipt:&recepit];
            [recepit wait:15];
        } 
    };
    
    NSArray *cookies = [ASIHTTPRequest sessionCookies];
    if ([cookies count] && !bRefreshCookie)
    {
        block();
    }
    else
    {
        NSString *loginUrl =  [NSString stringWithFormat:@"%@%@%@%@%@", 
                MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH, JSESSION_PATH];
        
        request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:loginUrl]];
        
        [request setUseCookiePersistence:YES];
        [request setFailedBlock:^{
            
             NSError *error = [request error];
             if (error)
             {
                 DDLogError(@"Error: %@ %@ %@", 
                            [error localizedDescription], 
                            THIS_FILE, 
                            THIS_METHOD);
                 return;// return from block
             }
        }];
        
        [request setCompletionBlock:block];
        [request startSynchronous];
    }
}

- (id <XMPPUser>)fetchXMPPUser:(NSString *)userID 
{    
    if ([userID length] == 0)
        return nil;
    
    NSString *JIDstr = [NSString stringWithFormat:@"%@@%@", userID, XMPP_DOMIN];
    
    return [xmppRoster userForJID:[XMPPJID jidWithString:JIDstr]];
}

#pragma mark -
#pragma mark XMPP delegate

- (void)XMPPLoginFinished:(XMPPiKnowFramework *)framework
{
    //xmpp登录完毕之后，需要绑定jsessionid
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self bindSessionSync:YES];
    });
    
    if ([xmppViewLoginDelegate respondsToSelector:@selector(loginFinished)]) 
    {
        [xmppViewLoginDelegate loginFinished];
    }
    else if ([xmppViewRegisterDelegate respondsToSelector:@selector(loginFinished)]) 
    {
        [xmppViewRegisterDelegate loginFinished];
    }
    
    //[self goOnline];
    
    //push code
    NSString *deviceCode = [[EnglishFunAppDelegate sharedAppDelegate] deviceToken];
    if ([deviceCode length]) {
        [xmppiKnowUserModule setUserInfoWithObject:deviceCode 
                                            andKey:@"deviceCode"];
    }
    
    if ([framework isNewRegisterUser]) 
    {
        //用户第一次登录，也就是注册之后
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self addFollowSync:IKNOW_OFFICIAL_ID];
        });
        
        NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPmyEmail];
        [xmppiKnowUserModule setUserInfoWithObject:email 
                                            andKey:@"email"];
        
        NSString *nickName = [iKnowXMPPClient getRegisterNickName];
        if ([nickName length])
        {
            [xmppiKnowUserModule setUserInfoWithObject:nickName 
                                                andKey:@"nickName"];
        }
    }
    else {
        NSDictionary *userInfo = [xmppiKnowUserModule queryLocalUserInfo];
        
        if ([[userInfo objectForKey:@"email"] length] == 0) {
            //登录成功，检查本地email 为空
            NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPmyEmail];
            if ([email length]) {
                [xmppiKnowUserModule setUserInfoWithObject:email 
                                                    andKey:@"email"];
            }
        }
    }
    
    [xmppiKnowUserModule queryUserInfo];
}
- (void)XMPPLoginError:(XMPPiKnowFramework *)framework 
             withError:(NSString *)errorStr
{
    if ([xmppViewLoginDelegate respondsToSelector:@selector(loginError:)]) {
        [xmppViewLoginDelegate loginError:errorStr];
        
        DDLogError(@"login failed");
        [self xmppClearXmppid];
    }
    else if ([xmppViewRegisterDelegate respondsToSelector:@selector(loginError:)]) {
        [xmppViewRegisterDelegate loginError:errorStr];
        
        DDLogError(@"login failed");
        [self xmppClearXmppid];
    }
}

- (void)XMPPRegisterFinished:(XMPPiKnowFramework *)framework
{
    if ([xmppViewRegisterDelegate respondsToSelector:@selector(registerFinished)]) 
    {
        [xmppViewRegisterDelegate registerFinished];
    }
}

- (void)XMPPRegisterError:(XMPPiKnowFramework *)framework 
                withError:(NSString *)errorStr
{
    if ([xmppViewRegisterDelegate respondsToSelector:@selector(registerError:)]) 
    {
        DDLogError(@"register failed");
        
        [xmppViewRegisterDelegate registerError:errorStr];
        [self xmppClearXmppid];
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    
    DDLogError(@"xmppStreamDidDisconnect");
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    if ([[presence type] isEqualToString:@"subscribe"])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            NSDictionary *userInfo = [xmppiKnowUserModule 
                                        queryUserInfoWithUserIDSync:[[presence from] user]];
            if (userInfo == nil)
                return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *name = [userInfo objectForKey:@"nickName"];
                if ([name length] == 0)
                    name = DEFAULT_NAME;
                
                NSString *text = [NSString stringWithFormat:NSLocalizedString(@"%@关注了您", @""), name];
                
                [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:nil 
                                                                             info:text];
            });
        });
    }
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence {
    [xmppRoster acceptBuddyRequest:[presence from]];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error
{
    //<stream:error xmlns:stream="http://etherx.jabber.org/streams">
    //<conflict xmlns="urn:ietf:params:xml:ns:xmpp-streams">
    //</conflict>
    //</stream:error>
    
    NSXMLElement *conflict = [error elementForName:@"conflict" 
                                                    xmlns:@"urn:ietf:params:xml:ns:xmpp-streams"];
    if (conflict)
    {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil 
                                                       message:NSLocalizedString(@"您的帐号已在别处登录，您被迫下线", @"")  
                                                      delegate:nil 
                                             cancelButtonTitle:NSLocalizedString(@"确定", @"")
                                             otherButtonTitles:nil     
                             ];
        [view show];
        [view release];
    }
}

#pragma mark XMPPiKnowMessageDelegate

- (void)xmppiKnowMessage:(XMPPiKnowMessage *)sender 
          didSendMessage:(XMPPMessage *)message 
{
    if ([message isChatMessage])
    {
        //MessageManager *msgManager = [[EnglishFunAppDelegate sharedAppDelegate] getMessageManager];
        [msgManager handleDidSendMessage:message];   
    }
}

- (void)xmppiKnowMessage:(XMPPiKnowMessage *)sender 
       didReceiveMessage:(XMPPMessage *)message 
{
    if ([message isChatMessage])
    {
        //MessageManager *msgManager = [[EnglishFunAppDelegate sharedAppDelegate] getMessageManager];
        [msgManager handleReceivedXMPPMessage:message];   
    }
}

#pragma mark XMPPUserInfoMudule

- (void)chanagedPasswordFinish:(XMPPiKnowUserModule *)sender 
               withNewPassword:(NSString *)password
{
    NSParameterAssert(password);
    
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:kXMPPmyPassword];
}

#pragma mark PubSub

/*
- (void)xmppPubSub:(XMPPPubSub *)sender didSubscribe:(XMPPIQ *)iq;
//- (void)xmppPubSub:(XMPPPubSub *)sender didCreateNode:(NSString *)node withIQ:(XMPPIQ *)iq;
- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveMessage:(XMPPMessage *)message;
- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveError:(XMPPIQ *)iq;
- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveResult:(XMPPIQ *)iq;*/

@end

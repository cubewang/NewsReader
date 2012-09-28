//
//  XMPPiKnowFramework.m
//  iKnow
//
//  Created by curer on 11-11-22.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPiKnowFramework.h"
#import "XMPPInclude.h"
#import "DDLog.h"

enum { 
    STATE_IKNOW_XMPP_NO_LOGIN = 0,
	STATE_IKNOW_XMPP_WILL_REGISTER = 1,
    STATE_IKNOW_XMPP_LOGINED = 2
};

enum { 
    REGISTER_RESULT_INVALID = 0,
    REGISTER_RESULT_ERROR = 1,
    REGISTER_RESULT_CONFLICT = 2
};

enum  {
    LOGIN_RESULT_INVALID = 0,
    LOGIN_RESULT_CONFLICT_ERROR = 1,
    LOGIN_RESULT_NETWORK_OR_SERVER_ERROR = 2,
    LOGIN_RESULT_USERORPASSWORD_ERROR = 3
};

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface  XMPPiKnowFramework(PrivateAPI)

- (void)setupStream;
- (void)teardownStream;

@end


@implementation XMPPiKnowFramework

@synthesize connectHost;
@synthesize resourceName;
@synthesize xmppJID;
@synthesize password;
@synthesize delegate;

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize iqRequestModule;

- (id)initWithConnectHostName:(NSString *)hostName 
                 resourceName:(NSString *)resName
                        domin:(NSString *)aDomin
{
    if (self = [super init]) {
        connectHost = [hostName copy];
        resourceName = [resName copy];
        domin = [aDomin copy];
    }
    
    return self;
}

// Configure the xmpp stream
- (BOOL)setupStream
{
    // Setup xmpp stream
    // 
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    if (xmppStream)
    {
        return YES;
        //[xmppStream release];
        //xmppStream = nil;
        //[self teardownStream];
    }
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        // 
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    RELEASE_SAFELY(iqRequestModule);
    iqRequestModule = [[XMPPIQRequest alloc] init];
    
    // Setup roster
    // 
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    // Setup reconnect
    // 
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    RELEASE_SAFELY (xmppReconnect);
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup capabilities
    // 
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    // 
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    // 
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    //id <XMPPCapabilitiesStorage> capsStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    
    //RELEASE_SAFELY(xmppCapabilities);
    //xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:capsStorage];
    
    //xmppCapabilities.autoFetchHashedCapabilities = YES;
    //xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    //RELEASE_SAFELY(xmppAutoPing);
    //xmppAutoPing = [[XMPPAutoPing alloc] init];
    
    //RELEASE_SAFELY(xmppPing);
    //xmppPing = [[XMPPPing alloc] init];
    
    /*
     RELEASE_SAFELY(xmppPubSub);
     
     xmppPubSub = [[XMPPPubSub alloc] initWithServiceJID:[XMPPJID jidWithString:XMPP_DOMIN]];*/
    
    // Activate xmpp modules
    
    [xmppReconnect activate:xmppStream];
    //[xmppCapabilities activate:xmppStream];

    //[xmppAutoPing activate:xmppStream];
    //[xmppPing activate:xmppStream];
    
    [iqRequestModule activate:xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    /*
     [xmppPubSub addDelegate:self delegateQueue:dispatch_get_main_queue()];
     [xmppPubSub addDelegate:xmppiKnowUserAvatar 
     delegateQueue:xmppiKnowUserAvatar.moduleQueue];*/
    
    //[xmppAutoPing addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //xmppAutoPing 我们不需要接受任何delegate
    // Optional:
    // 
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    // 
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    // 
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    NSParameterAssert(connectHost);
    [xmppStream setHostName:connectHost];
    //[xmppStream setHostPort:5222];    
    
    
    // You may need to alter these settings depending on the server you're connecting to
    //allowSelfSignedCertificates = NO;
    //allowSSLHostNameMismatch = NO;
    
    return NO;
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    
    [xmppReconnect deactivate];
    [xmppCapabilities deactivate];
    [xmppAutoPing deactivate];
    [xmppPing deactivate];
    [iqRequestModule deactivate];
    
    [xmppStream disconnect];
    
    RELEASE_SAFELY(xmppStream);
    RELEASE_SAFELY(xmppReconnect);
    RELEASE_SAFELY(xmppCapabilities);
    RELEASE_SAFELY(xmppPing);
    RELEASE_SAFELY(xmppAutoPing);
    RELEASE_SAFELY(iqRequestModule);
}

-(BOOL)connect
{
    NSParameterAssert([domin length]);
    NSParameterAssert([resourceName length]);
    
    if (xmppJID == nil || password == nil) {
        return NO;
    }
    
    [self setupStream];
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    [xmppStream setMyJID:xmppJID];
    
    NSError *error = nil;
    if (![xmppStream connect:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                            message:[NSString stringWithFormat:@"抱歉，我们连接服务器遇到错误： %@", [error localizedDescription]]  
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Ok" 
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    [xmppStream disconnect];
}

- (BOOL)isNewRegisterUser
{
    return isNewUser;
}

- (void)loginout 
{
    [self disconnect];
    self.xmppJID = nil;
    self.password = nil;
}

- (XMPPiKnowResult)loginWithUser:(NSString *)aUser 
                     andPassword:(NSString *)aPassword
{
    if ([aUser length] == 0 || [aPassword length] == 0)
        return XMPPiKnowResult_paramErr;
    
    self.xmppJID = [XMPPJID jidWithUser:aUser domain:domin resource:resourceName];
    self.password = aPassword;
    
    loginResult = LOGIN_RESULT_INVALID;
    
    return [self connect] ? XMPPiKnowResult_OK : XMPPiKnowResult_networkErr;
}

- (XMPPiKnowResult)registerWithUser:(NSString *)aUser 
                        andPassword:(NSString *)aPassword
{
    if ([aUser length] == 0 || [aPassword length] == 0)
        return XMPPiKnowResult_paramErr;
    
    registerResult = REGISTER_RESULT_INVALID;
    
    self.xmppJID = [XMPPJID jidWithUser:aUser domain:domin resource:resourceName];
    self.password = aPassword;
    [xmppStream setMyJID:self.xmppJID];
    
    NSError *error;
    if ([xmppStream connect:&error]) {
        clientStatus = STATE_IKNOW_XMPP_WILL_REGISTER;
        return XMPPiKnowResult_OK;
    }
    else {
        return XMPPiKnowResult_networkErr;
    }
}

- (XMPPiKnowResult)changePasswordWithUser:(NSString *)aUser 
                              andPassword:(NSString *)aPassword
{
    return 0;
}

- (void)dealloc
{
    [self teardownStream];
    [connectHost release];
    [resourceName release];
    [xmppJID release];
    [domin release];
    [password release];
    
    [super dealloc];
}

#pragma mark XMPPStreamDelegate

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    
    NSError *error = nil;
        
    if (xmppJID == nil)
    {
        DDLogError(@"未注册用户");
        //这是一个未注册用户
        [xmppStream disconnect];
        return;
    }
    
    if (password == nil)
    {
        DDLogError(@"用户密码空");
        return;
    }
    
    if (clientStatus == STATE_IKNOW_XMPP_WILL_REGISTER) {
        [xmppStream registerWithPasswordEx:password error:&error];
    }
    else {
        [xmppStream authenticateWithPassword:password error:&error];
    }
    
    clientStatus = 0;
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    
    DDLogError(@"xmppStreamDidDisconnect");
    
    if ([delegate respondsToSelector:@selector(XMPPLoginError:withError:)]) {
        
        if (loginResult == LOGIN_RESULT_USERORPASSWORD_ERROR)
        {
            [delegate XMPPLoginError:self 
                       withError:@"用户名或密码不正确"];
        }
        else if (loginResult == LOGIN_RESULT_CONFLICT_ERROR){
            [delegate XMPPLoginError:self 
                       withError:@"该用户已在线，登录失败"];
        }
        else {
            [delegate XMPPLoginError:self 
                       withError:@"网络错误"];
        }
        
        loginResult = LOGIN_RESULT_INVALID;
    }
    
    if ([delegate respondsToSelector:@selector(XMPPRegisterError:withError:)]) 
    {
        if (registerResult == REGISTER_RESULT_CONFLICT)
        {
            [delegate XMPPRegisterError:self 
                          withError:@"注册失败，该邮箱已经注册"];
        }
        else {
            [delegate XMPPRegisterError:self 
                          withError:@"网络错误"];
        }
        
        registerResult = REGISTER_RESULT_INVALID;
    }
}

- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender
{
    self.password = nil;
    self.xmppJID = nil; 
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender 
{
    if ([delegate respondsToSelector:@selector(XMPPLoginFinished:)]) 
    {
        [delegate XMPPLoginFinished:self];
    }
    
    if (isNewUser)
    {
        isNewUser = NO;
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    
    self.xmppJID = nil;
    self.password = nil;
    
    [xmppStream disconnectAfterSending];
    
    NSXMLElement *errorElement = [error elementForName:@"error"];
    NSXMLElement *conflict = [errorElement elementForName:@"conflict" 
                                                    xmlns:@"urn:ietf:params:xml:ns:xmpp-stanzas"];
    if (conflict)
    {
        loginResult = LOGIN_RESULT_CONFLICT_ERROR;
    }
    else {
        loginResult = LOGIN_RESULT_USERORPASSWORD_ERROR;
    }
}

#pragma mark -
#pragma mark XMPP register

/**
 * This method is called after registration of a new user has successfully finished.
 * If registration fails for some reason, the xmppStream:didNotRegister: method will be called instead.
 **/
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    
    NSError *error;
    [xmppStream authenticateWithPassword:password error:&error];
    
    clientStatus = 0;
    
    if ([delegate respondsToSelector:@selector(XMPPRegisterFinished:)]) {
        [delegate XMPPRegisterFinished:self];
    }
    
    isNewUser = YES;
}

/**
 * This method is called if registration fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error {
    
    NSXMLElement *errorElement = [error elementForName:@"error"];
    NSXMLElement *conflict = [errorElement elementForName:@"conflict" 
                                                    xmlns:@"urn:ietf:params:xml:ns:xmpp-stanzas"];
    if (conflict)
    {
        registerResult = REGISTER_RESULT_CONFLICT;
    }
    else {
        registerResult = REGISTER_RESULT_ERROR;
    }

    [xmppStream disconnectAfterSending];
}

@end

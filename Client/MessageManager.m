//
//  MessageManager.m
//  iKnow
//
//  Created by curer on 11-7-21.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "MessageManager.h"
#import "Client.h";
#import "SessionCoreDataObject.h"
#import "MemberCoreDataObject.h"
#import "MessageCoreDataObject.h"

#import "XMPP.h"
#import "XMPPRoster.h"
#import "XMPPUser.h"
#import "XMPPElement+Delay.h"
#import "iKnowXMPPClient.h"
#import "XMPPiKnowMessage.h"
#import "Message.h"
#import "XMPPMessage+iKnowMessage.h"

#import "XMPPiKnowUserModule.h"


static const int ddLogLevel = LOG_FLAG_ERROR;


@interface MessageManager (PrivateAPI)

- (BOOL)SendMessage:(MessageCoreDataObject *)message andProgressView:(UIProgressView *)view;
- (void)handleReceivedMessage:(Message *)message;
- (void)playAlertMessage;

@end

@implementation MessageManager

@synthesize xmppiKnowStorage;

+ (BOOL)allowToSendOrReveiveMessage:(NSString *)userID
{
    //不是friend 现在不能发送消息,接收消息
    return [[[[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient] fetchXMPPUser:userID] isFriend];
}

- (XMPPiKnowUserModule *)getUserModule
{
    return [[[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient] xmppiKnowUserModule];
}

-(id)init {
    
    self = [super init];
    if (self) {
        multicastMessageDelegate = [[GCDMulticastDelegate alloc] init];
        
        fileTransferEx = [[FileTransferEx alloc] init];
        fileTransferEx.delegate = self;
    }
    return self;
}

- (id)initWithUserInfoCoreDataStorage:(XMPPiKnowStorage *)aUserInfoCoreDataStorage;
{
    NSParameterAssert(aUserInfoCoreDataStorage);
    
    xmppiKnowStorage = [aUserInfoCoreDataStorage retain];
    return [self init];
}

- (iKnowXMPPClient *)iKnowXmppClient {
    return [[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient];
}

- (XMPPRoster *)iKnowXmppRosterClient {
    return [[self iKnowXmppClient] xmppRoster];
}

- (void)addDelegate:(id)aDelegate {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");
    
    [multicastMessageDelegate addDelegate:aDelegate 
                            delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id)aDelegate {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");
    
    [multicastMessageDelegate removeDelegate:aDelegate];
}

- (void)dealloc 
{
    [player stop];
    [player release];
    
    [multicastMessageDelegate removeAllDelegates];
    [multicastMessageDelegate release];
    [fileTransferEx release];
    [xmppiKnowStorage release];

    [super dealloc];
}

#pragma mark -
#pragma mark Message

- (void)handleReceivedXMPPMessage:(XMPPMessage *)xmppMsg 
{
    if (xmppMsg == nil) 
    {
        return;
    }
    
    if (![xmppMsg isChatMessage]) {
        //不是聊天的消息，我们不处理
        return;
    }
    
    NSString *from = [[xmppMsg attributeForName:@"from"] stringValue];
    XMPPJID *fromJID = [XMPPJID jidWithString:from];
    if ([fromJID user] == nil) 
    {
        return;
    }
    
    NSString *msg = [[xmppMsg elementForName:@"body"] stringValue];
    NSString *identify = [[xmppMsg attributeForName:@"id"] stringValue];
    
    if ([identify length] == 0) 
    {
        return;
    }
    
    NSString *userID = [fromJID user];
    
    NSDictionary *userInfo = [[self getUserModule] queryLocalUserInfoWithUserID:userID];
    
    // Create Message
    Message *newMessage = [[Message alloc] init];
    
    newMessage.UserId = userID;
    newMessage.UserName = [[userInfo objectForKey:@"nickName"] length] ? 
                                        [userInfo objectForKey:@"nickName"] : DEFAULT_MSG_NAME;
    newMessage.Content = msg;
    
    newMessage.messageIdentify = identify;
    
    if (![xmppMsg wasDelayed]) 
    {
        newMessage.DataTime = [StringUtils iKnowTime:[NSDate date]];
        newMessage.localDataTime = [StringUtils iKnowTime:[NSDate date]];
    }
    else 
    {
        NSDate *timeDate = [xmppMsg delayedDeliveryDate];
        newMessage.DataTime = [StringUtils iKnowTime:timeDate];
        newMessage.localDataTime = [StringUtils iKnowTime:[NSDate date]];
    }
    
    if ([xmppMsg isiKnowImageMessage]) 
    {
        newMessage.MessageType = FileTransferTypeImage;
        newMessage.messageResourceName = [xmppMsg getiKnowImageMessageImagePath];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  newMessage, @"Message", nil];
        
        [fileTransferEx downloadFile:newMessage.messageResourceName
                             andType:FileTransferTypeImage 
                     andProgressView:nil 
                           andUserID:newMessage.UserId 
                         andUserInfo:userInfo];
        
        //[self handleReceivedMessage:newMessage]; 放在了下载完毕
        //之后的回调函数中操作.
    }
    else if ([xmppMsg isiKnowAudioMessage])
    {
        newMessage.MessageType = FileTransferTypeAudio;
        
        //TODO:
        //[self handleReceivedMessage:newMessage]; 放在了下载完毕
        //之后的回调函数中操作.
    }
    else 
    {
        newMessage.MessageType = FileTransferTypeText;
        [self handleReceivedMessage:newMessage];
    }
    
    [newMessage release];
}

- (void)handleReceivedMessage:(Message *)message 
{
    [self playAlertMessage];
    MessageCoreDataObject *coreDataMessage = [xmppiKnowStorage handleReceivedMessage:message];
    
    [multicastMessageDelegate MessageManager:self 
                          didReceivedMessage:coreDataMessage];
}

- (void)handleDidSendMessage:(XMPPMessage *)xmppMsg 
{
    NSString *identify = [[xmppMsg attributeForName:@"id"] stringValue];
    
    [multicastMessageDelegate MessageManager:self 
                              didSendMessageIdentify:identify];
}

- (int) QueryUnReadMsgCount 
{
    return [xmppiKnowStorage QueryUnReadMsgCount];
}

#pragma mark Message send

- (BOOL)SendMessageToId:(NSString *)userID 
                andText:(NSString *)text 
            andIdentify:(NSString *)identify
{
    return [[self iKnowXmppClient].xmppiKnowMessage sendTextMessage:text 
                                                           withUser:userID 
                                                            andUUID:identify];
}

- (BOOL)SendMessage:(MessageCoreDataObject *)message andProgressView:(UIProgressView *)view 
{
    NSNumber *number = message.type;
    int intType = [number intValue];
    
    switch (intType) {
        case FileTransferTypeText:
            [self SendMessageToId:message.session.userId 
                          andText:message.content 
                      andIdentify:message.identify];
            break;
        case FileTransferTypeImage:            
            {
                Message *aMessage = [[Message alloc] initWithiMessage:message];
                
                NSString *filePath = [EnglishFunAppDelegate getImagePathInDocument];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aMessage
                                                                     forKey:@"Message"];
                
                [fileTransferEx uploadFile:[filePath stringByAppendingPathComponent:message.resourceName] 
                                   andType:FileTransferTypeImage 
                           andProgressView:view 
                                 andUserID:aMessage.UserId
                               andUserInfo:userInfo];
                
                [aMessage release];
            }
            break;
    
        default:
            break;
    }
    
    return YES;
}

#pragma mark FileTransferDelegate

- (void)fileTransferDidDownLoad:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = [request.userInfo retain];
    
    Message *aMessage = [userInfo objectForKey:@"Message"];
    if (aMessage) 
    {
        [self handleReceivedMessage:aMessage];
    }
    
    [userInfo release];
}

- (void)fileTransferDidUpLoad:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = [request.userInfo retain];
    NSString *response = [request responseString];
    
    NSDictionary *dic = [response JSONValue];
    
    Message *aMessage = [userInfo objectForKey:@"Message"];
    aMessage.messageResourceName = [dic objectForKey:@"path"];
    
    if (aMessage) 
    {
        NSString *imagePath = [EnglishFunAppDelegate getImagePathInDocument];
        [imagePath stringByAppendingPathComponent:aMessage.messageResourceName];
        
        DDLogInfo(@"upload sucess filePath = %@, userID = %@", imagePath, aMessage.UserId);
        [[self iKnowXmppClient].xmppiKnowMessage sendImageMessage:aMessage.messageResourceName
                                                         widhUser:aMessage.UserId 
                                                          andUUID:aMessage.messageIdentify];    
    }
    
    [userInfo release];
}

- (void)fileTransferDidError:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = [request.userInfo retain];
    Message *aMessage = [userInfo objectForKey:@"Message"];
    if (aMessage) 
    {
        [multicastMessageDelegate MessageManager:self 
                          didSendMessageIdentify:aMessage.messageIdentify 
                                       withError:[request.error description]];
    }
    
    [userInfo release];
}

#pragma mark session

- (SessionCoreDataObject *)newSessionWithId:(NSString *)userId
{
    return [SessionCoreDataObject newSessionWithId:userId 
                            inManagedObjectContext:[xmppiKnowStorage getContext]];
}

#pragma mark alert music

- (void)playAlertMessage
{
    /*
    if (player == nil) {
        NSError *error = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"messageAlert" ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:path];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    }
    
    [player play];*/
}

@end

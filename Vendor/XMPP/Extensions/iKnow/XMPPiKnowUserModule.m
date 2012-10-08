//
//  XMPPiKnowUserModule.m
//  iKnow
//
//  Created by curer on 11-9-27.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPiKnowUserModule.h"
#import "XMPP.h"
#import "XMPPiKnowUser.h"
#import "NSXMLElement+XMPP.h"
#import "XMPPIDTracker.h"
#import "XMPPiKnowError.h"
#import "NSXMLElement+XMPP.h"
#import "XMPPiKnowStorage.h"

#import "XMPPStream.h"

#import "MemberCoreDataObject.h"

static const int ddLogLevel = LOG_LEVEL_ERROR;

#define QUERY_TIMEOUT 10

#define NS_PUBSUB          @"http://jabber.org/protocol/pubsub"
#define iKNOWUSER          @"http://192.168.1.108/xmpp/iq/user"   

#define iKNOWUSER_RES      @"http://192.168.1.108/xmpp/data/query/user"

#define TIMEOUT            QUERY_TIMEOUT + 5 


/*
 
 UserInfo NSDictionary keys
 
 @"gender",
 @"latitude",
 @"longitude",
 @"user_id",
 @"email",
 @"nickName",
 @"signature",
 @"userFlag",
 @"subscribeFlag",
 @"photoUrl",
*/

@interface XMPPiKnowUserModule (PrivateAPI)

- (void)changePasswordResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info; 
- (void)setAllResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info;
- (void)setOneResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info;
- (void)queryResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info;
- (void)queryMultiUserResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info;
- (NSDictionary *)parseUserInfo:(XMPPIQ *)iq;
- (NSArray *)parseMultiUserInfo:(XMPPIQ *)iq;
- (NSDictionary *)parseUserInfoItem:(NSXMLElement *)item;

@end


@implementation XMPPiKnowUserModule

@synthesize userInfoForSet;
@synthesize newPassword;
@synthesize returnSyncValue;
@synthesize userInfoForOneProperty;
@synthesize returnSyncMultiValue;

- (id)init 
{
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    if (self = [super initWithDispatchQueue:queue]) 
    {
        xmppIDTracker = [[XMPPIDTracker alloc] initWithDispatchQueue:self.moduleQueue];  
    }
    
    return self;
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue andStorage:(XMPPiKnowStorage *)storage
{
    NSParameterAssert(storage);
    
    xmppiKnowStorage = [storage retain];
    return [self initWithDispatchQueue:nil];
}

- (void)activeIQRequest:(XMPPIQRequest *)request
{
	dispatch_block_t block = ^{
		
        NSAssert(iqResquest == nil, @"failed");
        iqResquest = [request retain];
	};
	
	if (dispatch_get_current_queue() == moduleQueue)
		block();
	else
		dispatch_sync(moduleQueue, block);
}

- (NSString *)moduleName
{
    return @"XMPPiKnowUserModule";
}

- (void)dealloc
{
    [xmppIDTracker removeAllIDs];
    [xmppIDTracker release];
    [xmppiKnowStorage release];
    
    [userInfoForSet release];
    [newPassword release];
    [userInfoForOneProperty release];
    [returnSyncMultiValue release];
    [iqResquest release];
    
    [super dealloc];
}

#pragma mark public Method

- (BOOL)queryUserInfo
{
    // this method can invoke on any thread 
    
    NSString *userID = [[xmppStream myJID] user];
    return [self queryUserInfoWithUserID:userID];
}

- (NSDictionary *)queryUserInfoSync
{
    DDLogVerbose(@"%@ call %@", THIS_FILE, THIS_METHOD);
    // this method can invoke on any thread
    NSString *userID = [[xmppStream myJID] user];
    if ([userID length] == 0) {
        return nil;
    }
    
    return [self queryUserInfoWithUserIDSync:userID];
}

- (BOOL)queryUserInfoWithUserID:(NSString *)userID
{
    // this method can invoke on any thread 
    if ([userID length] == 0) {
        return NO;
    }
    
    if ([xmppStream isDisconnected]) {
        return NO;
    }
    
    dispatch_block_t block = ^{
        
        XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
        [iq addAttributeWithName:@"id" 
                     stringValue:[XMPPStream generateUUID]];
        
        NSXMLElement *user = [NSXMLElement elementWithName:@"user" 
                                                     xmlns:iKNOWUSER];
        
        NSXMLElement *user_id = [NSXMLElement elementWithName:@"user_id"];
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        
        [item setStringValue:userID];
        
        [user_id addChild:item];
        [user addChild:user_id];
        
        [iq addChild:user];
        
        [xmppIDTracker addID:[iq elementID] 
                      target:self 
                    selector:@selector(queuryResult:withInfo:) 
                     timeout:QUERY_TIMEOUT];
        
        [xmppStream sendElement:iq];
	};
	
	if (dispatch_get_current_queue() == self.moduleQueue)
		block();
	else
		dispatch_async(self.moduleQueue, block);
    
    return YES;
}

- (NSDictionary *)queryUserInfoWithUserIDSync:(NSString *)userID
{
    // this method can invoke on any thread
    if ([userID length] == 0) {
        return nil;
    }
    
    BOOL bRes = NO;
    
    NSAssert(receipt == nil, @"这部分代码，现在只能允许一个同步操作");
    
    receipt = [[XMPPElementReceipt alloc] init];
    bRes = [self queryUserInfoWithUserID:userID];
    
    if (!bRes) {
        RELEASE_SAFELY(receipt);
        return nil;
    }
    
    self.returnSyncValue = nil;
    bRes = [receipt wait:TIMEOUT];
    
    RELEASE_SAFELY(receipt);
    
    if (!bRes) {
        DDLogError(@"%@, %@, timeout", THIS_FILE, THIS_METHOD);
    }
    
    return self.returnSyncValue;
}

- (BOOL)setUserInfoWithDic:(NSDictionary *)dic
{
    // this method can invoke on any thread 
    if (dic == nil) {
        return NO;
    }
    
    if ([xmppStream isDisconnected]) {
        return NO;
    }
    
    dispatch_block_t block = ^{
        
        XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
        [iq addAttributeWithName:@"id" 
                     stringValue:[XMPPStream generateUUID]];
        
        NSXMLElement *user = [NSXMLElement elementWithName:@"user" 
                                                     xmlns:iKNOWUSER];
        NSXMLElement *element;
        for (NSString *item in dic)
        {
            element = [NSXMLElement elementWithName:item 
                                        stringValue:[dic valueForKey:item]];
            
            [user addChild:element];
        }  
        
        [iq addChild:user];
        
        self.userInfoForSet = dic;
        DDLogInfo(@"%@ will setUserInfo into %@", THIS_METHOD,[dic description]);
        
        [xmppIDTracker addID:[iq elementID] 
                        target:self 
                    selector:@selector(setAllResult:withInfo:) 
                    timeout:QUERY_TIMEOUT];
            
        [xmppStream sendElement:iq];
	};
	
	if (dispatch_get_current_queue() == self.moduleQueue)
		block();
	else
		dispatch_async(self.moduleQueue, block);
    
    return YES;
}

- (BOOL)setUserInfoWithObject:(NSString *)stringValue andKey:(NSString *)key
{
    // this method can invoke on any thread 
    if (key == nil) {
        return NO;
    }
    
    if ([xmppStream isDisconnected]) {
        //note this should be check by UI?
        //return NO;
    }
    
    dispatch_block_t block = ^{
        
        XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
        [iq addAttributeWithName:@"id" 
                     stringValue:[XMPPStream generateUUID]];
        
        NSXMLElement *user = [NSXMLElement elementWithName:@"user" 
                                                     xmlns:iKNOWUSER];
        NSXMLElement *element;
        element = [NSXMLElement elementWithName:key 
                                    stringValue:stringValue];
        
        [user addChild:element]; 
        
        [iq addChild:user];
        
        self.userInfoForOneProperty = [NSDictionary dictionaryWithObject:stringValue forKey:key];
        DDLogInfo(@"%@ will setUserInfo into %@", THIS_METHOD,[self.userInfoForOneProperty description]);
        
        
        [xmppIDTracker addID:[iq elementID] 
                      target:self 
                    selector:@selector(setOneResult:withInfo:) 
                     timeout:QUERY_TIMEOUT];
        
        [xmppStream sendElement:iq];
	};
	
	if (dispatch_get_current_queue() == self.moduleQueue)
		block();
	else
		dispatch_async(self.moduleQueue, block);
    
    return YES;
}

- (BOOL)setUserInfoWithObjectSync:(NSString *)stringValue andKey:(NSString *)key
{
    // this method can invoke on any thread 
    if ([key length] == 0) {
        return NO;
    }
    
    //NSAssert([key isEqualToString:@"deviceCode"], @"nosuport");
    
    if ([xmppStream isDisconnected]) {
        //note this should be check by UI?
        return NO;
    }
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"id" 
                 stringValue:[XMPPStream generateUUID]];
    
    NSXMLElement *user = [NSXMLElement elementWithName:@"user" 
                                                 xmlns:iKNOWUSER];
    NSXMLElement *element;
    element = [NSXMLElement elementWithName:key 
                                stringValue:stringValue];
    
    [user addChild:element]; 
    
    [iq addChild:user];
    
    return [[iqResquest sendSync:iq] isResultIQ];
}

- (BOOL)changePassword:(NSString *)password
{
    // this method can invoke on any thread 
    if ([password length] == 0) {
        return NO;
    }
    
    if ([xmppStream isDisconnected]) {
        return NO;
    }
    
    self.newPassword = password;
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"id" 
                 stringValue:[xmppStream generateUUID]];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" 
                                                  xmlns:@"jabber:iq:register"];
    
    NSXMLElement *userName = [NSXMLElement elementWithName:@"username"];
    [userName setStringValue:[[xmppStream myJID] user]];
    NSXMLElement *passwordElement = [NSXMLElement elementWithName:@"password"];
    [passwordElement setStringValue:password];
    
    [query addChild:userName];
    [query addChild:passwordElement];
    
    [iq addChild:query];
    
    dispatch_block_t block = ^{
        [xmppIDTracker addID:[iq elementID] 
                      target:self 
                    selector:@selector(changePasswordResult:withInfo:) 
                     timeout:QUERY_TIMEOUT];
        
        [xmppStream sendElement:iq];
	};
	
	if (dispatch_get_current_queue() == self.moduleQueue)
		block();
	else
		dispatch_async(self.moduleQueue, block);
    
    return YES;
}

- (BOOL)changePasswordSync:(NSString *)password
{
    BOOL bRes;
    
    NSAssert(receipt == nil, @"这部分代码，现在只能允许一个同步操作");
    
    receipt = [[XMPPElementReceipt alloc] init];
    bRes = [self changePassword:password];
    
    if (!bRes) {
        RELEASE_SAFELY(receipt);
        return NO;
    }
    
    self.newPassword = nil;
    bRes = [receipt wait:TIMEOUT];
    
    RELEASE_SAFELY(receipt);
    
    if (!bRes) {
        DDLogError(@"%@, %@, timeout", THIS_FILE, THIS_METHOD);
    }
    
    return self.newPassword;
    
}

- (BOOL)subscribeTag:(NSString *)articleTag withUserID:(NSString *)userID
{
    // this method can invoke on any thread 
    
    if ([articleTag length] == 0 || [userID length] == 0) {
        return NO;
    }
    
    if ([xmppStream isDisconnected]) {
        return NO;
    }
    
    NSDictionary *dic = [self queryLocalUserInfoWithUserID:userID];
    
    NSString *userFlag = [dic objectForKey:@"subscribeFlag"];
    
    NSRange range = [userFlag rangeOfString:articleTag];
    
    if (range.location != NSNotFound) {
        return NO;
    }
    
    NSMutableString *newUserFlag;
    if ([userFlag length]) 
    {
        newUserFlag = [NSMutableString stringWithString:userFlag];
        [newUserFlag appendFormat:@",%@", articleTag];
    }
    else 
    {
        newUserFlag = [NSMutableString stringWithString:articleTag];
    }

    return [self setUserInfoWithObject:newUserFlag 
                                andKey:@"subscribeFlag"];
}

- (BOOL)subscribeTagSync:(NSString *)articleTag withUserID:(NSString *)userID
{
    // this method can invoke on any thread 
    
    NSAssert(receipt == nil, @"这部分代码，现在只能允许一个同步操作");
    receipt = [[XMPPElementReceipt alloc] init]; // autoreleased below
    //[receipts addObject:receipt];
    
    BOOL bRes = YES;
    if ([self subscribeTag:articleTag withUserID:userID]) {
        bRes = [receipt wait:TIMEOUT];
    }
    else {
        bRes = NO;
    }
    
    RELEASE_SAFELY(receipt);
    
    return bRes;
}

- (BOOL)unsubscribeTag:(NSString *)articleTag withUserID:(NSString *)userID
{
    // this method can invoke on any thread 
    if ([articleTag length] == 0 || [userID length] == 0) {
        return YES;
    }
    
    NSDictionary *dic = [self queryLocalUserInfoWithUserID:userID];
    
    NSString *userFlag = [dic objectForKey:@"subscribeFlag"];
    
    if ([userFlag length] == 0) {
        //用户没有订阅标签
        return YES;
    }
    
    NSRange range = [userFlag rangeOfString:userFlag];
    if (range.location == NSNotFound) {
        //标签没有被订阅
        return YES;
    }
    
    if ([xmppStream isDisconnected]) {
        return NO;
    }
    
    NSArray *flagArr = [userFlag componentsSeparatedByString:@","];
    
    NSMutableArray *newFlagsArr = [NSMutableArray arrayWithArray:flagArr];
    
    [newFlagsArr removeObject:articleTag];
    
    if ([newFlagsArr count]) 
    {
        NSString *newUserFlag = nil;
        
        newUserFlag = [[newFlagsArr valueForKey:@"description"] componentsJoinedByString:@","];
        
        [self setUserInfoWithObject:SAFE_STRING(newUserFlag) andKey:@"subscribeFlag"];
    }
    else 
    {
        [self setUserInfoWithObject:@"" andKey:@"subscribeFlag"];
    }
    
    return YES;
}

- (NSDictionary *)queryLocalUserInfo
{
    XMPPJID *jid = [iKnowXMPPClient getJID];
    if (jid == nil) {
        return nil;
    }
    
    return [self queryLocalUserInfoWithUserID:[[xmppStream myJID] user]];
}

- (NSDictionary *)queryLocalUserInfoWithUserID:(NSString *)userID
{
    if ([userID length] == 0) {
        return nil;
    }
    
    MemberCoreDataObject *member = [xmppiKnowStorage fetchMemberWithUserID:userID];
    
    if (member == nil) {
        return nil;
    }
    
    NSArray *keys = [NSArray arrayWithObjects:
                     @"gender",
                     @"latitude",
                     @"longitude",
                     @"user_id",
                     @"email",
                     @"nickName",
                     @"signature",
                     @"userFlag",
                     @"subscribeFlag",
                     @"photoUrl",
                     nil];
    
    NSArray *values = [NSArray arrayWithObjects:
                       SAFE_STRING(member.gender),
                       SAFE_STRING(member.latitude),
                       SAFE_STRING(member.longitude),
                       SAFE_STRING(member.userId),
                       SAFE_STRING(member.email),
                       SAFE_STRING(member.name),
                       SAFE_STRING(member.signature),
                       SAFE_STRING(member.userFlag),
                       SAFE_STRING(member.subscribeFlag),
                       SAFE_STRING(member.photoUrl),
                       nil];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:values 
                                                    forKeys:keys];
    
    DDLogInfo(@"%@ %@", THIS_METHOD,[dic description]);
    return dic;
}

- (BOOL)querySurroundWithLatitude:(double)latitude 
                        Longitude:(double)longitude 
                            Limit:(double)limit
{
    if ([xmppStream isDisconnected]) {
        return NO;
    }
    
    dispatch_block_t block = ^{
        
        XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
        [iq addAttributeWithName:@"id" 
                     stringValue:[XMPPStream generateUUID]];
        
        NSXMLElement *user = [NSXMLElement elementWithName:@"user" 
                                                     xmlns:iKNOWUSER];
        
        [iq addChild:user];
        
        NSXMLElement *element = [NSXMLElement elementWithName:@"surround"];
        [element addAttributeWithName:@"latitude" 
                          stringValue:[NSString stringWithFormat:@"%f", latitude]];
        
        [element addAttributeWithName:@"longitude" 
                          stringValue:[NSString stringWithFormat:@"%f", longitude]];
        
        [element addAttributeWithName:@"limit" 
                          stringValue:[NSString stringWithFormat:@"%f", limit]];
        
        [user addChild:element];
        
        [xmppIDTracker addID:[iq elementID] 
                      target:self 
                    selector:@selector(queryMultiUserResult:withInfo:) 
                     timeout:QUERY_TIMEOUT];
        
        [xmppStream sendElement:iq];
	};
	
	if (dispatch_get_current_queue() == self.moduleQueue)
		block();
	else
		dispatch_async(self.moduleQueue, block);
    
    return YES;
}

- (void)queryUserStatus
{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"id" 
                 stringValue:[XMPPStream generateUUID]];
    
    NSXMLElement *user = [NSXMLElement elementWithName:@"user" 
                                                 xmlns:@"http://192.168.1.108/xmpp/iq/user"];
    
    NSXMLElement *subStatus = [NSXMLElement elementWithName:@"subStatus"];
    [subStatus setStringValue:@"from"];
    
    [user addChild:subStatus];
    
    [iq addChild:user];
    
    [xmppStream sendElement:iq];
}

- (NSArray *)queryOnLine
{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"id" 
                 stringValue:[XMPPStream generateUUID]];
    
    NSXMLElement *user = [NSXMLElement elementWithName:@"user" 
                                                 xmlns:@"http://192.168.1.108/xmpp/iq/user"];
    
    NSXMLElement *subStatus = [NSXMLElement elementWithName:@"online"];
    [subStatus setStringValue:@"1"];
    
    [user addChild:subStatus];
    
    NSXMLElement *offset = [NSXMLElement elementWithName:@"offset"];
    [offset setStringValue:@"0"];
    [user addChild:offset];
    
    NSXMLElement *length = [NSXMLElement elementWithName:@"length"];
    [length setStringValue:@"20"];
    [user addChild:length];
    
    [iq addChild:user];
    
    XMPPIQ *iqReceive = [iqResquest sendSync:iq];
    if (![iqReceive isResultIQ]) {
        return nil;
    }
    
    __block NSArray *array = nil; 
    
    array = [self parseMultiUserInfo:iqReceive];
    
    return array;
}

#pragma mark PrivateAPI

- (void)changePasswordResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info 
{
    NSAssert(dispatch_get_current_queue() == self.moduleQueue, @"Invoked on incorrect queue");

    if ([iq isResultIQ]) 
    {
        [receipt signalSuccess];
        [multicastDelegate chanagedPasswordFinish:self 
                                  withNewPassword:self.newPassword];
    }
    else 
    {
        [receipt signalFailure];
        NSError *error = [NSError errorWithDomain:XMPP_iKNOW_ERROR_DOMIN 
                                             code:XMPPiKnowDefaultError 
                                         userInfo:nil];
        
        [multicastDelegate chanagedPasswordError:self 
                                       withError:error];
    }
}

- (void)queryMultiUserResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info
{
    if ([iq isResultIQ]) {
        [receipt signalSuccess];
        
        NSArray *dics = [self parseMultiUserInfo:iq];
        if ([dics count] == 0) 
        {
            //没有找到
            dics = nil;
        }
        
        self.returnSyncMultiValue = dics;
        [receipt signalSuccess];
        
        [multicastDelegate xmppiKnowUserModule:self multiUserInfo:dics];
    }
    else 
    {
        self.returnSyncMultiValue = nil;
        [receipt signalFailure];
    }
}

- (void)queuryResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info 
{
    NSAssert(dispatch_get_current_queue() == self.moduleQueue, @"Invoked on incorrect queue");

    
    if ([iq isResultIQ]) 
    {
        NSDictionary *dic = [self parseUserInfo:iq];
        if ([[dic objectForKey:@"user_id"] length] == 0) 
        {
            //没有找到该用户
            dic = nil;
        }
        
        self.returnSyncValue = dic;
        [receipt signalSuccess];
        
        [multicastDelegate xmppiKnowUserModule:self 
                                       queryFinish:dic];
    }
    else 
    {
        NSError *error = [NSError errorWithDomain:XMPP_iKNOW_ERROR_DOMIN 
                                                 code:XMPPiKnowDefaultError 
                                             userInfo:nil];
            
        self.returnSyncValue = nil;
        [receipt signalFailure];
        
        [multicastDelegate xmppiKnowUserModule:self 
                                queryWithError:error];
    }
}

- (void)setAllResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info
{
    NSAssert(dispatch_get_current_queue() == self.moduleQueue, @"Invoked on incorrect queue");

    
    if ([iq isResultIQ]) 
    {
        dispatch_block_t block = ^{
            NSDictionary *dic = self.userInfoForSet;
            
            XMPPJID *jid = [self.xmppStream myJID];
            
            MemberCoreDataObject *member = [xmppiKnowStorage insertOrModifyMemberWidhUserID:[jid user]];
            
            if ([[dic objectForKey:@"signature"] length]) {
                member.signature = [dic objectForKey:@"signature"];
            }
            if ([[dic objectForKey:@"userFlag"] length]) {
                member.userFlag = [dic objectForKey:@"userFlag"];
            }
            if ([[dic objectForKey:@"gender"] length]) {
                member.gender = [dic objectForKey:@"gender"];
            }
            if ([[dic objectForKey:@"nickName"] length]) {
                member.name = [dic objectForKey:@"nickName"];
            }
            if ([[dic objectForKey:@"subscribeFlag"] length]) {
                
                NSString *str = [dic objectForKey:@"subscribeFlag"];
                if ([str isEqualToString:@" "]) {
                    member.subscribeFlag = @"";
                }
                else {
                    member.subscribeFlag = [dic objectForKey:@"subscribeFlag"];
                }
            }
            if ([[dic objectForKey:@"email"] length]) {
                member.email = [dic objectForKey:@"email"];
            }
            
            if ([[dic objectForKey:@"photoUrl"] length]) {
                member.photoUrl = [dic objectForKey:@"photoUrl"];
            }
            
            DDLogVerbose(@"%@ %@", THIS_METHOD,[dic description]);
            
            [xmppiKnowStorage mayBeSave];
            
            [multicastDelegate xmppiKnowUserModule:self 
                                   userInfoChanged:member];
            
            DDLogVerbose(@"%@ %@", THIS_METHOD,[member description]);
        };
        
        if (dispatch_get_current_queue() == dispatch_get_main_queue())
            block();
        else
            dispatch_async(dispatch_get_main_queue(), block);
        
        [receipt signalSuccess];
        
        [multicastDelegate xmppiKnowUserModule:self 
                                     setFinish:self.userInfoForSet];
    }
    else 
    {
        NSError *error = [NSError errorWithDomain:XMPP_iKNOW_ERROR_DOMIN 
                                             code:XMPPiKnowDefaultError 
                                         userInfo:nil];
        [receipt signalFailure];
        
        [multicastDelegate xmppiKnowUserModule:self 
                                  setWithError:error];
    } 
}

- (void)setOneResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info
{
    NSAssert(dispatch_get_current_queue() == self.moduleQueue, @"Invoked on incorrect queue");
    
    if ([iq isResultIQ]) 
    {
        dispatch_block_t block = ^{
            NSDictionary *dic = self.userInfoForOneProperty;
            
            XMPPJID *jid = [self.xmppStream myJID];
            
            MemberCoreDataObject *member = [xmppiKnowStorage insertOrModifyMemberWidhUserID:[jid user]];
            
            NSString *key = [[dic allKeys] lastObject];
            
            if ([key isEqualToString:@"signature"]) {
                member.signature = [dic objectForKey:@"signature"];
            }
            else if ([key isEqualToString:@"userFlag"]) {
                member.userFlag = [dic objectForKey:@"userFlag"];
            }
            else if ([key isEqualToString:@"gender"]) {
                member.gender = [dic objectForKey:@"gender"];
            }
            else if ([key isEqualToString:@"nickName"]) {
                member.name = [dic objectForKey:@"nickName"];
            }
            else if ([key isEqualToString:@"subscribeFlag"]) {
                member.subscribeFlag = [dic objectForKey:@"subscribeFlag"];
            }
            else if ([key isEqualToString:@"email"]) {
                member.email = [dic objectForKey:@"email"];
            }
            else if ([key isEqualToString:@"photoUrl"]) {
                member.photoUrl = [dic objectForKey:@"photoUrl"];
            }
            
            DDLogVerbose(@"%@ %@", THIS_METHOD,[dic description]);
             
            [xmppiKnowStorage mayBeSave];
            
            [multicastDelegate xmppiKnowUserModule:self 
                                   userInfoChanged:member];
            
            DDLogVerbose(@"%@ %@", THIS_METHOD,[member description]);
        };
        
        if (dispatch_get_current_queue() == dispatch_get_main_queue())
            block();
        else
            dispatch_async(dispatch_get_main_queue(), block);
        
        [receipt signalSuccess];
        
        [multicastDelegate xmppiKnowUserModule:self 
                                     setFinish:self.userInfoForOneProperty];
    }
    else 
    {
        NSError *error = [NSError errorWithDomain:XMPP_iKNOW_ERROR_DOMIN 
                                             code:XMPPiKnowDefaultError 
                                         userInfo:nil];
        
        [receipt signalFailure];
        
        [multicastDelegate xmppiKnowUserModule:self 
                                  setWithError:error];
    } 
}

- (NSDictionary *)parseUserInfo:(XMPPIQ *)iq
{
    NSAssert(dispatch_get_current_queue() == self.moduleQueue, @"Invoked on incorrect queue");

    
    NSXMLElement *user = [iq elementForName:@"user" xmlns:iKNOWUSER_RES];    
    NSXMLElement *item = [user elementForName:@"item"];
    
    NSDictionary *userInfo = [self parseUserInfoItem:item];
    
    return userInfo;
}

- (NSArray *)parseMultiUserInfo:(XMPPIQ *)iq
{
    NSXMLElement *user = [iq elementForName:@"user" xmlns:iKNOWUSER_RES];
    if (user == nil) {
        return nil;
    }
    
    NSArray *items = [user elementsForName:@"item"];
    
    if ([items count] == 0) {
        return nil;
    }

    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:[items count]];
    
    for (NSXMLElement *item in items) {
        NSDictionary *dic = [self parseUserInfoItem:item];
        [arr addObject:dic];
    }
    
    return [arr autorelease];
}

- (NSDictionary *)parseUserInfoItem:(NSXMLElement *)item
{
    NSDictionary *userInfo = nil;
    
    NSArray *keys = [NSArray arrayWithObjects:
                     @"gender",
                     @"latitude",
                     @"longitude",
                     @"user_id",
                     @"email",
                     @"nickName",
                     @"signature",
                     @"userFlag",
                     @"subscribeFlag",
                     @"photoUrl",
                     nil];
    
    NSArray *values = [NSArray arrayWithObjects:
                       SAFE_STRING([[item attributeForName:@"gender"] stringValue]),
                       SAFE_STRING([[item attributeForName:@"latitude"] stringValue]),
                       SAFE_STRING([[item attributeForName:@"longitude"] stringValue]),
                       SAFE_STRING([[item attributeForName:@"user_id"] stringValue]),
                       SAFE_STRING([[item attributeForName:@"email"] stringValue]),
                       SAFE_STRING([[item attributeForName:@"nickName"] stringValue]),
                       SAFE_STRING([[item attributeForName:@"signature"] stringValue]),
                       SAFE_STRING([[item attributeForName:@"userFlag"] stringValue]),
                       SAFE_STRING([[item attributeForName:@"subscribeFlag"] stringValue]),
                       SAFE_STRING([[item attributeForName:@"photoUrl"] stringValue]),
                       nil];
    
    userInfo = [[NSDictionary dictionaryWithObjects:values forKeys:keys] retain];
    
    //store in coreData
    
    NSString *userID = [userInfo objectForKey:@"user_id"];
    
    NSAssert(userID, @"userid nil bad happen");
    
    DDLogVerbose(@"%@ %@", THIS_METHOD,[userInfo description]);
    
    dispatch_block_t block = ^{
        MemberCoreDataObject *member = [xmppiKnowStorage insertOrModifyMemberWidhUserID:userID];
        
        member.gender = [userInfo objectForKey:@"gender"];
        member.latitude = [userInfo objectForKey:@"latitude"];
        member.longitude = [userInfo objectForKey:@"longitude"];
        member.userId = [userInfo objectForKey:@"user_id"];
        
        if ([member.email length] == 0) {
            
            //服务器查询有可能返回自己，但是并没有包括email字段
            //而且email是不能被修改的字段
            //所以，一旦存在意味着设定了之后，不能被修改
            member.email = [userInfo objectForKey:@"email"];
        }
        
        member.name = [userInfo objectForKey:@"nickName"];
        member.signature = [userInfo objectForKey:@"signature"];
        member.userFlag = [userInfo objectForKey:@"userFlag"];
        member.photoUrl = [userInfo objectForKey:@"photoUrl"];
        
        member.subscribeFlag = [userInfo objectForKey:@"subscribeFlag"];
        
        [xmppiKnowStorage mayBeSave];
        
        [multicastDelegate xmppiKnowUserModule:self 
                               userInfoChanged:member];
        
        DDLogVerbose(@"%@  member = %@", THIS_METHOD,[member description]);
    };
    
    if (dispatch_get_current_queue() == dispatch_get_main_queue())
        block();
    else
        dispatch_async(dispatch_get_main_queue(), block);
    
    return [userInfo autorelease];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{   
    NSAssert(dispatch_get_current_queue() == self.moduleQueue, @"Invoked on incorrect queue");

    NSString *type = [iq type];
    if ([type isEqualToString:@"result"] || [type isEqualToString:@"error"])
    {
        [xmppIDTracker invokeForID:[iq elementID] withObject:iq]; 
    }
}

@end

//
//  xmppClient.h
//  iKnow
//
//  Created by curer on 11-9-2.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iKnowXMPPDelegate.h"
#import "GCDMulticastDelegate.h"
#import "XMPPUser.h"

//for user register and login
extern NSString *const kXMPPmyJID;
extern NSString *const kXMPPmyPassword;
extern NSString *const kXMPPmyEmail;    // just for register 
extern NSString *const kXMPPmyNickName; // just for register

enum { 
    STATE_IKNOW_XMPP_NO_LOGIN = 0,
	STATE_IKNOW_XMPP_WILL_REGISTER = 1,
    STATE_IKNOW_XMPP_LOGINED = 2
};

enum  {
    LOGIN_RESULT_INVALID = 0,
    LOGIN_RESULT_CONFLICT_ERROR = 1,
    LOGIN_RESULT_NETWORK_OR_SERVER_ERROR = 2,
    LOGIN_RESULT_USERORPASSWORD_ERROR = 3
};

@class MessageManager;

@class XMPPStream;
@class XMPPCapabilities;
@class XMPPReconnect;
@class XMPPPresence;
@class XMPPAutoPing;
@class XMPPPing;
@class XMPPIQRequest;
@class XMPPPubSub;
@class XMPPvCardTemp;

@class XMPPRoster;

@class XMPPiKnowMessage;
@class XMPPiKnowvCardTempModule;
@class XMPPiKnowUserAvatar;
@class XMPPiKnowUserModule;
@class XMPPiKnowStorage;
@class XMPPRosterCoreDataStorage;

@class XMPPiKnowFramework;

@interface iKnowXMPPClient : NSObject <iKnowXMPPClientDelegate> {
    
   	XMPPRoster *xmppRoster;     
    XMPPiKnowFramework *xmppiKnowFramework;
    
    XMPPiKnowMessage *xmppiKnowMessage;
    XMPPiKnowUserModule *xmppiKnowUserModule;
    
    id<iKnowXMPPPresenceDelegate> xmppViewPresenceDelegate;
    id<iKnowXMPPRegisterDelegate> xmppViewRegisterDelegate; 
    id<iKnowXMPPLoginDelegate> xmppViewLoginDelegate;
    
    GCDMulticastDelegate <iKnowXMPPClientDelegate> *multicastXMPPiKnowClientDelegate;
    
    int clientStatus;
    
    XMPPiKnowStorage *xmppiKnowStorage;
    
    BOOL isOnLine;
    
    MessageManager *msgManager;
    
    //coreData
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    NSManagedObjectContext *managedObjectContext_roster;
}

@property (nonatomic, readonly) MessageManager *msgManager;

@property (nonatomic, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, readonly) XMPPiKnowMessage *xmppiKnowMessage;
@property (nonatomic, readonly) XMPPiKnowUserModule *xmppiKnowUserModule;

@property (nonatomic, readonly) XMPPiKnowStorage *xmppiKnowStorage;
@property (nonatomic, readonly) XMPPiKnowFramework *xmppiKnowFramework;

@property (nonatomic, assign) id<iKnowXMPPRegisterDelegate> xmppViewRegisterDelegate; 
@property (nonatomic, assign) id<iKnowXMPPPresenceDelegate> xmppViewPresenceDelegate;
@property (nonatomic, assign) id<iKnowXMPPLoginDelegate> xmppViewLoginDelegate;

@property (nonatomic, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;

- (NSManagedObjectContext *)managedObjectContext_roster;

#pragma mark -
#pragma mark iKnowXMPPDelegate
+ (XMPPJID *)getJID;
+ (NSString *)getUserEmail;
+ (NSString *)getRegisterNickName;
+ (BOOL)isAdministratorName:(NSString *)name;
+ (BOOL)isOfficialName:(NSString *)name;

- (void)addDelegate:(id)aDelegate;
- (void)removeDelegate:(id)aDelegate;

- (void)setupStream;
//build xmppstream with local user account and login user
- (BOOL)xmppConnect;

//stop xmppStream and user go offline
- (void)xmppDisconnect;

- (BOOL)loginWithEmail:(NSString *)email andPassword:(NSString *)password;
//stop xmppStream and delete user local account;
- (void)loginout;
- (void)clearLocalData;

- (BOOL)loginAdministrator:(NSString *)adminName andPassword:(NSString *)password;

- (void)bindSessionSync:(BOOL)bRefreshCookie;

- (BOOL)registerUserWithEmail:(NSString *)email 
                  andPassword:(NSString *)pwd;
- (BOOL)registerUserWithEmail:(NSString *)email 
                  andPassword:(NSString *)pwd 
                  andNickName:(NSString *)nickName;
 
- (BOOL)addFollowSync:(NSString *)userID;
- (BOOL)removeFollowSync:(NSString *)userID;

- (id <XMPPUser>)fetchXMPPUser:(NSString *)userID;
- (BOOL)isOnLine;
- (BOOL)userIsOnLine:(NSString *)userID;

@end

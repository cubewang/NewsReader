//
//  XMPPiKnowFramework.h
//  iKnow
//
//  Created by curer on 11-11-22.
//  Copyright 2011 iKnow Team. All rights reserved.
//

//封装XMPP基本的协议

#import <Foundation/Foundation.h>

typedef enum _XMPPiKnowResult {
    XMPPiKnowResult_OK = 0,
    XMPPiKnowResult_unknownErr = 1, //未知错误
    XMPPiKnowResult_paramErr = 2,   //参数错误
    XMPPiKnowResult_networkErr = 3
} XMPPiKnowResult;

@class XMPPStream;
@class XMPPReconnect;
@class XMPPCapabilities;     
@class XMPPAutoPing;
@class XMPPPing;
@class XMPPIQRequest;

@interface XMPPiKnowFramework : NSObject {
    NSString *connectHost;
    NSString *resourceName;
    XMPPJID  *xmppJID;
    NSString *domin;
    NSString *password;
    
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPCapabilities *xmppCapabilities;     
    XMPPAutoPing *xmppAutoPing;
    XMPPPing *xmppPing;
    XMPPIQRequest *iqRequestModule;
    
    int clientStatus;
    int loginResult;
    //BOOL isRegisterConflict;
    int registerResult;
    BOOL isNewUser;
    
    id delegate;
}

@property (nonatomic, copy) XMPPJID *xmppJID;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, readonly) NSString *connectHost; 
@property (nonatomic, readonly) NSString *resourceName;
@property (nonatomic, assign) id delegate;

@property (nonatomic, readonly)XMPPStream *xmppStream;
@property (nonatomic, readonly)XMPPReconnect *xmppReconnect;
@property (nonatomic, readonly)XMPPIQRequest *iqRequestModule;

- (id)initWithConnectHostName:(NSString *)hostName 
                 resourceName:(NSString *)resName
                        domin:(NSString *)aDomin;


- (BOOL)connect;
- (void)disconnect;
- (BOOL)isNewRegisterUser;

- (BOOL)setupStream;

- (XMPPiKnowResult)loginWithUser:(NSString *)user 
                     andPassword:(NSString *)password;

- (XMPPiKnowResult)registerWithUser:(NSString *)user 
                        andPassword:(NSString *)password;

- (XMPPiKnowResult)changePasswordWithUser:(NSString *)user 
                              andPassword:(NSString *)password;

- (void)loginout;

@end

@protocol XMPPiKnowFrameworkDelegate <NSObject>
@required

- (void)XMPPLoginFinished:(XMPPiKnowFramework *)framework;
- (void)XMPPLoginError:(XMPPiKnowFramework *)framework 
         withError:(NSString *)errorStr;

- (void)XMPPRegisterFinished:(XMPPiKnowFramework *)framework;
- (void)XMPPRegisterError:(XMPPiKnowFramework *)framework 
            withError:(NSString *)errorStr;

- (void)XMPPLoginoutFinished:(XMPPiKnowFramework *)framework;

@end

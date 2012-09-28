//
//  iKnowXMPPDelegate.h
//  iKnow
//
//  Created by curer on 11-9-1.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPUser.h"

@protocol iKnowXMPPClientDelegate <NSObject>
@required

//build xmppstream with local user account and login user
- (BOOL)xmppConnect;

//stop xmppStream and user go offline
- (void)xmppDisconnect;
- (BOOL)loginWithEmail:(NSString *)email andPassword:(NSString *)password;
//stop xmppStream and delete user local account;
- (void)loginout;

- (void)bindSessionSync;

- (BOOL)registerUserWithID:(NSString *)userID andPassword:(NSString *)pwd;
@end

@protocol iKnowXMPPPresenceDelegate <NSObject>

- (void)buddyDidOnline:(NSString *)text;
- (void)buddyDidOffline:(NSString *)text;

@end

@protocol iKnowXMPPRegisterDelegate <NSObject>

- (void)loginFinished;
- (void)registerFinished;
- (void)registerError:(NSString *)errorStr;

@end

@protocol iKnowXMPPLoginDelegate <NSObject>

- (void)loginFinished;
- (void)loginError:(NSString *)errorStr;

@end

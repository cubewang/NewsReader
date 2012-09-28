//
//  XMPPJID+iKnow.h
//  iKnow
//
//  Created by curer on 11-9-27.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPJID.h"

@interface XMPPJID(iKnow)

+ (NSString *)userWithEmail:(NSString *)email;
+ (XMPPJID *)createJIDWithUserID:(NSString *)userID;
+ (XMPPJID *)jidWithEmail:(NSString *)email;
+ (NSString *)userIDWithEmail:(NSString *)email;

@end

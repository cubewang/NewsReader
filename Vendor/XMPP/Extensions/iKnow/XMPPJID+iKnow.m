//
//  XMPPJID+iKnow.m
//  iKnow
//
//  Created by curer on 11-9-27.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPJID+iKnow.h"
#import "XMPPiKnowConfig.h"


@implementation XMPPJID(iKnow)

+ (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

+ (NSString *)userWithEmail:(NSString *)email;
{
    return [[self md5:email] lowercaseString];
}

+ (XMPPJID *)createJIDWithUserID:(NSString *)userID
{
    assert(userID);
    //NSString *xmppid = [NSString stringWithFormat:@"%@@%@", userID, XMPP_DOMIN];
    //return [XMPPJID jidWithString:xmppid];
    return [XMPPJID jidWithUser:userID 
                         domain:XMPP_DOMIN 
                       resource:XMPP_RESOURCE];
}

+ (XMPPJID *)jidWithEmail:(NSString *)email;
{
    return [XMPPJID jidWithUser:[XMPPJID userWithEmail:email] 
                         domain:XMPP_DOMIN 
                       resource:XMPP_RESOURCE];
}

+ (NSString *)userIDWithEmail:(NSString *)email
{
    return [XMPPJID userWithEmail:email];
}

@end

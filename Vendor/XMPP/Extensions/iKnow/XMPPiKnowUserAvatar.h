//
//  XMPPiKnowUserAvatar.h
//  iKnow
//
//  Created by curer on 11-9-26.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPModule.h"

@class XMPPPubSub;

@interface XMPPiKnowUserAvatar : XMPPModule {
    XMPPPubSub *_xmppPubSub;
}

- (id)initWithPubSub:(XMPPPubSub *)xmppPubSub;
- (id)initWithDispatchQueue:(dispatch_queue_t)queue;
- (void)updateUserAvatar:(NSString *)fileName;

@end

@protocol XMPPiKnowUserAvatarDelegate
@optional

- (void)xmppiKnowUserAvatar:(XMPPiKnowUserAvatar *)sender 
           didReceiveAvatar:(NSString *)fileName;

@end

//
//  XMPPiKnowvCardTempModule.h
//  iKnow
//
//  Created by curer on 11-9-25.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPModule.h"

@class XMPPiKnowvCardTemp;

@interface XMPPiKnowvCardTempModule : XMPPModule {
    /**************************************
     * Inherited from XMPPModule:
     * 
     * XMPPStream *xmppStream;
     * 
     * dispatch_queue_t moduleQueue;
     * id multicastDelegate;
     ***************************************/
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue;

//return YES means push data into system socket buffer
//doesn't means that we get the vCardTemp data from server
//return NO means param error or some other things wrong
- (BOOL)fetchvCardTempForJID:(XMPPJID *)jid;
- (BOOL)updateMyvCardTemp:(XMPPiKnowvCardTemp *)vCardTemp;

@end

@protocol XMPPiKnowvCardTempModuleDelegate
@optional

- (void)xmppiKnowvCardTempModule:(XMPPiKnowvCardTempModule *)vCardTempModule 
             didReceivevCardTemp:(XMPPiKnowvCardTemp *)vCardTemp 
                          forJID:(XMPPJID *)jid;

@end

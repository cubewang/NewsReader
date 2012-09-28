//
//  XMPPIQRequest.h
//  iKnow
//
//  Created by curer on 11-10-21.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#import "XMPPModule.h"
#import "XMPPStream.h"

@class XMPPIDTracker;

@interface XMPPIQRequest : XMPPModule {
    
    /**************************************
     * Inherited from XMPPModule:
     * 
     * 
     * dispatch_queue_t moduleQueue;
     * id multicastDelegate;
     ***************************************/
    
    XMPPIDTracker *xmppIDTracker;
    XMPPElementReceipt *receipt;
    XMPPElement *response;
    
    NSMutableDictionary *waitObjects;
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue;

- (XMPPIQ *)sendSync:(XMPPIQ *)iq;
//- (void)sendAsync:(XMPPIQ *)iq;

@end

@protocol XMPPIQRequestDelegate

- (void)iqRequestFinish:(XMPPIQRequest *)iqRequest;

@end

@interface XMPPIQRequestPakage : NSObject
{
    XMPPIQ *iqReceive;
    XMPPElementReceipt *receipt;
}

@property (nonatomic, retain) XMPPIQ *iqReceive;
@property (nonatomic, retain) XMPPElementReceipt *receipt;

@end

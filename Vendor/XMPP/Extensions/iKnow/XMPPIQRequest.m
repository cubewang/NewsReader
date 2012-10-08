//
//  XMPPIQRequest.m
//  iKnow
//
//  Created by curer on 11-10-21.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPIQRequest.h"
#import "XMPPIDTracker.h"

static const int ddLogLevel = LOG_LEVEL_ERROR;

#define IQTIMEOUT          10
#define TIMEOUT            IQTIMEOUT + 5

@interface XMPPIQRequest(PrivateAPI)

- (void)iqSyncResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info;
- (void)iqAsyncResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info;

@end


@implementation XMPPIQRequest


- (id)init 
{
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue 
{
    
    if ((self = [super initWithDispatchQueue:queue]))
    {
        xmppIDTracker = [[XMPPIDTracker alloc] initWithDispatchQueue:self.moduleQueue];  
        waitObjects = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return self;
}

- (BOOL)activate:(XMPPStream *)aXmppStream
{
    if ([super activate:aXmppStream])
    {
        //XMPPLogVerbose(@"%@: Activated", THIS_FILE);
        
        // Custom code goes here (if needed)
        
        return YES;
    }
    
    return NO;
}

- (void)deactivate
{
    //XMPPLogTrace();
    
    // Custom code goes here (if needed)
    
    [super deactivate];
}

- (NSString *)moduleName
{
    // Override me to provide a proper module name.
    // The name may be used as the name of the dispatch_queue which could aid in debugging.
    
    // this supper class XMPPModule , create dispatch queue with this name
    return @"XMPPIQRequest";
}

- (void)dealloc
{
    RELEASE_SAFELY(xmppIDTracker);
    RELEASE_SAFELY(response);   
    RELEASE_SAFELY(waitObjects);
    
    [super dealloc];
}

#pragma mark method

- (XMPPIQ *)sendSync:(XMPPIQ *)iq;
{
    // this method can invoke on any thread 
    NSAssert(receipt == nil, @"这部分代码，现在只能允许一个同步操作");
    
    if ([xmppStream isDisconnected]) {
        return nil;
    }
    
    XMPPIQ *sendIQ = [XMPPIQ iqFromElement:iq];
    
    receipt = [[XMPPElementReceipt alloc] init];
    RELEASE_SAFELY(response); // 清除掉上一次调用结果
    
    dispatch_block_t block = ^{
        [xmppIDTracker addID:[sendIQ elementID] 
                      target:self 
                    selector:@selector(iqSyncResult:withInfo:) 
                     timeout:IQTIMEOUT];
	};
	
	if (dispatch_get_current_queue() == self.moduleQueue)
		block();
	else
		dispatch_sync(self.moduleQueue, block);
    
    [xmppStream sendElement:sendIQ];
    BOOL bRes = [receipt wait:TIMEOUT];
    RELEASE_SAFELY(receipt);
    
    if (bRes) {
        [multicastDelegate iqRequestFinish:self];
    }
    else {
        //这里几乎永远不会遇到，如果遇到了，那么说明发生了dead lock
        //这是防止发生dead lock的最后措施
        //当然，如果我们真的遇到了，bad things happen and find out
        //TTDASSERT(0);
        DDLogError(@"%@, %@, dead lock happen", THIS_FILE, THIS_METHOD);
    }
    
    if (response == nil) {
        //this means that server not response us
        //so time out happen
        return nil;
    }
    
    //not fix me with copy 
    //because XMPPIQ need to be set by runtime class method
    //so common copy method will cause crash at runtime
    return [XMPPIQ iqFromElement:response];
    //这里，我们不能避免所有可能发生的dead lock，但是，已经很低*/
    
    //return [self sendSyncEx:iq];
}

- (XMPPIQ *)sendSyncEx:(XMPPIQ *)iq;
{
    // this method can invoke on any thread 
    
    if ([xmppStream isDisconnected]) {
        return nil;
    }
    
    XMPPIQ *sendIQ = [XMPPIQ iqFromElement:iq];
    
    if (sendIQ == nil || [[sendIQ elementID] length] == 0) {
        return nil;
    }
    
    XMPPIQRequestPakage *pakage = [[XMPPIQRequestPakage alloc] init];
    XMPPElementReceipt *aReceipt = [[XMPPElementReceipt alloc] init];
    pakage.receipt = aReceipt;
    [aReceipt release];
    
    dispatch_block_t block = ^{
        [waitObjects setObject:pakage forKey:[sendIQ elementID]];
        
        [xmppIDTracker addID:[sendIQ elementID] 
                      target:self 
                    selector:@selector(iqAsyncResult:withInfo:) 
                     timeout:IQTIMEOUT];
	};
	
	if (dispatch_get_current_queue() == self.moduleQueue)
		block();
	else
		dispatch_sync(self.moduleQueue, block);
    
    [xmppStream sendElement:sendIQ];
    BOOL bRes = [pakage.receipt wait:TIMEOUT];
    
    if (!bRes) {
        //这里几乎永远不会遇到，如果遇到了，那么说明发生了dead lock
        //这是防止发生dead lock的最后措施
        //当然，如果我们真的遇到了，bad things happen and find out
        //TTDASSERT(0);
        DDLogError(@"%@, %@, dead lock happen", THIS_FILE, THIS_METHOD);
    }
    
    XMPPIQ *iqReceive = pakage.iqReceive;
    
    if (iqReceive == nil || [iqReceive isErrorIQ]) {
        //this means that server not response us
        //so time out happen
        RELEASE_SAFELY(pakage);
        return nil;
    }
    
    [pakage autorelease];
    //not fix me with copy 
    //because XMPPIQ need to be set by runtime class method
    //so common copy method will cause crash at runtime
    return [XMPPIQ iqFromElement:iqReceive];
    //这里，我们不能避免所有可能发生的dead lock，但是，已经很低
}

- (void)iqSyncResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info 
{
    NSAssert(dispatch_get_current_queue() == self.moduleQueue, 
             @"Invoked on incorrect queue");
    
    if (iq) {
        response = [iq retain];
        [receipt signalSuccess];
    }
    
    RELEASE_SAFELY(response);
    [receipt signalFailure];
}

- (void)iqAsyncResult:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info
{
    NSAssert(dispatch_get_current_queue() == self.moduleQueue, 
             @"Invoked on incorrect queue");
    
    XMPPIQRequestPakage *pakage = [waitObjects objectForKey:[iq elementID]];
    //we are safe , because pakage retain by other
    if (iq) {
        pakage.iqReceive = iq;
        [pakage.receipt signalSuccess];
    }
    else {
        pakage.iqReceive = nil;
        [pakage.receipt signalFailure];
    }

    [waitObjects removeObjectForKey:[iq elementID]];
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

@implementation XMPPIQRequestPakage

@synthesize iqReceive;
@synthesize receipt;

- (void)dealloc
{
    [iqReceive release];
    
    [receipt signalFailure];
    [receipt release];
    
    [super dealloc];
}

@end

//
//  XMPPiKnowvCardTempModule.m
//  iKnow
//
//  Created by curer on 11-9-25.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPiKnowvCardTempModule.h"
#import "XMPPiKnowvCardTemp.h"
#import "XMPP.h"
#import "XMPPIQ.h"


#define MYVCARD_NAME_KEY        @"MyvCardTempNameKey"

@implementation XMPPiKnowvCardTempModule

- (id)init 
{
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue 
{
    
    if ((self = [super initWithDispatchQueue:queue]))
    {
        //other init 
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
    return @"XMPPiKnowvCardTempModule";
}

- (void)dealloc
{
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark vCard
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//return YES means push data into system socket buffer
//doesn't means that we get the vCardTemp data from server
//return NO means param error or some other things wrong
- (BOOL)fetchvCardTempForJID:(XMPPJID *)jid
{
    XMPPIQ *iq = [XMPPiKnowvCardTemp iqvCardRequestForJID:jid];
    [xmppStream sendElement:iq];
    return YES;
}

- (BOOL)updateMyvCardTemp:(XMPPiKnowvCardTemp *)vCardTemp
{
    if (vCardTemp == nil) {
        return NO;
    }
    
    NSString *elemId = [xmppStream generateUUID];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:nil elementID:elemId child:vCardTemp];
    [xmppStream sendElement:iq];
    
    return YES;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	// This method is invoked on the moduleQueue.
	
	// Remember XML heirarchy memory management rules.
	// The passed parameter is a subnode of the IQ, and we need to pass it to an asynchronous operation.
	// 
	// Therefore we use vCardTempCopyFromIQ instead of vCardTempSubElementFromIQ.
	
	XMPPiKnowvCardTemp *vCardTemp = [XMPPiKnowvCardTemp vCardTempiKnowFromIQ:iq];
    
	if (vCardTemp != nil)
	{
        XMPPJID *from = [iq from];
        
        if ([from.bare length] == 0) 
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"test" 
                                                      forKey:MYVCARD_NAME_KEY];
        }
        
        [multicastDelegate xmppiKnowvCardTempModule:self 
                                didReceivevCardTemp:vCardTemp 
                                             forJID:from];
        
		return YES;
	}
	
	return NO;
}

@end

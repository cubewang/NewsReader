//
//  XMPPiKnowUserAvatar.m
//  iKnow
//
//  Created by curer on 11-9-26.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPiKnowUserAvatar.h"
#import "XMPPPubSub+publish.h"
#import "XMPP.h"
#import "XMPPPubSub.h"

#define USERAVATAR          @"urn:xmpp:avatar:metadata"
#define NS_PUBSUB_EVENT     @"http://jabber.org/protocol/pubsub#event"


@implementation XMPPiKnowUserAvatar

- (id)initWithPubSub:(XMPPPubSub *)xmppPubSub;
{
    NSParameterAssert(xmppPubSub != nil);
    
    _xmppPubSub = [xmppPubSub retain];
    
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

- (void)dealloc {
	[_xmppPubSub removeDelegate:self];
    RELEASE_SAFELY(_xmppPubSub);
	
	[super dealloc];
}

- (void)updateUserAvatar:(NSString *)fileName
{
    /*
    //标准的XEP－084 item id是指的是图片数据hash值，
    //我们这里的id 被简化为图片在服务器的文件名
    //这样，可以减少一次服务器的请求。
    //而且，同样能够达到获知图片是否更新的状态
    
    NSAssert(fileName, @"fileName nil");
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    
    NSString *itemID = fileName;
    [item addAttributeWithName:@"id" 
                   stringValue:itemID];
    
    NSXMLElement *metadata = [NSXMLElement elementWithName:@"metadata" 
                                               xmlns:USERAVATAR];
    
    NSXMLElement *info = [NSXMLElement elementWithName:@"info"];
    [info addAttributeWithName:@"url" 
                   stringValue:fileName];
    [metadata addChild:info];
    [item addChild:metadata];
    
    [_xmppPubSub publishNode:USERAVATAR withitem:item];*/
    
    
}

- (NSString *)moduleName
{
    // Override me to provide a proper module name.
    // The name may be used as the name of the dispatch_queue which could aid in debugging.
    
    // this supper class XMPPModule , create dispatch queue with this name
    return @"XMPPiKnowUserAvatar";
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPPubSub Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSXMLElement *event = [message elementForName:@"event" xmlns:NS_PUBSUB_EVENT];
	if (event)
	{
		NSXMLElement *items = [event elementForName:@"items"];
        if (items) 
        {
            NSXMLElement *item = [items elementForName:@"item"];
            if (item) 
            {
                NSXMLElement *metadata = [item elementForName:@"metadata" 
                                                        xmlns:USERAVATAR];
                
                NSXMLElement *info = [metadata elementForName:@"info"];
                
                
                [multicastDelegate xmppiKnowUserAvatar:self 
                                      didReceiveAvatar:[info attributeStringValueForName:@"id"]];
            }
            
        }
	}
}

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveError:(XMPPIQ *)iq
{
}

@end

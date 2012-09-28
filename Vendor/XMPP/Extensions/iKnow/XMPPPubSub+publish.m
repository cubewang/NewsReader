//
//  XMPPPubSub+publish.m
//  iKnow
//
//  Created by curer on 11-9-26.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPPubSub+publish.h"
#import "XMPPPubSub.h"
#import "XMPP.h"

#define NS_PUBSUB          @"http://jabber.org/protocol/pubsub"
#define NS_PUBSUB_EVENT    @"http://jabber.org/protocol/pubsub#event"

@implementation XMPPPubSub(publish)

- (NSString *)publishNode:(NSString *)nodeNameSpace 
              withitem:(NSXMLElement *)item;
{
    /*
      <iq type='set' from='juliet@capulet.lit/chamber' id='publish2'>
       <pubsub xmlns='http://jabber.org/protocol/pubsub'>
        <publish node='urn:xmpp:avatar:metadata'>
          <item id='111f4b3c50d7b0df729d299bc6f8e9ef9066971f'>
            ...
            ...
          </item>
        </publish>
       </pubsub>
      </iq>
    */
    NSString *sid = [NSString stringWithFormat:@"%@:publish_node", 
                        xmppStream.generateUUID];
    XMPPJID *from = [xmppStream myJID];
    
	XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:serviceJID elementID:sid];
    [iq addAttributeWithName:@"from" 
                 stringValue:from.bare];
    
	NSXMLElement *ps = [NSXMLElement elementWithName:@"pubsub" xmlns:NS_PUBSUB];
	NSXMLElement *publish = [NSXMLElement elementWithName:@"publish"];
	[publish addAttributeWithName:@"node" stringValue:nodeNameSpace];
    
    [publish addChild:item];
    [ps addChild:publish];
    [iq addChild:ps];
    
    [xmppStream sendElement:iq];
    
    return sid;
}

@end

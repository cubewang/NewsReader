#import "XMPPRoster+follow.h"
#import "XMPP.h"
#import "XMPPRoster.h"
#import "XMPPLogging.h"

#import "iKnowXMPPClient.h"
#import "XMPPIQRequest.h"

#if DEBUG
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;//XMPP_LOG_LEVEL_VERBOSE;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

#define TIME_OUT 5

@implementation XMPPRoster (iKnowFollow)

- (BOOL)userIsOnLine:(XMPPJID *)jid
{
    if (jid == nil) {
        return NO;
    }
    
    id <XMPPUser> user = [self userForJID:jid];
    return [user isOnline];
}

- (BOOL)addBuddySync:(XMPPJID *)jid;
{
    // This is a public method.
    // It may be invoked on any thread/queue.
    
    if (jid == nil) return NO;
    
    XMPPJID *myJID = xmppStream.myJID;
    
    if ([[myJID bare] isEqualToString:[jid bare]])
    {
        // No, you don't need to add yourself
        return NO;
    }
    
    if ([xmppStream isDisconnected]) {
        return NO;
    }
    
    // Add the buddy to our roster
    // 
    // <iq type="set">
    //   <query xmlns="jabber:iq:roster">
    //     <item jid="bareJID" name="optionalName"/>
    //   </query>
    // </iq>
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"jid" stringValue:[jid bare]];

    /*
    if (optionalName)
    {
        [item addAttributeWithName:@"name" stringValue:optionalName];
    }*/
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [query addChild:item];
    
    XMPPIQ *iq = [XMPPIQ elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addChild:query];
    [iq addAttributeWithName:@"id" stringValue:[xmppStream generateUUID]];
    
    XMPPIQ *iqResult = [xmppIQRequestModule sendSync:iq];
    BOOL bRes = NO;
    if ([iqResult isResultIQ]) {
        // Subscribe to the buddy's presence
        // 
        // <presence to="bareJID" type="subscribe"/>
        
        NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
        [presence addAttributeWithName:@"to" stringValue:[jid bare]];
        [presence addAttributeWithName:@"type" stringValue:@"subscribe"];
        
        [xmppStream sendElement:presence];
        
        return YES;
    }
    
    return bRes;
}

- (BOOL)addFollowSync:(XMPPJID *)jid
{
    // This is a public method.
    // It may be invoked on any thread/queue.
    return [self addBuddySync:jid];
}

//TODO no sync now
- (BOOL)removeFollowSync:(XMPPJID *)jid
{
    if (jid == nil) return NO;
    
    XMPPJID *myJID = xmppStream.myJID;
    
    if ([[myJID bare] isEqualToString:[jid bare]])
    {
        //  No, you shouldn't remove yourself
        return NO;
    }
    
    if ([xmppStream isDisconnected]) {
        return NO;
    }
    
    //判断当前rosteritem subscription
    id<XMPPUser> user = [self userForJID:jid];
    if (user == nil) {
        return YES;
    }
    
    if ([user isFriend]) {
        NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
        [presence addAttributeWithName:@"to" stringValue:[jid bare]];
        [presence addAttributeWithName:@"type" stringValue:@"unsubscribe"];
        
        [xmppStream sendElement:presence];
        
        return YES;
    }
    else if ([user isNone])
    {
        return YES;
    }
    else {
        // isFollow or isFans
        
        // Remove the buddy from our roster
        // Unsubscribe from presence
        // And revoke contact's subscription to our presence
        // ...all in one step
        
        // <iq type="set">
        //   <query xmlns="jabber:iq:roster">
        //     <item jid="bareJID" subscription="remove"/>
        //   </query>
        // </iq>
        
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        [item addAttributeWithName:@"jid" stringValue:[jid bare]];
        [item addAttributeWithName:@"subscription" stringValue:@"remove"];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
        [query addChild:item];
        
        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
        [iq addAttributeWithName:@"type" stringValue:@"set"];
        [iq addAttributeWithName:@"id" stringValue:[xmppStream generateUUID]];
        [iq addChild:query];
        
        XMPPIQ *iqSend = [XMPPIQ iqFromElement:iq];
        return [xmppIQRequestModule sendSync:iqSend] != nil;
    }
}

@end

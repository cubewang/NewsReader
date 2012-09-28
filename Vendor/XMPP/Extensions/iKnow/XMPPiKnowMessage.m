//
//  iKnowXMPPMessage.m
//  iKnow
//
//  Created by curer on 11-9-20.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPiKnowMessage.h"
#import "XMPPMessage+iKnowMessage.h"
#import "XMPP.h"

@interface XMPPiKnowMessage (PrivateAPI)

- (void) didReceiveTextMessage:(XMPPMessage *)message;
- (void) didReceiveImageMessage:(XMPPMessage *)message;
- (void) didReceiveAudioMessage:(XMPPMessage *)message;

@end


@implementation XMPPiKnowMessage

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
    return @"XMPPiKnowMessage";
}

- (void)dealloc
{
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Message Management Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)sendArticleNotify:(NSString *)type
              withArticle:(Article *)article
                 withUUID:(NSString *)uuid
              withContent:(NSString *)content
{
    if ([uuid length] == 0 || [content length] == 0 || article == nil) {
        return NO;
    }
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    
    [body setStringValue:content];
    
    NSString *jidStr = [[XMPPJID createJIDWithUserID:article.UserId] bare];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"to" stringValue:jidStr];
    [message addAttributeWithName:@"id" stringValue:uuid];
    
    if ([type isEqualToString:@"love"]) {
        message = [XMPPMessage addNotifyWithLoveType:message
                                        andArticleID:article.Id];
    }
    else if ([type isEqualToString:@"comment"]){
        message = [XMPPMessage addNotifyWithCommentType:message
                                           andArticleID:article.Id];
    }
    
    [message addChild:body];
    
    [xmppStream sendElement:message];
    return YES;
}

//返回正确，只是保证参数传递正确，不保证消息送达
- (BOOL)sendTextMessage:(NSString *)content 
               withUser:(NSString *)userID 
                andUUID:(NSString *)uuid
{
    // This is a public method.
    // It may be invoked on any thread/queue.
    
    if ([content length] == 0 || [userID length] == 0 || [uuid length] == 0)
    {
        return NO;
    }
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    
    [body setStringValue:content];
    
    NSString *jidStr = [[XMPPJID createJIDWithUserID:userID] bare];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:jidStr];
    [message addAttributeWithName:@"id" stringValue:uuid];
    [message addChild:body];
    
    [xmppStream sendElement:message];
    return YES;
}

//返回正确，只是保证参数传递正确，不保证消息送达
//imageName 表示文件名
- (BOOL)sendImageMessage:(NSString *)imageName 
                widhUser:(NSString *)userID
                 andUUID:(NSString *)uuid
{
    // This is a public method.
    // It may be invoked on any thread/queue.
    
    if ([imageName length] == 0 || [userID length] == 0 || [uuid length] == 0)
    {
        return NO;
    }
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"图片"];
    
    NSXMLElement *imageElement = [NSXMLElement elementWithName:@"image"];
    [imageElement addAttributeWithName:@"src" stringValue:imageName];
    
    //NSXMLElement *iKnowMessage = [NSXMLElement elementWithName:@"iKnow"];
    //[iKnowMessage addAttributeWithName:@"xmlns" stringValue:@"http://192.168.1.108"];
    
    //[iKnowMessage addChild:imageElement];
    
    //NSString *jidStr = [NSString stringWithFormat:@"%@@%@", userID, XMPP_DOMIN];
    NSString *jidStr = [[XMPPJID createJIDWithUserID:userID] bare];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:jidStr];
    [message addAttributeWithName:@"id" stringValue:uuid];
    [message addChild:body];
    //[message addChild:iKnowMessage];
    
    [message addChild:imageElement];
    
    [xmppStream sendElement:message];
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message 
{
    // This method is invoked on the moduleQueue.
    if ([message isChatMessage]) 
    {
        [multicastDelegate xmppiKnowMessage:self 
                             didSendMessage:message];   
    }
}

/**
 * Delegate method to receive incoming message stanzas.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message 
{
    // This method is invoked on the moduleQueue.
    
    // <message from='pubsub.foo.co.uk' to='admin@foo.co.uk'>
    //   <event xmlns='http://jabber.org/protocol/pubsub#event'>
    //     <items node='/pubsub.foo'>
    //       <item id='5036AA52A152B'>
    //         <text id='724427814855'>
    //           Huw Stephens sits in for Greg James and David Garrido takes a look at the sporting week
    //         </text>
    //       </item>
    //     </items>
    //   </event>
    // </message>
    /*
    if ([message isiKnowImageMessage]) 
    {
        [self didReceiveImageMessage:message];
    }
    else if ([message isiKnowAudioMessage]) 
    {
        [self didReceiveAudioMessage:message];
    }
    else if ([message isMessageWithBody])
    {
        [self didReceiveTextMessage:message];
    }
    */
    
    [multicastDelegate xmppiKnowMessage:self 
                      didReceiveMessage:message];   
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error 
{
    // This method is invoked on the moduleQueue.
    [multicastDelegate xmppiKnowMessageDidSendMessageFailed:self 
                                                  withError:error];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPiKnowMessage (PrivateAPI)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end

//
//  XMPPMessage+iKnowMessage.m
//  iKnow
//
//  Created by curer on 11-9-11.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPMessage.h"
#import "XMPP.h"
#import "XMPPMessage+iKnowMessage.h"
#import "XMPPElement.h"

//<message from = 'aa' to 'bb'>
//  <notify xmlns = 'http://192.168.1.108/xmpp/data/notify/user' type='love'>
//    <articleID>xxx</articleID>
//</message> 

//type:
//love 收藏
//comment 评论

#define IKNOW_NOTIFY    @"http://192.168.1.108/xmpp/data/notify/user"

@implementation XMPPMessage(iKnowMsg)

+ (id)addNotifyWithCommentType:(NSXMLElement *)message 
                  andArticleID:(NSString *)articleID
{
    if (message == nil || [articleID length] == 0) {
        return nil;
    }
    
    NSXMLElement *notify = [NSXMLElement elementWithName:@"notify" 
                                                 xmlns:IKNOW_NOTIFY];
    
    [notify addAttributeWithName:@"type" stringValue:@"comment"];
    XMPPElement *articleElement = [XMPPElement elementWithName:@"articleID"
                                              stringValue:articleID];
    [notify addChild:articleElement];
    
    [message addChild:notify];
    
    return message;
}

+ (id)addNotifyWithLoveType:(NSXMLElement *)message
               andArticleID:(NSString *)articleID
{
    if (message == nil || [articleID length] == 0) {
        return nil;
    }
    
    NSXMLElement *notify = [NSXMLElement elementWithName:@"notify" 
                                                 xmlns:IKNOW_NOTIFY];
    
    [notify addAttributeWithName:@"type" stringValue:@"love"];
    
    NSXMLElement *articleElement = [XMPPElement elementWithName:@"articleID"
                                              stringValue:articleID];
    [notify addChild:articleElement];
    
    [message addChild:notify];
    
    return message;
}

- (NSString *)notifyType
{
    NSXMLElement *notifyElement = [self elementForName:@"notify"
                                                 xmlns:IKNOW_NOTIFY];
    if (notifyElement) {
        return [[notifyElement attributeForName:@"type"] stringValue];
    }
    
    return nil;
}

- (BOOL)isiKnowImageMessage
{
    NSXMLElement *imageElement = [self elementForName:@"image"];
    return imageElement != nil;
}

- (BOOL)isiKnowAudioMessage
{
    return [self elementForName:@"audio"] != nil;
}

- (NSString *)getiKnowImageMessageImagePath {
    if (![self isiKnowImageMessage]) {
        return nil;
    }

    NSXMLElement *res = [self elementForName:@"image"];
    return [[res attributeForName:@"src"] stringValue];
}

- (BOOL)isNotifyMessage {
    if ([self isChatMessage])
        return NO;
    
    NSXMLElement *notifyElement = [self elementForName:@"notify"
                                                 xmlns:IKNOW_NOTIFY];
    return notifyElement != nil;
}

@end

//
//  XMPPPresence+iKnow.m
//  iKnow
//
//  Created by curer on 11-10-13.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPPresence+iKnow.h"
#import "XMPP.h"
#import "DDXMLElement.h"
#import "NSString+DDXML.h"

#define XMLNS_NICKNAME  @"http://jabber.org/protocol/nick"

@implementation XMPPPresence (iKnowFollow)


- (NSString *)nickName
{
    NSXMLElement *nick = [self elementForName:@"nick"
                                        xmlns:XMLNS_NICKNAME];
    
    if (nick == nil) {
        return nil;
    }
    
    return [nick stringValue];
}

- (void)addNickName:(NSString *)nickName
{
    NSXMLElement *nick = [NSXMLElement elementWithName:@"nick" 
                                                 xmlns:XMLNS_NICKNAME];
    NSString *utf8Name = [NSString stringWithFormat:@"%s", [nickName xmlChar]];
    [nick setStringValue:utf8Name];  //注意，在Presence节中，的中文需要utf8转义，否则解析时会出错
    
    [self addChild:nick];
}

@end

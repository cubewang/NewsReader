//
//  XMPPvCardTempiKnow.m
//  iKnow
//
//  Created by curer on 11-9-25.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPiKnowvCardTemp.h"
#import "XMPPLogging.h"
#import "XMPP.h"

#import <objc/runtime.h>

#if DEBUG_XMPP
static const int xmppLogLevel = XMPP_LOG_LEVEL_ERROR;
#else
static const int xmppLogLevel = XMPP_LOG_LEVEL_ERROR;
#endif

static NSString *const kXMPPNSvCardTemp = @"vcard-temp";
static NSString *const kXMPPvCardTempElement = @"vCard";


@implementation XMPPiKnowvCardTemp

+ (void)initialize
{
	// We use the object_setClass method below to dynamically change the class from a standard NSXMLElement.
	// The size of the two classes is expected to be the same.
	// 
	// If a developer adds instance methods to this class, bad things happen at runtime that are very hard to debug.
	// This check is here to aid future developers who may make this mistake.
	// 
	// For Fearless And Experienced Objective-C Developers:
	// It may be possible to support adding instance variables to this class if you seriously need it.
	// To do so, try realloc'ing self after altering the class, and then initialize your variables.
	
	size_t superSize = class_getInstanceSize([NSXMLElement class]);
	size_t ourSize   = class_getInstanceSize([XMPPiKnowvCardTemp class]);
	
	if (superSize != ourSize)
	{
		NSLog(@"Adding instance variables to XMPPMessage is not currently supported!");
		exit(15);
	}
}

+ (XMPPiKnowvCardTemp *)iKnowvCardTempFromElement:(NSXMLElement *)element
{
    object_setClass(element, [XMPPiKnowvCardTemp class]);
    return (XMPPiKnowvCardTemp *)element;
}

+ (XMPPiKnowvCardTemp *)vCardTempiKnowFromIQ:(XMPPIQ *)iq
{
    if ([iq isResultIQ])
    {
        NSXMLElement *query = [iq elementForName:kXMPPvCardTempElement xmlns:kXMPPNSvCardTemp];
		if (query)
		{
			object_setClass(query, [XMPPiKnowvCardTemp class]);
            return (XMPPiKnowvCardTemp *)query;
		}
    }
    return nil;
}

+ (XMPPIQ *)iqvCardRequestForJID:(XMPPJID *)jid {
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[jid bareJID]];
    NSXMLElement *vCardElem = [NSXMLElement elementWithName:kXMPPvCardTempElement xmlns:kXMPPNSvCardTemp];
    
    [iq addChild:vCardElem];
    return iq;
}

#pragma mark -
#pragma mark Getter/setter methods

- (void)setiKnowName:(NSString *)name 
{
    NSXMLElement *elem = [self elementForName:@"name"];					
	if (name != nil)                                                 
	{                                                                  
		if (elem == nil) {											
			elem = [NSXMLElement elementWithName:@"name"];	
            [self addChild:elem];
		}                                                               
		[elem setStringValue:name];									
	}                                                                   
	else if (elem != nil) {											    
		[self removeChildAtIndex:[[self children] indexOfObject:elem]];	
	}
}

- (NSString *)iKnowName 
{
	return [[self elementForName:@"name"] stringValue];
}

- (void)setAvatar:(NSString *)fileName
{
    NSXMLElement *elem = [self elementForName:@"photo"];					
	if (fileName != nil)                                                 
	{                                                                  
		if (elem == nil) {											
			elem = [NSXMLElement elementWithName:@"photo"];	
            [self addChild:elem];
		}                                                               
		[elem setStringValue:fileName];									
	}                                                                   
	else if (elem != nil) {											    
		[self removeChildAtIndex:[[self children] indexOfObject:elem]];	
	}
}

- (NSString *)avatar
{
    return [[self elementForName:@"photo"] stringValue];
}


@end
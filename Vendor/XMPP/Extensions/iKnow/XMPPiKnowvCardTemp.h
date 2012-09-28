//
//  XMPPvCardTempiKnow.h
//  iKnow
//
//  Created by curer on 11-9-25.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPvCardTempBase.h"
#import "XMPPElement.h"

@interface XMPPiKnowvCardTemp : XMPPElement
{
}

+ (XMPPiKnowvCardTemp *)iKnowvCardTempFromElement:(NSXMLElement *)element;
+ (XMPPiKnowvCardTemp *)vCardTempiKnowFromIQ:(XMPPIQ *)iq;
+ (XMPPIQ *)iqvCardRequestForJID:(XMPPJID *)jid;

- (void)setiKnowName:(NSString *)name;
- (NSString *)iKnowName;

- (void)setAvatar:(NSString *)fileName;
- (NSString *)avatar;

@end

//
//  XMPPPubSub+publish.h
//  iKnow
//
//  Created by curer on 11-9-26.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPPubSub.h"


@interface XMPPPubSub(publish)

- (NSString *)publishNode:(NSString *)nodeNameSpace 
              withitem:(NSXMLElement *)item;


@end

//
//  XMPPMessage+iKnowMessage.h
//  iKnow
//
//  Created by curer on 11-9-11.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessage.h"

@interface XMPPMessage(iKnowMsg)

+ (id)addNotifyWithCommentType:(NSXMLElement *)message 
                  andArticleID:(NSString *)articleID;

+ (id)addNotifyWithLoveType:(NSXMLElement *)message
               andArticleID:(NSString *)articleID;

- (BOOL)isiKnowImageMessage;
- (BOOL)isiKnowAudioMessage;

- (NSString *)getiKnowImageMessageImagePath;

- (BOOL)isNotifyMessage;
- (NSString *)notifyType;

@end

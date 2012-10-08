//
//  iKnowXMPPMessage.h
//  iKnow
//
//  Created by curer on 11-9-20.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPModule.h"

@class XMPPStream;
@class XMPPJID;
@class XMPPIQ;
@class XMPPMessage;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPiKnowMessage
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface XMPPiKnowMessage : XMPPModule {
    /**************************************
    * Inherited from XMPPModule:
    * 
    * XMPPStream *xmppStream;
    * 
    * dispatch_queue_t moduleQueue;
    * id multicastDelegate;
    ***************************************/
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue;

- (BOOL)sendArticleNotify:(NSString *)type
              withArticle:(Article *)article
                 withUUID:(NSString *)uuid
              withContent:(NSString *)content;

//返回正确，只是保证参数传递正确，不保证消息送达
- (BOOL)sendTextMessage:(NSString *)content 
               withUser:(NSString *)userID 
                andUUID:(NSString *)uuid;

//返回正确，只是保证参数传递正确，不保证消息送达
- (BOOL)sendImageMessage:(NSString *)imagePath 
                widhUser:(NSString *)userID
                 andUUID:(NSString *)uuid;

@end

@protocol XMPPiKnowMessageDelegate
@optional

- (void)xmppiKnowMessage:(XMPPiKnowMessage *)sender 
          didSendMessage:(XMPPMessage *)message;

- (void)xmppiKnowMessage:(XMPPiKnowMessage *)sender 
       didReceiveMessage:(XMPPMessage *)message;

//这里发送失败，是简单的检测到网络断开，就会报告错误。没有对那个消息发送做控制
//后面会对这个网络不稳定情况优化
- (void)xmppiKnowMessageDidSendMessageFailed:(XMPPiKnowMessage *)sender 
                                   withError:(NSError *)error;

@end

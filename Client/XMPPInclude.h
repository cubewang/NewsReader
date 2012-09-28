//
//  XMPPInclude.h
//  iKnow
//
//  Created by curer on 11-9-22.
//  Copyright 2011 iKnow Team. All rights reserved.
//

/**
* XMPP Architecture 
* 
*                        UI Layer
* XMPPRoster XMPPiKnowUserModule XMPPiKnowMessage XMPPPubSub XMPPAutoPing XMPPReconnect
*                        XMPPStream
**/

/**
* XMPP 设计运行在不同的任务队列中，默认任务队列名为类名，
* 1、新增模块，必须与原有模块独立,且和其他模块不能有任何同步接口（新增模块的下层模块除外）
* 位于上层模块可以阻塞，等待，下层模块运行的结果，或是通过异步调用
* 下层模块的执行过程不依赖与上层模块结果（cancel除外）。
* 
* 如:
    XMPPStream:myJID;
    - (XMPPJID *)myJID
    {
        if (dispatch_get_current_queue() == xmppQueue)
        {
            return myJID;
        }
        else
        {
            __block XMPPJID *result;
 
            dispatch_sync(xmppQueue, ^{
                result = [myJID retain];
            });
 
            return [result autorelease];
        }
    }
* 上层模块调用- (XMPPJID *)myJID 会阻塞自己。
* 如果出现情况 下层模块必须依赖上层模块结果，那么下层模块应该设计成多个部分。
* 有且执行一个任务
* 
* 2、所有模块提供的delegate 都为异步调用, delegate不会阻塞模块的任务队列
* 但并不保证thread safe。
* 如:上层设置xmppStream delegate 的运行任务队列为main_queue, 
* [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];  
* 那么delegate 只能保证运行main_queue 安全，不能保证其他队列同样安全。
**/ 

 

/**
* XMPPStream :
* 基础网络层+XMPP基础协议实现层
* 上层模块任务队列，不能运行在XMPPStream 队列中，XMPPStream 提供的delegate 都是
* 异步调用，不会阻塞XMPPStream
**/

/**
* XMPPRoster :
* 好友名单＋好友状态
**/

/**
* XMPPiKnowMessage
* iKnow 扩展消息协议， 包括图片和音频消息 
**/

/**
* XMPPReconnect
* 网络连接断开，负责重新连接并登录
**/

/**
* XMPPAutoPing
* 服务器心跳，保证客户端状态
**/

/**
* XMPPPubSub
* 发布订阅部分
**/
 
#import "XMPP.h"
#import "XMPPRoster.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPiKnowvCardTempModule.h"

#import "XMPPiKnowMessage.h"
#import "XMPPAutoPing.h"
#import "XMPPPubSub.h"

#import "XMPPiKnowUserAvatar.h"
#import "XMPPiKnowUserModule.h"
#import "XMPPIQRequest.h"
#import "XMPPiKnowStorage.h"
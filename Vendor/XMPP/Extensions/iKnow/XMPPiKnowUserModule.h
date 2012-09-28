//
//  XMPPiKnowUserModule.h
//  iKnow
//
//  Created by curer on 11-9-27.
//  Copyright 2011 iKnow Team. All rights reserved.
//

/*
 @"gender",
 @"latitude",
 @"longitude",
 @"user_id",
 @"email",
 @"nickName",
 @"signature",
 @"userFlag",
 @"subscribeFlag",
 @"photoUrl",
 */

//note: why don't do more safely sync operator
//这里的所有同步操作，都应该在userModule这里有记录
//这样，当这个模块被卸载时，或是delloc时
//我们可以解除这些用于同步的锁。避免deadlock
//但是这里为了简单实现，没有做处理的原因是
//1、我们这个模块不会被卸载,和整个程序生命周期一致
//2、所有的wait操作，已经被指定TIMEOUT，而且大于网络连接时间这样保证了不会出现一直等待情况出现。
//3、wait操作不能使用－1参数，作为永久等待，因为，模块不被卸载，但是，delegate可能被卸载，为了防止
//   这种情况发生，必须指定TIMEOUT 给wait operator

//存在问题
//1、现在的同步接口，只能保证同一时刻，只有一个函数进入
// 原因，只有一个receipt，多次会覆盖，导致receipt 失效

//这里的局限性很大，但是，却能满足现在的需求，所以，使用同步接口，需要注意
//1、同步操作中，不能嵌套同步操作
//2、本模块不能调用这些同步接口

#import <Foundation/Foundation.h>
#import "XMPPModule.h"

@class XMPPIDTracker;
@class XMPPiKnowStorage;
@class XMPPElementReceipt;
@class MemberCoreDataObject;
@class XMPPIQRequest;

@interface XMPPiKnowUserModule : XMPPModule {
    XMPPIDTracker *xmppIDTracker;
    
    XMPPiKnowStorage *xmppiKnowStorage;
    
    NSDictionary *userInfoForSet;
    NSDictionary *userInfoForOneProperty;
    NSDictionary *returnSyncValue;
    NSArray *returnSyncMultiValue;
    
    NSString *newPassword;
    
    XMPPElementReceipt *receipt;
    
    XMPPIQRequest *iqResquest;
}

@property (nonatomic, copy) NSDictionary *userInfoForSet;
@property (nonatomic ,copy) NSDictionary *userInfoForOneProperty;
@property (nonatomic, copy) NSDictionary *returnSyncValue;
@property (nonatomic, copy) NSArray *returnSyncMultiValue;
@property (nonatomic, copy) NSString *newPassword;

- (id)initWithDispatchQueue:(dispatch_queue_t)queue;
- (id)initWithDispatchQueue:(dispatch_queue_t)queue andStorage:(XMPPiKnowStorage *)storage;
- (void)activeIQRequest:(XMPPIQRequest *)request;

#pragma mark baseMethod
- (BOOL)queryUserInfo;
- (NSDictionary *)queryUserInfoSync;
- (BOOL)queryUserInfoWithUserID:(NSString *)userID;
- (NSDictionary *)queryUserInfoWithUserIDSync:(NSString *)userID;

- (NSDictionary *)queryLocalUserInfo;
- (NSDictionary *)queryLocalUserInfoWithUserID:(NSString *)userID;

//设置整个userInfo
- (BOOL)setUserInfoWithDic:(NSDictionary *)dic;
- (BOOL)setUserInfoWithDicSync:(NSDictionary *)dic;

//设置部分userInfo属性
- (BOOL)setUserInfoWithObject:(NSString *)stringValue andKey:(NSString *)key;
- (BOOL)setUserInfoWithObjectSync:(NSString *)stringValue andKey:(NSString *)key;

#pragma mark server layer

- (BOOL)changePassword:(NSString *)password;
- (BOOL)changePasswordSync:(NSString *)password;

- (BOOL)subscribeTag:(NSString *)articleTag withUserID:(NSString *)userID;
- (BOOL)unsubscribeTag:(NSString *)articleTag withUserID:(NSString *)userID;

- (BOOL)subscribeTagSync:(NSString *)articleTag withUserID:(NSString *)userID;

- (BOOL)querySurroundWithLatitude:(double)latitude 
                        Longitude:(double)longitude 
                            Limit:(double)limit;

- (void)queryUserStatus;
- (NSArray *)queryOnLine;

@end

@protocol XMPPiKnowUserModuleDelegate

- (void)xmppiKnowUserModule:(XMPPiKnowUserModule *)sender 
            userInfoChanged:(MemberCoreDataObject *)memberCoreDataObject;

- (void)xmppiKnowUserModule:(XMPPiKnowUserModule *)sender 
                queryFinish:(NSDictionary *)userDic;

- (void)xmppiKnowUserModule:(XMPPiKnowUserModule *)sender 
             queryWithError:(NSError *)error;

- (void)xmppiKnowUserModule:(XMPPiKnowUserModule *)sender 
                  setFinish:(NSDictionary *)userDic;

- (void)xmppiKnowUserModule:(XMPPiKnowUserModule *)sender 
               setWithError:(NSError *)error;

- (void)chanagedPasswordFinish:(XMPPiKnowUserModule *)sender 
               withNewPassword:(NSString *)password;

- (void)chanagedPasswordError:(XMPPiKnowUserModule *)sender 
                    withError:(NSError *)error;

- (void)xmppiKnowUserModule:(XMPPiKnowUserModule *)sender
            multiUserInfo:(NSArray *)userInfoArray;

@end


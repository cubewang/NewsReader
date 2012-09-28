//  RORequestParam.h
//  Renren Open-platform
//
//  Created by xiawenhai on 11-8-12.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <Foundation/Foundation.h>
#import "ROResponse.h"

/**
 *封装请求参数的基类
 */

@class ROResponse;

@interface RORequestParam : NSObject {
	NSString *_method;
	NSString *_format;
	NSString *_apiVersion;
	NSString *_apiKey;
	NSString *_sessionKey;
	NSString *_callID;
	NSString *_sig;
	NSString *_xn_ss;
}

/**
 *请求的API方法
 */
@property (copy,nonatomic)NSString *method;

/**
 *返回数据的格式
 */
@property (copy,nonatomic)NSString *format;

/**
 *API的版本号
 */
@property (copy,nonatomic)NSString *apiVersion;

/**
 *应用的appkey
 */
@property (copy,nonatomic)NSString *apiKey;

/**
 *认证应用和用户的sessionkey
 */
@property (copy,nonatomic)NSString *sessionKey;

/**
 *call_id
 */
@property (copy,nonatomic)NSString *callID;

/**
 *计算得到的签名
 */
@property (copy,nonatomic)NSString *sig;

/**
 *返回值的格式
 */
@property (copy,nonatomic)NSString *xn_ss;

/**
 *将封装好的各个参数解析为字典
 */
-(NSMutableDictionary*)requestParamToDictionary;

/**
 *将返回的数据整理为ROResponse
 */
-(ROResponse *)requestResultToResponse:(id)result;

/**
 *将派生类中封装的各个参数加入字典
 */
-(void)addParamToDictionary:(NSMutableDictionary*)dictionary;

@end

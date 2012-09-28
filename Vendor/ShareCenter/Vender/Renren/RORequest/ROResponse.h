//
//  ROResponse.h
//  SimpleDemo
//
//  Created by Winston on 11-8-16.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import <Foundation/Foundation.h>

@class ROError;
@class RORequestParam;
@interface ROResponse : NSObject{
    id _rootObject;
    ROError *_error;
    RORequestParam *_param;
}
/**
 * 接口返回的正确处理对象
 * 对象类型：ROResponseItem | NSArray 
 * 请调用者自行判断。
 */
@property(nonatomic, retain)id rootObject;
/**
 * 接口返回的错误对象.
 */
@property(nonatomic, retain)ROError *error;
/**
 * 接口请求的参数对象
 * 用于调用者判断是那个接口返回的response;
 */
@property(nonatomic, retain)RORequestParam *param;
/**
 * 返回由Rest接口正确信息构建的Response对象.
 */
+(ROResponse *)responseWithRootObject:(id)rootObject;
/**
 * 返回由Rest接口错误信息构建的Response对象.
 */
+(ROResponse *)responseWithError:(ROError *)error;
@end

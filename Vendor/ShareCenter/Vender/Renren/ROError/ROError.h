//
//  ROError.h
//  SimpleDemo
//
//  Created by Winston on 11-8-15.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <Foundation/Foundation.h>

#define kROErrorDomain @"Renren Open-platform"
#define kROUnknowDialogErrorCode 99999999
@interface ROError : NSError{
    
}
/**
 * 返回由oAuth接口返回错误信息构建的错误对象.
 */
+ (ROError*)errorWithOAuthResult:(NSDictionary*)result;

/**
 * 返回由Rest接口错误信息构建的错误对象.
 */
+ (ROError*)errorWithRestInfo:(NSDictionary*)restInfo;


/**
 * 返回由NSError构建的错误对象.
 */
+ (ROError*)errorWithNSError:(NSError*)error;

/**
 * 构造ROError错误。
 *
 * @param code 错误代码
 * @param errorMessage 错误信息
 *
 * 返回错误对象.
 */
+ (ROError*)errorWithCode:(NSInteger)code errorMessage:(NSString*)errorMessage;

/**
 * 返回错误描述
 */
- (NSString *)localizedDescription;
/**
 * 返回调用Rest Api 的 method字段的值.
 */
- (NSString*)methodForRestApi;
@end

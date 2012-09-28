//
//  ROPasswordFlowRequestParam.h
//  Renren Open-platform
//
//  Created by xiawenhai on 11-8-17.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <Foundation/Foundation.h>
#import "RORequestParam.h"


@interface ROPasswordFlowRequestParam : RORequestParam {
	NSString *_userName;
	NSString *_passWord;
	NSString *_grantType;
	NSString *_secretKey;
	NSString *_scope;
}

/**
 *用户名
 */
@property (copy,nonatomic)NSString *userName;

/**
 *密码
 */
@property (copy,nonatomic)NSString *passWord;

/**
 *授权的类型
 */
@property (copy,nonatomic)NSString *grantType;

/**
 *secret key
 */
@property (copy,nonatomic)NSString *secretKey;

/**
 *需要授权的项目
 */
@property (copy,nonatomic)NSString *scope;


@end

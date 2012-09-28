//  ROUserInfoRequestParam.h
//  Renren Open-platform
//
//  Created by xiawenhai on 11-8-12.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <Foundation/Foundation.h>
#import "RORequestParam.h"

/**
 *封装了用户信息请求参数的类
 */
@interface ROUserInfoRequestParam : RORequestParam {
	NSString *_userIDs;
	NSString *_fields;
}

/**
 *用户的ID。多个相册的ID,以逗号分隔
 */
@property (copy,nonatomic)NSString *userIDs;

/**
 *请求的字段
 */
@property (copy,nonatomic)NSString *fields;

@end

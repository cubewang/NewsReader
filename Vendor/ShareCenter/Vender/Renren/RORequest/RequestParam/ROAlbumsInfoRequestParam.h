//  ROAlbumsInfoRequestParam.h
//  Renren Open-platform
//
//  Created by xiawenhai on 11-8-12.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <Foundation/Foundation.h>
#import "RORequestParam.h"

/**
 *封装了获取相册信息请求参数的类
 */
@interface ROAlbumsInfoRequestParam : RORequestParam {
	NSString *_page;
	NSString *_count;
	NSString *_albumIDs;
	NSString *_userID;
}

/**
 *分页的页数
 */
@property (copy,nonatomic)NSString *page;

/**
 *分页后每页的个数
 */
@property (copy,nonatomic)NSString *count;

/**
 *相册的ID。多个相册的ID,以逗号分隔,最多支持10个数据
 */
@property (copy,nonatomic)NSString *albumIDs;

/**
 *相册所有者的用户ID
 */
@property (copy,nonatomic)NSString *userID;

@end

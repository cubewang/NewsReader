//
//  ROUtility.h
//  RenrenSDKDemo
//
//  Created by Tora on 11-8-23.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import <Foundation/Foundation.h>

/**
 * Renren SDK中的工具类。
 * 包含了主要用于数据处理和转换的工具方法集。
 * 所有方法均以类方法形式调用，使用时，类型本身没有实例化的必要。
 */

@interface ROUtility : NSObject

/**
 * 解析URL参数的工具方法。
 */
+ (NSDictionary *)parseURLParams:(NSString *)query;

/*
 * 使用传入的baseURL地址和参数集合构造含参数的请求URL的工具方法。
 */
+ (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params;

/*
 * 根据指定的参数名，从URL中找出并返回对应的参数值。
 */
+ (NSString *)getValueStringFromUrl:(NSString *)url forParam:(NSString *)param;

/**
 * 对输入的字符串进行MD5计算并输出验证码的工具方法。
 */
+ (NSString *)md5HexDigest:(NSString *)input;

/**
 * 针对人人开放平台接口传参需求生成随机CallId的工具方法。
 */
+ (NSString *)generateCallId;

/**
 * 针对人人开放平台接口传参需求计算sig码的工具方法。
 */
+ (NSString *)generateSig:(NSMutableDictionary *)paramsDict secretKey:(NSString *)secretKey;

/**
 * 对字符串进行URL编码转换。
 */
+ (NSString*)encodeString:(NSString*)string urlEncode:(NSStringEncoding)encoding;

/**
 * 将日期字符串转换为字符串类型。
 */
+ (NSDate *)getDateFromString:(NSString *)dateTime;

/**
 * 将传入的图像加文字水印。
 */
+ (UIImage *)getImageWithWatermark:(UIImage *)inImage;

/**
 * 用accesstoken 获取调用api 时用到的参数session_secret
 */
+(NSString *)getSecretKeyByToken:(NSString *)token;

/**
 * 用accesstoken 获取调用api 时用到的参数session_key
 */
+(NSString *)getSessionKeyByToken:(NSString *)token;

@end



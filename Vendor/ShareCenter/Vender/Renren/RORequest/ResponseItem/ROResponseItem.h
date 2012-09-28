//
//  ROResponseItem.h
//  SimpleDemo
//
//  Created by Winston on 11-8-12.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <Foundation/Foundation.h>

@interface ROResponseItem : NSObject{
    NSDictionary* _responseDictionary;
    NSString* _result;
}

/*
 *表示操作的返回码;result;1表示操作成功，其他则为错误码
 *只有操作类的API才回返回此字段，用于表示操作是否成功,无其他含义。
 */
@property(nonatomic, readonly)NSString *result;

/**
 * 生成一个ROResponseItem 
 * @param responseDictionary 传入的由json解析完后字典对象
 * 返回一个ROResponseItem
 */
+(ROResponseItem*)itemWithDictionary:(NSDictionary*)responseDictionary;
/*
 *初始化ROResponseItem
 */
-(id)initWithDictionary:(NSDictionary*)responseDictionary;

/*
 *表示对应的json字典对象。 
 */
-(NSDictionary*)responseDictionary;


-(id)valueForItemKey:(NSString*)key;
@end


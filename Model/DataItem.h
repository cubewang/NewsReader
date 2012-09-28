//
//  Article.h
//  iKnow
//
//  Created by Cube on 11-4-23.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataItem : NSObject {
    
    NSString *_ItemId;     //该Item的Id
    NSString *_ItemType;   //该Item的类型：生词、文章等
    NSString *_CreateTime; //创建时间
    NSString *_LastUpdateTime;
    NSString *_Data1; //约定存放单词的Key、文章的Id
    NSString *_Data2; //约定存放单词的一个词性、文章的Name
    NSString *_Data3; //约定存放单词的Pronunciation、文章的PublishedDate
    NSString *_Data4; //约定存放单词的PhoneticSymbol、文章为空
    NSString *_Data5; //约定存放单词的一个词义、文章为空
}

@property (nonatomic, copy) NSString *ItemId;
@property (nonatomic, copy) NSString *ItemType;
@property (nonatomic, copy) NSString *CreateTime;
@property (nonatomic, copy) NSString *LastUpdateTime;
@property (nonatomic, copy) NSString *Data1;
@property (nonatomic, copy) NSString *Data2;
@property (nonatomic, copy) NSString *Data3;
@property (nonatomic, copy) NSString *Data4;
@property (nonatomic, copy) NSString *Data5;

- (id)initWithJsonDictionary:(NSDictionary*)dictionary;

@end
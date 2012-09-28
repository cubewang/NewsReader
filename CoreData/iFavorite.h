//
//  iFavorite.h
//  EnglishFun
//
//  Created by Cube Wang on 12-7-17.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface iFavorite : NSManagedObject

@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSString * articleDescription;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * articleId;
@property (nonatomic, retain) NSString * contentTags;
@property (nonatomic, retain) NSString * createDate;
@property (nonatomic, retain) NSString * openCount;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;

@end

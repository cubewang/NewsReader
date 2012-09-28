//
//  FavoriteHelper.h
//  EnglishFun
//
//  Created by Cube Wang on 12-7-16.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoriteHelper : NSObject

@property (nonatomic, retain) NSManagedObjectContext *context;

+ (FavoriteHelper*) instance;
- (BOOL)isFavorite:(NSString *)articleId;
- (BOOL)addFavorite:(Article *)newFavorite;
- (BOOL)deleteFavorite:(NSString *)articleId;

@end

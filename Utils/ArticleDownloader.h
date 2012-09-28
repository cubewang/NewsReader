//
//  ArticleDownloader.h
//  EnglishFun
//
//  Created by curer on 12-2-16.
//  Copyright 2012 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Parser;
@class ContentInfo;

@interface ArticleDownloader: NSObject {
    NSMutableArray *articleItems; // 文章列表
    NSMutableArray *articleItemsCached; 
    NSMutableArray *audioList;
    
    int articleCountBeforeLoading; //分段请求前的文章数，用于记录是否请求完所有服务器的文章
    //内容解析
    ContentInfo* contentInfo;
    
    Parser *parser;
    BOOL failedToLoad;
    
    BOOL bSuccess;
    
    id  delegate;
    
    BOOL bCancel;
    
    NSString *downloadTags;
    
    NSDictionary *userInfo;
    
    BOOL bDownLoadAudio;
}

@property (nonatomic, retain) NSMutableArray *articleItems;
@property (nonatomic, retain) NSMutableArray *articleItemsCached;
@property (nonatomic, retain) NSMutableArray *audioList;

@property (nonatomic, retain) Parser *parser;
@property (nonatomic, retain) ContentInfo* contentInfo;
@property (nonatomic, retain) NSString *downloadTags;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSDictionary *userInfo;
@property (nonatomic, assign) BOOL bDownLoadAudio;

//@property (nonatomic, retain) Downloader *downloader;

+ (ArticleDownloader *)shareInstance;

- (BOOL)downloadSync:(NSString *)tag;
- (BOOL)downloadFollowSync:(NSString *)userID;
- (BOOL)downloadLastestSync;

- (void)cancel;
- (void)reset;
- (BOOL)isCancel;

@end

@protocol ArticleDownloaderDelegate

- (void)downloadFinished:(ArticleDownloader *)downloader;
- (void)downloadError;
- (void)downloadArticleFinished:(NSInteger)index 
                        withSum:(NSInteger)sum;

@end


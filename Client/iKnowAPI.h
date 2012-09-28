//
//  iKnowAPI.h
//  iKnow
//
//  Created by Cube on 11-9-21.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONParser.h"
#import "XMLParser.h"
#import "Downloader.h"
              

#define IKNOW_OFFICIAL_ID   @"official_id"

#define MAIN_PROCOTOL       @"http://"

#define MAIN_HOST           @"192.168.1.108"
#define MAIN_PORT           @":80"  

#define MAIN_PATH_C         @"/path/"
#define MAIN_PATH_U         MAIN_PATH_C
#define MAIN_PATH_A         MAIN_PATH_C

#define MAIN_PATH           MAIN_PATH_C


#define CONTENT_LIST_PATH    @"content_list.do"
#define CONTENT_PATH         @"content.do"
#define ADD_CONTENT_PATH     @"add_content.do"
#define SET_CONTENT_TAG_PATH @"set_content_tag.do"

#define TAG_LIST_PATH        @"tag_list.do"

#define COMMENT_LIST_PATH    @"comment_list.do"
#define ADD_COMMENT_PATH     @"add_comment.do"

#define FAVORITE_LIST_PATH   @"favorite_list.do"
#define EDIT_FAVORITE_PATH   @"edit_favorite.do"

#define WORD_LIST_PATH       @"word_list.do"
#define EDIT_WORD_PATH       @"edit_word.do"

#define JSESSION_PATH        @"index.do"

#define FEEDBACK_PATH         @"feedback.do"

#define THUMB_IMAGE_PATH    @"resize_img.do"


//admin

#define DELETE_ARTICLE      @"content_edit.do"

//Others

#define SHORT_URL_PATH   @"http://api.t.sina.com.cn/short_url/shorten.json"
#define SHORT_URL_KEY    kShareToCNKey

#define BINGURL  @"http://api.microsofttranslator.com/v2/Http.svc/Translate?text=" 
#define BING_TOKEN @"https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
#define SCOPE   @"http://api.microsofttranslator.com"
#define GRANTTYPE  @"client_credentials"

// Delegate
// dataType:
// FriendList, SubscribedTags
@protocol DataChangedDelegate <NSObject>
@optional
- (void)dataDidChanged:(NSString *)dataType;
@end


@interface iKnowAPI : NSObject {

}

/********************************
 文章相关
 ********************************/

//获取文章列表，根据UserId、Tag列表、列表的开始位置和长度，
//userId、tagArray都不为空：取得userId用户tagArray标签下的文章列表，
//userId不为空、tagArray为空：取得userId用户的文章列表，
//userId为空、tagArray不为空：取得tagArray标签下的文章列表，
//userId、tagArray都为空：取得最新的文章列表。
+ (Parser *)getArticleList:(NSString *)userId
                  tagArray:(NSArray *)tagArray
             startPosition:(NSUInteger)startPosition
                    length:(NSUInteger)length
                  delegate:(id<ParserDelegate>)delegate
             useCacheFirst:(BOOL)useCacheFirst;

+ (Parser *)getArticleListSync:(NSString *)userId
                      tagArray:(NSArray *)tagArray
                 startPosition:(NSUInteger)startPosition
                        length:(NSUInteger)length
                      delegate:(id<ParserDelegate>)delegate
                 useCacheFirst:(BOOL)useCacheFirst;

//获取好友的文章列表，
//tagArray为空：取得所有好友发布的文章列表
+ (Parser *)getSubscribedList:(NSArray *)tagArray
               startPosition:(NSUInteger)startPosition
                      length:(NSUInteger)length 
                    delegate:(id<ParserDelegate>)delegate
               useCacheFirst:(BOOL)useCacheFirst;

+ (Parser *)getSubscribedList:(NSArray *)tagArray
                startPosition:(NSUInteger)startPosition
                       length:(NSUInteger)length 
                     delegate:(id<ParserDelegate>)delegate
                useCacheFirst:(BOOL)useCacheFirst
               connectionType:(ConnectionType)type
                       userID:(NSString *)userId;

//获得文章内容的url地址
+ (NSString *)getContentPath:(NSString *)articleId;

//获得文章内容分享的url地址
+ (NSString *)getShareArticlePath:(NSString *)articleId;

//获取文章内容
+ (Downloader *)getContent:(NSString *)articleId 
                  delegate:(id<DownloaderDelegate>)delegate
             useCacheFirst:(BOOL)useCacheFirst;

+ (Downloader *)getContentSync:(NSString *)articleId 
                      delegate:(id<DownloaderDelegate>)delegate
                 useCacheFirst:(BOOL)useCacheFirst;

+ (Parser *)getRelatedArticle:(Article *)article
                      delegate:(id<ParserDelegate>)delegate;

//发布内容
+ (BOOL)publishContentText:(NSString *)content 
                  title:(NSString *)title 
                summary:(NSString *)summary 
                   tags:(NSArray *)tagArray
               coverUrl:(NSString *)url;

+ (BOOL)publishContentImage:(NSString *)imageServerReturnedPath 
              imageWidth:(int)width
             imageHeight:(int)height
                   title:(NSString *)title 
                 summary:(NSString *)summary 
                    andText:(NSString *)text 
                    tags:(NSArray *)tagArray
                coverUrl:(NSString *)url;


/********************************
 关注相关
 ********************************/

//设置和取消好友变更通知的回调，需要匹对使用
+ (BOOL)addFriendListChangedDelegate:(id<DataChangedDelegate>)delegate;
+ (BOOL)removeFriendListChangedDelegate:(id<DataChangedDelegate>)delegate;

//告知iKnowAPI用户的好友列表已经发生变化
+ (void)didFriendListChanged;


/********************************
 标签相关
 ********************************/

//获取当前iKnow上所有的内容标签
+ (Parser *)getTagList:(id<ParserDelegate>)delegate useCacheFirst:(BOOL)useCacheFirst;

+ (NSArray *)getTagGroups;

//获得用户订阅的内容标签数组
+ (NSArray *)getSubscribedTags;

//订阅和退订内容标签
+ (BOOL)subscribeTag:(NSString *)articleTag withUserID:(NSString *)userID;
+ (BOOL)unsubscribeTag:(NSString *)articleTag withUserID:(NSString *)userID;

//设置和取消标签变更通知的回调，需要匹对使用
+ (BOOL)addSubscribedTagsChangedDelegate:(id<DataChangedDelegate>)delegate;
+ (BOOL)removeSubscribedTagsChangedDelegate:(id<DataChangedDelegate>)delegate;

//告知iKnowAPI用户订阅的标签已经发生变化
+ (void)didSubscribedTagsChanged;


/********************************
 评论相关
 ********************************/

//根据文章Id获取评论列表
+ (Parser *)getCommentList:(NSString *)articleId 
                  delegate:(id<ParserDelegate>)delegate
             useCacheFirst:(BOOL)useCacheFirst;

//发表评论
+ (BOOL)submitComment:(NSString *)articleId
              comment:(NSString *)comment;


/********************************
 生词相关
 ********************************/

//获取userId用户的生词列表
+ (Parser *)getWordList:(NSString *)userId
               delegate:(id<ParserDelegate>)delegate
          useCacheFirst:(BOOL)useCacheFirst
         connectionType:(ConnectionType)connectionType;

//在线查询生词
+ (Parser *)queryWordOnline:(NSString *)word 
                   delegate:(id<ParserDelegate>)delegate
              useCacheFirst:(BOOL)useCacheFirst;

+ (Parser *)querySentenceOnline:(NSString *)sentence
                       delegate:(id<ParserDelegate>)delegate
                  useCacheFirst:(BOOL)useCacheFirst;

//添加和删除生词
+ (BOOL)addWord:(Word *)word;
+ (BOOL)addWords:(NSArray *)dictionaryArray;
+ (BOOL)deleteWord:(NSString *)word;
+ (BOOL)deleteWords:(NSArray *)dictionaryArray;


/********************************
 收藏相关
 ********************************/

//获取收藏列表
+ (Parser *)getFavoriteList:(NSString *)userId
                   delegate:(id<ParserDelegate>)delegate
              useCacheFirst:(BOOL)useCacheFirst
             connectionType:(ConnectionType)connectionType;

//添加和删除收藏
+ (BOOL)addFavorite:(Article *)article;
+ (BOOL)addFavorites:(NSArray *)dictionaryArray;
+ (BOOL)deleteFavorite:(NSString *)articleId;
+ (BOOL)deleteFavorites:(NSArray *)dictionaryArray;


/********************************
 其它
 ********************************/

//取得最新版本信息
+ (Parser *)getLastestVerson:(id<ParserDelegate>)delegate;

//根据path取得完整的Url地址
+ (NSString *)getPath:(NSString *)path;

//根据上传serverPath 找到锁略图imageserverpath
+ (NSString *)getThumbImageServerPath:(NSString *)serverPath 
                            thumbWidh:(int)width;

//根据path取得完整文件下载Url
+ (NSString *)getDownloadFilePath:(NSString *)path;

//获得微博短地址
+ (NSString *)getShortUrl:(NSString *)longUrl delegate:(id<ParserDelegate>)delegate;

#pragma mark userInfo

//取得当前用户的Id
+ (NSString *)getUserId;
+ (NSDictionary *)getUserLocalInfoWithUserID:(NSString *)userID;
+ (NSString *)getUserLocalAvatar:(NSString *)userID;
+ (NSString *)getUserLocalName:(NSString *)userID;

//没有本地数据，则请求网络
+ (void)updateUserInfoFromServer:(NSString *)userID;

+ (NSDictionary *)checkUpdate;

+ (NSArray *)getSuggestionUserIDList;

//admin
+ (BOOL)deleteArticleWithArticleID:(NSString *)articleID;

@end

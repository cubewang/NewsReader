//
//  ArticleDownloader.m
//  EnglishFun
//
//  Created by curer on 12-2-16.
//  Copyright 2012 iKnow Team. All rights reserved.
//

#import "ArticleDownloader.h"
#import "Downloader.h"
#import "Parser.h"
#import "ContentFormatterFactory.h"
#import "ContentInfo.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "SDImageCache.h"

static const int ddLogLevel = LOG_FLAG_ERROR;

@implementation ArticleDownloader

//@synthesize downloader;
@synthesize articleItems;
@synthesize articleItemsCached;
@synthesize audioList;
@synthesize parser;
@synthesize contentInfo;
@synthesize delegate;
@synthesize downloadTags;
@synthesize userInfo;
@synthesize bDownLoadAudio;

static ArticleDownloader *s_articleDownloader = nil;

+ (ArticleDownloader *)shareInstance
{
    @synchronized(self) 
    {
        if (s_articleDownloader == nil) {
            s_articleDownloader = [[ArticleDownloader alloc] init];
        }
    }
    
    return s_articleDownloader;
}

- (void)downloadArticle:(Article *)article
{
    if (article == nil) {
        return;
    }
    
    Downloader *downloader = 
        [iKnowAPI getContentSync:article.Id delegate:self useCacheFirst:YES];
    
    NSString *url = article.ImageUrl;
    if ([url length] == 0) {
        return;
    }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    NSString *downloadPath = [[SDImageCache sharedImageCache] cachePathForKey:url];
    
    [request setDownloadDestinationPath:downloadPath];
    
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
    [request setUseCookiePersistence:YES];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
    [request startSynchronous];
    
    if ([request error]) {
        DDLogInfo(@"download imageurl error %@ path %@", url, downloadPath);
        return;
    }
    else {
        DDLogInfo(@"download imageurl = %@ path %@", url, downloadPath);
    }
}

- (void)reset
{
    bCancel = NO;
    bDownLoadAudio = NO;
    
    self.audioList = [[NSMutableArray alloc] init];
    [self.audioList release];
    
    delegate = nil;
}

- (BOOL)isCancel
{
    return bCancel;
}

- (void)cancel
{
    [self.parser cancel];
    delegate = nil;
    
    self.userInfo = nil;
    bCancel = YES;
    
    self.audioList = nil;
}

- (void)downloadArticles:(NSArray *)articleList
{
    [articleList retain];
    
    int sum = [articleList count];
    if (sum) {
    
        for (int index = 0; index < sum; ++index) {
            if (bCancel) {
                DDLogError(@"%d, receive cancel");
                break;
            }
            
            [self downloadArticle:[articleList objectAtIndex:index]];
            
            if ([delegate respondsToSelector:@selector(downloadArticleFinished:withSum:)]) {
                [delegate downloadArticleFinished:index 
                                          withSum:sum];
            }
        }
        
        if ([delegate respondsToSelector:@selector(downloadFinished:)]) {
            [delegate downloadFinished:self];
        }
    }
    
    [articleList release];
}

- (BOOL)downloadFollowSync:(NSString *)userID
{
    if (bCancel) {
        return NO;
    }
    
    bSuccess = YES;
    
    Parser *result = [iKnowAPI getSubscribedList:nil 
                                   startPosition:0 
                                          length:20 
                                        delegate:self 
                                useCacheFirst:NO
                                  connectionType:ConnectionTypeSynchronously
                                          userID:userID];
    self.parser = result;
    
    if (!result) {
        bSuccess = NO;
    }
    
    return bSuccess;
}

- (BOOL)downloadLastestSync
{
    if (bCancel) {
        return NO;
    }
    
    bSuccess = YES;
    
    Parser *result = [iKnowAPI getArticleListSync:nil 
                                         tagArray:nil
                                    startPosition:0 
                                           length:20 
                                         delegate:self 
                                    useCacheFirst:NO];
    
    self.parser = result;
    
    if (!result) {
        bSuccess = NO;
    }
    
    return bSuccess;
}

- (BOOL)downloadSync:(NSString *)tag
{
    if ([tag length] == 0) {
        return NO;
    }
    
    if (bCancel) {
        return NO;
    }
    
    bSuccess = YES;
    
    Parser *result = [iKnowAPI getArticleListSync:nil 
                                         tagArray:[NSArray arrayWithObject:tag]
                                    startPosition:0 
                                           length:20 
                                         delegate:self 
                                    useCacheFirst:NO];
    
    self.parser = result;
    
    if (!result) {
        bSuccess = NO;
    }
    
    return bSuccess;
}

- (id)init
{
    if (self = [super init]) {
        articleItems = [[NSMutableArray alloc] init];
        articleItemsCached = [[NSMutableArray alloc] init];
        audioList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    delegate = nil;
    
    self.userInfo = nil;
    [articleItems release];
    [articleItemsCached release];
    [audioList release];
    [contentInfo release];
    
    [parser cancel];
    [parser release];
    
    [super dealloc];
}

#pragma mark parser

- (void)parserDidStart:(Parser *)parser {
    
}

- (void)parser:(Parser *)parser didParseArticle:(Article *)article {
    
    if (!article)
        return;
    
    NSDictionary *aUserInfo = nil;
    
    int width = [[UIScreen mainScreen] scale] * 200;
    article.ImageUrl = [iKnowAPI getThumbImageServerPath:article.ImageUrl thumbWidh:width];
    
    article.AvatarImageUrl = [iKnowAPI getThumbImageServerPath:article.AvatarImageUrl 
                                                     thumbWidh:[[UIScreen mainScreen] scale] * 80];
    
    if (aUserInfo == nil) 
    {
        if ([article.UserName length] == 0) 
        {
            article.UserName = DEFAULT_NAME;
        }
    }
    else 
    {
        article.UserName = [aUserInfo objectForKey:@"nickName"];
        
        if ([article.UserName length] == 0) {
            article.UserName = DEFAULT_NAME;
        }
    }
    
    [articleItemsCached addObject:article];
}


- (void)parserDidFinish:(Parser *)parser {
    
    if ([articleItemsCached count] == 0) //articleItems没有内容
    {
        self.articleItems = [articleItemsCached copy];
        [self.articleItems release];
        [articleItemsCached removeAllObjects];
        if (failedToLoad)
        {
            failedToLoad = NO;
        }
        
        return;
    }
    
    //如果articleItems没有增长，说明已经请求完所有服务器的文章
    if (articleCountBeforeLoading == [articleItemsCached count] 
        && articleCountBeforeLoading == [articleItems count]) 
    {
        //没有更多内容了
        //[[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:self.view info:@"没有更多内容了"];
    }
    
    self.articleItems = [articleItemsCached copy];
    [self.articleItems release];
    
    if (failedToLoad)
    {
        failedToLoad = NO;
    }
    
    [self downloadArticles:self.articleItems];
}

- (void)parser:(Parser *)parser didFailWithError:(NSString *)error
{
    failedToLoad = YES;
}

#pragma mark Downloader

- (void)downloader:(Downloader *)downloader didFailWithError:(NSString *)error{
    
    //[self didFailWithLoadingArticle:NO];
    
    bSuccess = NO;
    
    return;
}

- (void)downloadImage:(NSString *)url
{
    if ([url length] == 0) {
        return;
    }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
    [request setUseCookiePersistence:YES];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
    [request startSynchronous];
    
    if ([request error]) {
        DDLogInfo(@"download imageurl error %@", url);
        return;
    }
    else {
        DDLogInfo(@"download imageurl = %@", url);
    }
}

- (void)downloadAudio:(NSString *)url
{
    if ([url length]) {
        
        int iPos = 0;
        for (NSString *item in audioList) {
            if ([item isEqualToString:url]) {
                break;
            }
            iPos++;
        }
        
        if (iPos == [audioList count]) {
            [audioList addObject:url];
        }
    }
}

- (void)downloader:(Downloader *)downloader didDownloadData:(NSData *)data
{
    if (data == nil)
        return;
    
    NSString *articleString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    DDLogInfo(@"%@", articleString);
    
    self.contentInfo = [[ContentFormatterFactory example] formatContent:nil 
                                                            contentData:data 
                                                           articleTitle:nil];
    
    if (self.contentInfo == nil || [self.contentInfo.formattedString length] < 5) {
        [self didFailWithLoadingArticle:YES];
        
        return;
    }
    
    for (NSString *url in self.contentInfo.imageURLList)  {
    
        [self downloadImage:url];
    }
   
    if (bDownLoadAudio) {
        NSDictionary *dic = [self.contentInfo.audioList lastObject];
        NSString *audioUrl = [dic objectForKey:@"downUrl"];
        [self downloadAudio:audioUrl];
    }
    
    DDLogInfo(@"%@", contentInfo.formattedString);
}

@end

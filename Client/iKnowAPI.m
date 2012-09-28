//
//  iKnowAPI.m
//  iKnow
//
//  Created by Cube on 11-9-21.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "iKnowAPI.h"
#import "ASIFormDataRequest.h"
#import "NSObject+SBJson.h"

#import "iKnowXMPPClient.h"
#import "XMPPiKnowUserModule.h"
#import "HTMLBuilder.h"
#import "SBJsonWriter.h"

#import "TagGroup.h"

static const int ddLogLevel = LOG_FLAG_ERROR;


@interface iKnowAPI (PrivateAPI)

+ (XMPPiKnowUserModule *)getUserModule;

@end


@implementation iKnowAPI

+ (BOOL)postRequestSynchronously:(NSString *)requestUrl postParam:(NSString *)jsonString
{
    //配置POST参数
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setPostValue:jsonString forKey:@"json"];
    
    request.responseEncoding = NSUTF8StringEncoding;
    
    [request startSynchronous];
    
    BOOL result = NO;
    
    //如果连接服务器发生错误，则返回NO
    NSError *error = [request error];
    if (!error) 
    {
        //TODO:服务器返回的不一定的jsonvalue 这里出现过404等其他情况
        NSString *responseString = request.responseString;
        NSDictionary *responseDic = [Client analysePOSTData:responseString];
        
        //如果用户名和密码错误，则返回NO
        if ([[responseDic objectForKey:@"code"] isEqualToString:@"1"] ) 
            result = YES;
        else {
            DDLogError(@"publish error %@", responseString);
        }
    } 
    else
    {
        DDLogError(@"network error or server error");
        result = NO;
    }

    [request release];
    
    return result;
}

+ (Parser *)getArticleList:(NSString *)userId
                  tagArray:(NSArray *)tagArray
             startPosition:(NSUInteger)startPosition
                    length:(NSUInteger)length
                  delegate:(id<ParserDelegate>)delegate
             useCacheFirst:(BOOL)useCacheFirst
            connectionType:(ConnectionType)type
{
    if (length == 0 || delegate == nil)
        return nil;
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    
    if (userId) {
        [jsonDictionary setObject:[NSArray arrayWithObject:userId] forKey:@"create_user"];
    }
    
    if (tagArray) {
        [jsonDictionary setObject:tagArray forKey:@"tags"];
    }
    
    [jsonDictionary setObject:[NSString stringWithFormat:@"%d", startPosition] forKey:@"offset"];
    [jsonDictionary setObject:[NSString stringWithFormat:@"%d", length] forKey:@"length"];
    
    NSString *jsonString = [(NSDictionary *)jsonDictionary JSONRepresentation];
    DDLogInfo(@"The getArticleList request json string is: %@", jsonString);
    
    NSString *requestedUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@",
                              MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH, CONTENT_LIST_PATH];
    DDLogInfo(@"The requestedUrl request url string is: %@", requestedUrl);
    
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObject:jsonString forKey:@"json"];
    
    JSONParser *parser = [[JSONParser alloc] initWithString:requestedUrl 
                                                   delegate:delegate
                                             postDictionary:postDictionary
                                             connectionType:type];
    parser.useCacheFirst = useCacheFirst;
    [parser parse];
    
    [jsonDictionary release];
    [requestedUrl release];
    
    return [parser autorelease];
}

+ (Parser *)getArticleList:(NSString *)userId
                  tagArray:(NSArray *)tagArray
             startPosition:(NSUInteger)startPosition
                    length:(NSUInteger)length
                  delegate:(id<ParserDelegate>)delegate
             useCacheFirst:(BOOL)useCacheFirst
{
    return [self getArticleList:userId 
                       tagArray:tagArray 
                  startPosition:startPosition 
                         length:length 
                       delegate:delegate 
                  useCacheFirst:useCacheFirst
                 connectionType:ConnectionTypeAsynchronously];
}

+ (Parser *)getArticleListSync:(NSString *)userId
                      tagArray:(NSArray *)tagArray
                 startPosition:(NSUInteger)startPosition
                        length:(NSUInteger)length
                      delegate:(id<ParserDelegate>)delegate
                 useCacheFirst:(BOOL)useCacheFirst
{
    return [self getArticleList:userId 
                       tagArray:tagArray 
                  startPosition:startPosition 
                         length:length 
                       delegate:delegate 
                  useCacheFirst:useCacheFirst
                 connectionType:ConnectionTypeSynchronously]; 
}

+ (NSArray *)getTagGroups
{
    NSString *requestedUrl = [self getPath:@"taggroup_list.do"]; 
    DDLogInfo(@"The requestedUrl request url string is: %@", requestedUrl);
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestedUrl]];
    [request startSynchronous];
    
    if ([request error]) {
        return nil;
    }
    
    id jsonObject = [[request responseString] JSONValue];
    
    if (![jsonObject isKindOfClass:[NSArray class]]) 
    {
        return nil;
    }
    
    NSArray *array = [TagGroup TagGroupWithJSON:jsonObject];
    
    return array;
}

+ (Parser *)getSubscribedList:(NSArray *)tagArray
                startPosition:(NSUInteger)startPosition
                       length:(NSUInteger)length 
                     delegate:(id<ParserDelegate>)delegate
                useCacheFirst:(BOOL)useCacheFirst
               connectionType:(ConnectionType)type
                       userID:(NSString *)userId
{
    if (length == 0 || delegate == nil)
        return nil;
    
    //userId为空，取得官方iKnow的内容
    if ([userId length] == 0) {
        return [iKnowAPI getArticleListSync:IKNOW_OFFICIAL_ID
                                   tagArray:nil
                              startPosition:startPosition
                                     length:length
                                   delegate:delegate
                              useCacheFirst:useCacheFirst];
    }
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    
    if (userId) {
        [jsonDictionary setObject:userId forKey:@"user_id"];
    }
    
    [jsonDictionary setObject:[NSString stringWithFormat:@"%d", startPosition] forKey:@"offset"];
    [jsonDictionary setObject:[NSString stringWithFormat:@"%d", length] forKey:@"length"];
    
    NSString *jsonString = [(NSDictionary *)jsonDictionary JSONRepresentation];
    DDLogInfo(@"The getSubscribedList request json string is: %@", jsonString);
    
    NSString *requestedUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@",
                              MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH, CONTENT_LIST_PATH];
    DDLogInfo(@"The requestedUrl request url string is: %@", requestedUrl);
    
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObject:jsonString forKey:@"json"];
    
    JSONParser *parser = [[JSONParser alloc] initWithString:requestedUrl 
                                                   delegate:delegate
                                             postDictionary:postDictionary
                                             connectionType:type];
    parser.useCacheFirst = useCacheFirst;
    [parser parse];
    
    [jsonDictionary release];
    [requestedUrl release];
    
    return [parser autorelease];
}

+ (Parser *)getSubscribedList:(NSArray *)tagArray
               startPosition:(NSUInteger)startPosition
                      length:(NSUInteger)length 
                    delegate:(id<ParserDelegate>)delegate
               useCacheFirst:(BOOL)useCacheFirst
{
    NSString *userId = [iKnowAPI getUserId];
    
    return [self getSubscribedList:tagArray 
                     startPosition:startPosition 
                            length:length 
                          delegate:delegate 
                     useCacheFirst:useCacheFirst 
                    connectionType:ConnectionTypeAsynchronously
                            userID:userId];
}

+ (NSString *)getUserId
{
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");
    
    return [[iKnowXMPPClient getJID] user];
}

+ (NSDictionary *)getUserLocalInfoWithUserID:(NSString *)userID
{
    return [[self getUserModule] queryLocalUserInfoWithUserID:userID];
}

+ (NSString *)getUserLocalAvatar:(NSString *)userID
{
    NSDictionary *userInfo = [self getUserLocalInfoWithUserID:userID];
    return [userInfo objectForKey:@"photoUrl"];
}

+ (NSString *)getUserLocalName:(NSString *)userID
{
    return [[self getUserLocalInfoWithUserID:userID] objectForKey:@"nickName"];
}

+ (void)updateUserInfoFromServer:(NSString *)userID
{
    if ([userID length] == 0) {
        return;
    }
    
    NSDictionary *userInfo = [self getUserLocalInfoWithUserID:userID];
    if (userInfo) {
        return;
    }
    
    [[self getUserModule] queryUserInfoWithUserID:userID];
}

+ (NSDictionary *)getSelfInfo
{
    return [self getUserLocalInfoWithUserID:[self getUserId]];
}

+ (NSString *)getContentPath:(NSString *)articleId
{
    NSString *fullPath = [[NSString alloc] initWithFormat:@"%@%@%@%@%@?cid=%@",
                              MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH, CONTENT_PATH, articleId];
    
    return [fullPath autorelease];
}

+ (NSString *)getShareArticlePath:(NSString *)articleId
{
    NSString *fullPath = [[NSString alloc] initWithFormat:@"http://192.168.1.108/details.aspx?id=%@", articleId];
    
    return [fullPath autorelease];
}

+ (Downloader *)getContent:(NSString *)articleId 
                  delegate:(id<DownloaderDelegate>)delegate
             useCacheFirst:(BOOL)useCacheFirst
{
    if ([articleId length] == 0 || delegate == nil)
        return nil;
    
    NSString *requestedUrl = [iKnowAPI getContentPath:articleId];
    
    DDLogInfo(@"The getContent request url string is: %@", requestedUrl);
    
    Downloader *downloader = [[Downloader alloc] initWithString:requestedUrl
                                                       delegate:delegate
                                                 connectionType:ConnectionTypeAsynchronously 
                                                 downloaderType:DownloaderTypeData];
    downloader.useCacheFirst = useCacheFirst;
    [downloader download];
    
    return [downloader autorelease];
}

+ (Downloader *)getContentSync:(NSString *)articleId 
                      delegate:(id<DownloaderDelegate>)delegate
                 useCacheFirst:(BOOL)useCacheFirst
{
    if ([articleId length] == 0 || delegate == nil)
        return nil;
    
    NSString *requestedUrl = [iKnowAPI getContentPath:articleId];
    
    DDLogInfo(@"The getContent request url string is: %@", requestedUrl);
    
    Downloader *downloader = [[Downloader alloc] initWithString:requestedUrl
                                                       delegate:delegate
                                                 connectionType:ConnectionTypeSynchronously 
                                                 downloaderType:DownloaderTypeData];
    downloader.useCacheFirst = useCacheFirst;
    [downloader download];
    
    return [downloader autorelease];
}

+ (Parser *)getRelatedArticle:(Article *)article
                     delegate:(id<ParserDelegate>)delegate
{
    if (article == nil) {
        return nil;
    }
    
    if ([article.Tags count] < 2) {
        return nil;
    }
    
    NSString *tag = [article.Tags objectAtIndex:1];
    if ([tag length] == 0 || [article.CreateTime length] == 0) {
        return nil;
    }
    
    NSDateFormatter *format = [StringUtils getFullDateFormatter];
    NSDate *createDate = [format dateFromString:article.CreateTime];
    if (createDate == nil) {
        return nil;
    }
    
    NSDate *beginDay = [createDate addTimeInterval:-86400.0 * 7];//7天前
    //NSDate *tommorrowday = [createDate addTimeInterval:86400.0];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    
    [jsonDictionary setObject:[format stringFromDate:beginDay] forKey:@"create_time_start"];
    [jsonDictionary setObject:@"0" forKey:@"offset"];
    [jsonDictionary setObject:@"20" forKey:@"length"];
    
    //[jsonDictionary setObject:[format stringFromDate:tommorrowday] forKey:@"create_time_end"];
    [jsonDictionary setObject:[NSArray arrayWithObject:tag] forKey:@"tags"];
    
    NSString *jsonString = [(NSDictionary *)jsonDictionary JSONRepresentation];
    DDLogInfo(@"The getArticleList request json string is: %@", jsonString);
    
    NSString *requestedUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@",
                              MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH, CONTENT_LIST_PATH];
    DDLogInfo(@"The requestedUrl request url string is: %@", requestedUrl);
    
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObject:jsonString forKey:@"json"];
    
    JSONParser *parser = [[JSONParser alloc] initWithString:requestedUrl 
                                                   delegate:delegate
                                             postDictionary:postDictionary
                                             connectionType:ConnectionTypeSynchronously];
    [parser parse];
    
    [jsonDictionary release];
    [requestedUrl release];
    
    return [parser autorelease];
}

+ (BOOL)publishContentText:(NSString *)content 
                  title:(NSString *)title 
                summary:(NSString *)summary 
                   tags:(NSArray *)tagArray
               coverUrl:(NSString *)url
{
    if ([content length] == 0 || [title length] == 0 || [summary length] == 0
            || tagArray == nil)
        return NO;
    
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH_U, ADD_CONTENT_PATH];

    NSString *html = [HTMLBuilder CreateHTMLWithText:content];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:title forKey:@"title"];
    [jsonDictionary setObject:summary forKey:@"summary"];
    [jsonDictionary setObject:html forKey:@"content"];
    
    if ([url length]) {
        [jsonDictionary setObject:url forKey:@"coverUrl"];
    }
    
    [jsonDictionary setObject:@"text/html;charset=utf-8" forKey:@"contentType"];
    [jsonDictionary setObject:tagArray forKey:@"tags"];
    
    NSString *jsonString = [(NSDictionary *)jsonDictionary JSONRepresentation];
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl postParam:jsonString];
    
    [jsonDictionary release];
    [requestUrl release];
    
    return result;
}

+ (BOOL)publishContentImage:(NSString *)imageServerReturnedPath 
              imageWidth:(int)width
             imageHeight:(int)height
                   title:(NSString *)title 
                 summary:(NSString *)summary 
                    andText:(NSString *)text 
                    tags:(NSArray *)tagArray
                coverUrl:(NSString *)url
{
    if ([imageServerReturnedPath length] == 0)
        return NO;
    
    if ([title length] == 0 || tagArray == nil)
        return NO;
    
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH_U, ADD_CONTENT_PATH];
    
    NSString *html = [HTMLBuilder CreateHTMLWithText:text 
                                  imageServerPath:imageServerReturnedPath 
                                               width:width 
                                              height:height];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:title forKey:@"title"];
    
    if ([summary length]) {
        [jsonDictionary setObject:summary forKey:@"summary"];
    }
    
    [jsonDictionary setObject:html forKey:@"content"];
    if (url) {
        [jsonDictionary setObject:[NSString stringWithFormat:@"..%@", url] forKey:@"coverUrl"];
    }
    [jsonDictionary setObject:@"text/html;image/jpeg;charset=utf-8" forKey:@"contentType"];
    [jsonDictionary setObject:tagArray forKey:@"tags"];
    
    NSString *jsonString = [(NSDictionary *)jsonDictionary JSONRepresentation];
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl postParam:jsonString];
    
    [jsonDictionary release];
    [requestUrl release];
    
    return result;
}

+ (BOOL)addFriendListChangedDelegate:(id<DataChangedDelegate>)delegate
{
    return YES;
}

+ (BOOL)removeFriendListChangedDelegate:(id<DataChangedDelegate>)delegate
{
    return YES;
}

//告知iKnowAPI用户的好友列表已经发生变化
+ (void)didFriendListChanged
{
    return;
}


+ (Parser *)getTagList:(id<ParserDelegate>)delegate useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil)
        return nil;
    
    NSString *requestedUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@",
                              MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH, TAG_LIST_PATH];
    
    JSONParser *parser = [[JSONParser alloc] initWithString:requestedUrl 
                                                   delegate:delegate
                                             connectionType:ConnectionTypeAsynchronously];
    parser.useCacheFirst = useCacheFirst;
    [parser parse];
    
    [requestedUrl release];
    
    return [parser autorelease];
}

//获得用户订阅的标签数组
+ (NSArray *)getSubscribedTags
{
    NSDictionary *dic = [[self getUserModule] queryLocalUserInfo];
    NSString *tags = [dic objectForKey:@"subscribeFlag"];
    
    if ([tags length] == 0) 
    {
        [[self getUserModule] queryUserInfo];
	
        return nil;
    }
    
    if (dic == nil) {
        return nil;
    }
    
    tags = [dic objectForKey:@"subscribeFlag"];
    
    if ([tags length]) {
        return [tags componentsSeparatedByString:@","];
    }
    
    return nil;
}

+ (BOOL)subscribeTag:(NSString *)articleTag withUserID:(NSString *)userID
{
    return [[self getUserModule] subscribeTagSync:articleTag withUserID:userID];
}

+ (BOOL)unsubscribeTag:(NSString *)articleTag withUserID:(NSString *)userID
{
    return [[self getUserModule] unsubscribeTag:articleTag withUserID:userID];
}

+ (BOOL)addSubscribedTagsChangedDelegate:(id<DataChangedDelegate>)delegate
{
    return YES;
}

+ (BOOL)removeSubscribedTagsChangedDelegate:(id<DataChangedDelegate>)delegate
{
    return YES;
}

+ (void)didSubscribedTagsChanged
{
    return;
}

+ (Parser *)getCommentList:(NSString *)articleId 
                  delegate:(id<ParserDelegate>)delegate
             useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil)
        return nil;
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    
    [jsonDictionary setObject:articleId forKey:@"cid"];
    
    NSString *jsonString = [(NSDictionary *)jsonDictionary JSONRepresentation];
    
    NSString *requestedUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@",
                              MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH, COMMENT_LIST_PATH];
    
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObject:jsonString forKey:@"json"];
    
    JSONParser *parser = [[JSONParser alloc] initWithString:requestedUrl 
                                                   delegate:delegate
                                             postDictionary:postDictionary
                                             connectionType:ConnectionTypeAsynchronously];
    parser.useCacheFirst = useCacheFirst;
    [parser parse];
    
    [jsonDictionary release];
    [requestedUrl release];
    
    return [parser autorelease];
}


+ (BOOL)submitComment:(NSString *)articleId
              comment:(NSString *)comment
{
    //评价内容为空
    if ([comment length] == 0)
        return NO;

    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                        MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH, ADD_COMMENT_PATH];
    
    NSMutableString *commentString = [NSMutableString stringWithString:comment];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:articleId forKey:@"cid"];
    [jsonDictionary setObject:commentString forKey:@"value"];
    
    NSString *jsonString = [(NSDictionary *)jsonDictionary JSONRepresentation];
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl postParam:jsonString];
    
    [jsonDictionary release];
    [requestUrl release];
    
    return result;
}


+ (Parser *)getWordList:(NSString *)userId
               delegate:(id<ParserDelegate>)delegate
          useCacheFirst:(BOOL)useCacheFirst
         connectionType:(ConnectionType)connectionType
{
    if (delegate == nil)
        return nil;
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    
    if (userId) {
        [jsonDictionary setObject:userId forKey:@"user"];
    }
    
    NSString *jsonString = [(NSDictionary *)jsonDictionary JSONRepresentation];
    DDLogInfo(@"The getWordList request json string is: %@", jsonString);
    
    NSString *requestedUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@",
                              MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH, WORD_LIST_PATH];
    
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObject:jsonString forKey:@"json"];
    
    JSONParser *parser = [[JSONParser alloc] initWithString:requestedUrl 
                                                   delegate:delegate
                                             postDictionary:postDictionary
                                             connectionType:connectionType];
    parser.useCacheFirst = useCacheFirst;
    [parser parse];
    
    [jsonDictionary release];
    [requestedUrl release];
    
    return [parser autorelease];
}


+ (Parser *)queryWordOnline:(NSString *)word 
                   delegate:(id<ParserDelegate>)delegate
              useCacheFirst:(BOOL)useCacheFirst
{
    return [iKnowAPI queryWordOnline:word
                            delegate:delegate
                       useCacheFirst:useCacheFirst
                            useSpare:YES];
}

+ (Parser *)queryWordOnline:(NSString *)word 
                   delegate:(id<ParserDelegate>)delegate
              useCacheFirst:(BOOL)useCacheFirst
                   useSpare:(BOOL)useSpare
{
    //TODO: 处理非英语字符
    if ([word length] == 0)
        return nil;
    
    //查询的是句子
    if ([word rangeOfString:@" "].location != NSNotFound) {
        //return [iKnowAPI querySentenceOnline:word];
        return nil;
    }
    
    NSString *url = 
    useSpare ? 
    [NSString stringWithFormat:@"http://dict-co.iciba.com/api/dictionary.php?w=%@", word] :
    [NSString stringWithFormat:@"http://dict.cn/ws.php?utf8=true&q=%@", word];
    
    XMLParser *parser = [[XMLParser alloc] initWithString:url delegate:delegate connectionType:ConnectionTypeAsynchronously];
    [parser parse];
    
    return [parser autorelease];
}


+ (Parser *)querySentenceOnline:(NSString *)sentence 
                       delegate:(id<ParserDelegate>)delegate
                  useCacheFirst:(BOOL)useCacheFirst
{
    return nil;
}


+ (BOOL)addWord:(Word *)word
{
    if (word == nil || [word.Key length] == 0)
        return NO;
    
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH_U, EDIT_WORD_PATH];

    NSString *def = @"";
    
    if ( word.AcceptationList != nil && [word.AcceptationList count] > 0)
    {
        NSString *key = [[word.AcceptationList allKeys] objectAtIndex:0];
        def = [word.AcceptationList valueForKey:key];
    }
   
    NSDictionary *wordDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    word.Key, @"word",
                                    SAFE_STRING(word.Description), @"description", 
                                    SAFE_STRING(word.PhoneticSymbol), @"pron",
                                    def, @"def",
                                    SAFE_STRING(word.Pronunciation), @"audio_url", nil];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"1" forKey:@"action"];
    [jsonDictionary setObject:[NSArray arrayWithObject:wordDictionary] forKey:@"word"];
    
    NSString *jsonString = [jsonDictionary JSONRepresentation];
    DDLogInfo(@"The addWord request json string is: %@", jsonString);
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl postParam:jsonString];
    
    [requestUrl release];
    [jsonDictionary release];
    
    return result;
}

+ (BOOL)addWords:(NSArray *)dictionaryArray
{
    if ([dictionaryArray count] == 0)
        return NO;
    
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH_U, EDIT_WORD_PATH];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"1" forKey:@"action"];
    [jsonDictionary setObject:dictionaryArray forKey:@"word"];
    
    NSString *jsonString = [jsonDictionary JSONRepresentation];
    DDLogInfo(@"The addWords request json string is: %@", jsonString);
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl postParam:jsonString];
    
    [requestUrl release];
    [jsonDictionary release];
    
    return result;
}


+ (BOOL)deleteWord:(NSString *)word
{
    if ([word length] == 0)
        return NO;
    
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH_U, EDIT_WORD_PATH];
    
    NSDictionary *wordDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    word, @"word", nil];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"2" forKey:@"action"];
    [jsonDictionary setObject:[NSArray arrayWithObject:wordDictionary] forKey:@"word"];
    
    NSString *jsonString = [jsonDictionary JSONRepresentation];
    DDLogInfo(@"The deleteWord request json string is: %@", jsonString);
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl postParam:jsonString];
    
    [requestUrl release];
    [jsonDictionary release];
    
    return result;
}

+ (BOOL)deleteWords:(NSArray *)dictionaryArray
{
    if ([dictionaryArray count] == 0)
        return NO;
    
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH_U, EDIT_WORD_PATH];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"2" forKey:@"action"];
    [jsonDictionary setObject:dictionaryArray forKey:@"word"];
    
    NSString *jsonString = [jsonDictionary JSONRepresentation];
    DDLogInfo(@"The addWords request json string is: %@", jsonString);
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl postParam:jsonString];
    
    [requestUrl release];
    [jsonDictionary release];
    
    return result;
}


+ (Parser *)getFavoriteList:(NSString *)userId
                   delegate:(id<ParserDelegate>)delegate
              useCacheFirst:(BOOL)useCacheFirst
             connectionType:(ConnectionType)connectionType
{
    if (delegate == nil)
        return nil;
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    
    if (userId) {
        [jsonDictionary setObject:userId forKey:@"user"];
    }
    
    NSString *jsonString = [(NSDictionary *)jsonDictionary JSONRepresentation];
    DDLogInfo(@"The getWordList request json string is: %@", jsonString);
    
    NSString *requestedUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@",
                              MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH, FAVORITE_LIST_PATH];
    
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObject:jsonString forKey:@"json"];
    
    JSONParser *parser = [[JSONParser alloc] initWithString:requestedUrl 
                                                   delegate:delegate
                                             postDictionary:postDictionary
                                             connectionType:connectionType];
    parser.useCacheFirst = useCacheFirst;
    [parser parse];
    
    [jsonDictionary release];
    [requestedUrl release];
    
    return [parser autorelease];
}


+ (BOOL)addFavorite:(Article *)article
{
    if (article == nil || [article.Id length] == 0)
        return NO;
    
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH_U, EDIT_FAVORITE_PATH];
    
    NSDictionary *favoriteDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    article.Id, @"content", nil];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"1" forKey:@"action"];
    [jsonDictionary setObject:[NSArray arrayWithObject:favoriteDictionary] forKey:@"favorite"];
    
    NSString *jsonString = [jsonDictionary JSONRepresentation];
    DDLogInfo(@"The addFavorite request json string is: %@", jsonString);
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl postParam:jsonString];
    
    [requestUrl release];
    [jsonDictionary release];
    
    return result;
}

+ (BOOL)addFavorites:(NSArray *)dictionaryArray
{
    if ([dictionaryArray count] == 0)
        return NO;
    
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH_U, EDIT_FAVORITE_PATH];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"1" forKey:@"action"];
    [jsonDictionary setObject:dictionaryArray forKey:@"favorite"];
    
    NSString *jsonString = [jsonDictionary JSONRepresentation];
    DDLogInfo(@"The addFavorites request json string is: %@", jsonString);
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl postParam:jsonString];
    
    [requestUrl release];
    [jsonDictionary release];
    
    return result;
}

+ (BOOL)deleteFavorite:(NSString *)articleId
{
    if ([articleId length] == 0)
        return NO;
    
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH_U, EDIT_FAVORITE_PATH];
    
    NSDictionary *favoriteDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        articleId, @"content", nil];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"2" forKey:@"action"];
    [jsonDictionary setObject:[NSArray arrayWithObject:favoriteDictionary] forKey:@"favorite"];
    
    NSString *jsonString = [jsonDictionary JSONRepresentation];
    DDLogInfo(@"The deleteFavorite request json string is: %@", jsonString);
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl postParam:jsonString];
    
    [requestUrl release];
    [jsonDictionary release];
    
    return result;
}

+ (BOOL)deleteFavorites:(NSArray *)dictionaryArray
{
    if ([dictionaryArray count] == 0)
        return NO;
    
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH_U, EDIT_FAVORITE_PATH];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"2" forKey:@"action"];
    [jsonDictionary setObject:dictionaryArray forKey:@"favorite"];
    
    NSString *jsonString = [jsonDictionary JSONRepresentation];
    DDLogInfo(@"The addFavorites request json string is: %@", jsonString);
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl postParam:jsonString];
    
    [requestUrl release];
    [jsonDictionary release];
    
    return result;
}

+ (Parser *)getLastestVerson:(id<ParserDelegate>)delegate
{
    return nil;
}

+ (NSString *)getPath:(NSString *)path
{
    if ([path length] == 0) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%@%@%@%@%@", 
            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH, path];
}

+ (NSString *)getThumbImageServerPath:(NSString *)serverPath 
                            thumbWidh:(int)width
{
    if ([serverPath length] == 0 || width > 600) {
        return nil;
    }
    
    NSString *thumbPath = [self getPath:THUMB_IMAGE_PATH];
    return [NSString stringWithFormat:@"%@?width=%d&path=%@",
            thumbPath, width, serverPath];
}

+ (NSString *)getDownloadFilePath:(NSString *)path
{
    return [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, DOWNLOAD_RESOURCE_PATH, path];
}


+ (NSArray *)getSuggestionUserIDList
{
    NSString *url = [iKnowAPI getPath:@"recommend_account.json"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request startSynchronous];
    
    if ([request error]) {
        DDLogError(@"%@", [request error]);
        return nil;
    }
    
    NSString *response = [request responseString];
    
    id jsonObject = [response JSONValue];
    if (![jsonObject isKindOfClass:[NSArray class]]) 
    {
        return nil;
    }
    
    return (NSArray *)jsonObject;
}

#pragma mark update

//des =           //升级说明
//necessary = 4   //更新紧急程度
//ver=99.0.0.0.0  //更新包版本
//date=2011-10-16 18:17:51 //更新包发布时间
//url=*...     //更新包下载地址
/*
{
    necessary = -1; //不需要更新
}
*/ 

+ (NSDictionary *)checkUpdate
{
    NSString *updateUrl = [iKnowAPI getPath:@"check_update.do"];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:updateUrl]];
    [request startSynchronous];
    
    if ([request error]) {
        return nil;
    }
    
    NSString *response = [request responseString];
    
    id jsonObject = [response JSONValue];
    if (![jsonObject isKindOfClass:[NSDictionary class]]) 
    {
        return nil;
    }
    
    return (NSDictionary *)jsonObject;
}

#pragma mark admin

+ (BOOL)deleteArticleWithArticleID:(NSString *)articleID
{
    if ([articleID length] == 0) {
        return NO;
    }
    
    NSString *requestUrl = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                            MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, MAIN_PATH_A, DELETE_ARTICLE];
    
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"3" forKey:@"action"];
    [jsonDictionary setObject:articleID forKey:@"id"];
    
    NSString *jsonString = [jsonDictionary JSONRepresentation];
    DDLogInfo(@"The deleteArticle request json string is: %@", jsonString);
    
    BOOL result = [iKnowAPI postRequestSynchronously:requestUrl 
                                           postParam:jsonString];
    
    [jsonDictionary release];
    [requestUrl release];
    
    return result;
}

#pragma mark PrivateAPI

+ (XMPPiKnowUserModule *)getUserModule;
{
    return [[[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient] xmppiKnowUserModule];
}

@end

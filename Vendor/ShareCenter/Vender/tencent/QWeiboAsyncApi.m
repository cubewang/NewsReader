//
//  QWeiboAsyncApi.m
//  QWeiboSDK4iOSDemo
//
//  Created   on 11-1-18.
//   
//

#import "QWeiboAsyncApi.h"
#import "QOauthKey.h"
#import "QweiboRequest.h"


@implementation QWeiboAsyncApi

- (NSURLConnection *)getHomeMsgWithConsumerKey:(NSString *)aConsumerKey
                         consumerSecret:(NSString *)aConsumerSecret 
                         accessTokenKey:(NSString *)aAccessTokenKey 
                      accessTokenSecret:(NSString *)aAccessTokenSecret 
                             resultType:(ResultType)aResultType 
                              pageFlage:(PageFlag)aPageFlag 
                                nReqNum:(NSInteger)aReqNum 
                               delegate:(id)aDelegate {
    
    NSString *url = @"http://open.t.qq.com/api/statuses/home_timeline";
    
    QOauthKey *oauthKey = [[QOauthKey alloc] init];
    oauthKey.consumerKey = aConsumerKey;
    oauthKey.consumerSecret = aConsumerSecret;
    oauthKey.tokenKey = aAccessTokenKey;
    oauthKey.tokenSecret= aAccessTokenSecret;
    
    NSString *format = nil;
    if (aResultType == RESULTTYPE_XML) {
        format = @"xml";
    } else if (aResultType == RESULTTYPE_JSON) {
        format = @"json";
    } else {
        format = @"json";
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:format forKey:@"format"];
    [parameters setObject:[NSString stringWithFormat:@"%d", aPageFlag] forKey:@"pageflag"];
    [parameters setObject:[NSString stringWithFormat:@"%d", aReqNum] forKey:@"reqnum"];
    
    QWeiboRequest *request = [[QWeiboRequest alloc] init];
    NSURLConnection *connection = [request asyncRequestWithUrl:url httpMethod:@"GET" oauthKey:oauthKey parameters:parameters files:nil delegate:aDelegate];
    
    [request release];
    [oauthKey release];
    return connection;
}

- (NSURLConnection *)publishMsgWithConsumerKey:(NSString *)aConsumerKey 
                                consumerSecret:(NSString *)aConsumerSecret 
                                accessTokenKey:(NSString *)aAccessTokenKey 
                             accessTokenSecret:(NSString *)aAccessTokenSecret 
                                       content:(NSString *)aContent 
                                     imageFile:(NSString *)aImageFile 
                                    resultType:(ResultType)aResultType 
                                      delegate:(id)aDelegate {
    
    NSMutableDictionary *files = [NSMutableDictionary dictionary];
    NSString *url;
    
    if (aImageFile) {
        url = @"http://open.t.qq.com/api/t/add_pic";
        [files setObject:aImageFile forKey:@"pic"];
    } else {
        url = @"http://open.t.qq.com/api/t/add";
    }
    
    QOauthKey *oauthKey = [[QOauthKey alloc] init];
    oauthKey.consumerKey = aConsumerKey;
    oauthKey.consumerSecret = aConsumerSecret;
    oauthKey.tokenKey = aAccessTokenKey;
    oauthKey.tokenSecret= aAccessTokenSecret;
    
    NSString *format = nil;
    if (aResultType == RESULTTYPE_XML) {
        format = @"xml";
    } else if (aResultType == RESULTTYPE_JSON) {
        format = @"json";
    } else {
        format = @"json";
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:aContent forKey:@"content"];
    [parameters setObject:@"127.0.0.1" forKey:@"clientip"];
    
    QWeiboRequest *request = [[QWeiboRequest alloc] init];
    NSURLConnection *connection = [request asyncRequestWithUrl:url httpMethod:@"POST" oauthKey:oauthKey parameters:parameters files:files delegate:aDelegate];
    
    [request release];
    [oauthKey release];
    return connection;
}

//curer add
- (NSURLConnection *)publishMsgWithConsumerKey:(NSString *)aConsumerKey 
                                consumerSecret:(NSString *)aConsumerSecret 
                                accessTokenKey:(NSString *)aAccessTokenKey 
                             accessTokenSecret:(NSString *)aAccessTokenSecret 
                                       content:(NSString *)aContent 
                                      imageURL:(NSString *)aimageURL 
                                      delegate:(id)aDelegate
{
    if ([aContent length] == 0) {
        return nil;
    }
    
    NSString *url;
    
    QOauthKey *oauthKey = [[QOauthKey alloc] init];
    oauthKey.consumerKey = aConsumerKey;
    oauthKey.consumerSecret = aConsumerSecret;
    oauthKey.tokenKey = aAccessTokenKey;
    oauthKey.tokenSecret= aAccessTokenSecret;
    
    NSString *format = @"json";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:aContent forKey:@"content"];
    [parameters setObject:format forKey:@"format"];
    [parameters setObject:@"127.0.0.1" forKey:@"clientip"];
    
    if (aimageURL) {
        url = @"http://open.t.qq.com/api/t/add_pic_url";
        [parameters setObject:aimageURL forKey:@"pic_url"];
    } else {
        url = @"http://open.t.qq.com/api/t/add";
    }
    
    QWeiboRequest *request = [[QWeiboRequest alloc] init];
    NSURLConnection *connection = [request asyncRequestWithUrl:url httpMethod:@"POST" oauthKey:oauthKey parameters:parameters files:nil delegate:aDelegate];
    
    [request release];
    [oauthKey release];
    return connection;
}

@end

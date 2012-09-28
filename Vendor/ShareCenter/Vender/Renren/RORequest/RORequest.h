//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RORequestDelegate;
@protocol RORequestDebugDelegate;
@class RORequestParam;
@class ROResponse;
@class ROError;

@interface RORequest : NSObject {
    id<RORequestDelegate> _delegate;
    id<RORequestDebugDelegate> _debugDelegate;
    NSString *_url;
    NSString *_httpMethod; 
    NSMutableDictionary *_param;
    NSURLConnection *_connection;
    NSMutableData *_responseData;
    
    RORequestParam *_requestParamObject;
    ROResponse *_responseObject;
}


@property(nonatomic, assign) id<RORequestDelegate> delegate;

@property(nonatomic, assign) id<RORequestDebugDelegate> debugDelegate;

@property(nonatomic, copy) NSString *url;

@property(nonatomic, copy) NSString *httpMethod;

@property(nonatomic, retain) NSMutableDictionary *params;

@property(nonatomic, assign) NSURLConnection *connection;

@property(nonatomic, assign) NSMutableData *responseData;

@property(nonatomic, retain) RORequestParam *requestParamObject;

@property(nonatomic, retain) ROResponse *responseObject;

//新的接口。
+ (RORequest *)getRequestWithParam:(RORequestParam *)param httpMethod:(NSString *)httpMethod delegate:(id<RORequestDelegate>)delegate requestURL:(NSString *)url;
//旧的接口。
+ (RORequest *)getRequestWithParams:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod delegate:(id<RORequestDelegate>)delegate requestURL:(NSString *)url;
////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)getRequestSessionKeyWithParams:(NSString *)url;

+ (NSString*)serializeURL:(NSString *)baseUrl params:(NSDictionary *)params;


+ (NSString*)serializeURL:(NSString *)baseUrl params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) connect;

@end

////////////////////////////////////////////////////////////////////////////////
/*
 * RORequestDelegate protocol definition.
 */
@protocol RORequestDelegate <NSObject>

@optional

/**
 * 请求发送给服务器之前调用。
 */
- (void)requestLoading:(RORequest *)request;

/**
 * 服务器回应后准备再次发送数据时调用。
 */
- (void)request:(RORequest *)request didReceiveResponse:(NSURLResponse *)response;

/**
 * 错误使请求无法成功时调用。旧方法，为保持兼容存在。
 */
- (void)request:(RORequest *)request didFailWithError:(NSError *)error;

/**
 * 当收到回应回应并解析为对象后应用。
 *
 * 结果对应可以是dictionary，array，string，number，依赖于API返回的数据。
 */
- (void)request:(RORequest *)request didLoad:(id)result;

/**
 * 请求取消的时候调用。
 */
- (void)request:(RORequest *)request didLoadRawResponse:(NSData *)data;

/**
 * 服务器返回错误或NSConnection delegate方法返回错误时调用。
 */
- (void)request:(RORequest *)request didFailWithROError:(ROError *)error;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * RORequestDebugDelegate protocol definition.
 * 只能在调试时使用。
 */
@protocol RORequestDebugDelegate <NSObject>

- (void)requestToServer:(NSString *)requestParam forMethod:(NSString *)methodName;
- (void)responseFormServer:(NSString *)response forMethod:(NSString *)methodName;
- (void)otherErrors:(NSString *)errorDescription forMethod:(NSString *)methodName;

@end



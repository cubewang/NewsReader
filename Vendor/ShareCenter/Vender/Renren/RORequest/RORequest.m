//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import "RORequest.h"
#import "ROResponse.h"
#import "SBJSON.h"
#import "RORequestParam.h"
#import "ROError.h"
#import "ROUtility.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static NSString* kUserAgent = @"Renren iOS SDK v3.0";
static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3";
static const int kGeneralErrorCode = 10000;

static const NSTimeInterval kTimeoutInterval = 60.0;

///////////////////////////////////////////////////////////////////////////////////////////////////
@interface RORequest(Private)


- (BOOL)isKindOfUIImage;

- (NSMutableData *)generatePostBody;

- (id)parseJsonResponse:(NSData *)data error:(NSError **)error;

- (void)handleResponseData:(NSData *)data;

@end
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation RORequest

@synthesize delegate = _delegate;
@synthesize debugDelegate = _debugDelegate;
@synthesize url = _url;
@synthesize httpMethod = _httpMethod;
@synthesize params = _params;
@synthesize connection = _connection;
@synthesize responseData = _responseData;
@synthesize requestParamObject = _requestParamObject;
@synthesize responseObject = _responseObject;

/**
 * Free internal structure
 */
- (void)dealloc {
    [_connection cancel];
    [_connection release];
    [_responseData release];
    [_url release];
    [_httpMethod release];
    [_params release];
    [_requestParamObject release];
    [_responseObject release];
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// class public
// 新的接口。
+ (RORequest *)getRequestWithParam:(RORequestParam *)param httpMethod:(NSString *)httpMethod delegate:(id<RORequestDelegate>)delegate requestURL:(NSString *)url{
    RORequest* request = [[[RORequest alloc] init] autorelease];
    request.delegate = delegate;
    request.url = url;
    request.httpMethod = httpMethod;
    request.requestParamObject = param;
    request.params = [param requestParamToDictionary];
    request.connection = nil;
    request.responseData = nil;
    request.responseObject = nil;
    return request;
}

//旧的接口。
+ (RORequest *)getRequestWithParams:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod delegate:(id<RORequestDelegate>)delegate requestURL:(NSString *)url{
    RORequest* request = [[[RORequest alloc] init] autorelease];
    request.delegate = delegate;
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.requestParamObject = [[[RORequestParam alloc] init] autorelease];
    request.connection = nil;
    request.responseData = nil;
    request.responseObject = nil;
    return request;
}


#pragma mark - methods for one purpose -
///////////////////////////////////////////////////////////////////////////////////////////////////
//下面三个方法。
+ (NSString *)serializeURL:(NSString *)baseUrl params:(NSDictionary *)params{
    return [self serializeURL:baseUrl params:params httpMethod:@"GET"];
}

/**
 * Generate get URL
 */
+ (NSString*)serializeURL:(NSString *)baseUrl params:(NSDictionary *)params httpMethod:(NSString *)httpMethod{
    NSURL* parsedURL = [NSURL URLWithString:baseUrl];
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        if (([[params valueForKey:key] isKindOfClass:[UIImage class]])
            ||([[params valueForKey:key] isKindOfClass:[NSData class]])) {
            if ([httpMethod isEqualToString:@"GET"]) {
                NSLog(@"can not use GET to upload a file");
            }
            continue;
        }
        
        NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,/* allocator */ (CFStringRef)[params objectForKey:key], NULL, /* charactersToLeaveUnescaped */ (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        [escaped_value release];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}

+ (id)getRequestSessionKeyWithParams:(NSString *)url {  
	NSURL* sessionKeyURL = [NSURL URLWithString:url];
	NSData *data=[NSData dataWithContentsOfURL:sessionKeyURL];
	NSString* responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	SBJsonParser *jsonParser = [[SBJsonParser new] autorelease];
	id result = [jsonParser objectWithString:responseString];
	return result;
}
////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Formulate the NSError
 */
- (NSError *)formError:(NSInteger)code userInfo:(NSDictionary *)errorData{
    return [NSError errorWithDomain:@"renrenErrDomain" code:code userInfo:errorData];
}


/*
 * private helper function: call the delegate function when the request
 *                          fails with error
 */
- (void)failWithError:(NSError *)error {
    if([_delegate respondsToSelector:@selector(request:didFailWithROError:)]){
        if (nil == self.responseObject || nil == self.responseObject.error) {
            [_delegate request:self didFailWithROError:[ROError errorWithNSError:error]];
        }else{
            [_delegate request:self didFailWithROError:self.responseObject.error];
        }
        return;
    }else if([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [_delegate request:self didFailWithError:error];
    }
}



//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)connect{
    if ([_delegate respondsToSelector:@selector(requestLoading:)]) {
        [_delegate requestLoading:self];
    }
	
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeoutInterval];
   
	[urlRequest setHTTPMethod:self.httpMethod];
    UIDevice *device = [UIDevice currentDevice];
    NSString *ua = [NSString stringWithFormat:@"%@ (%@; %@ %@)",kUserAgent,device.model,device.systemName,device.systemVersion];
    [urlRequest setValue:ua forHTTPHeaderField:@"User-Agent"];
	if ([self isKindOfUIImage]) {
		NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];
		[urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
	}
	[urlRequest setHTTPBody:[self generatePostBody]];
    if (_debugDelegate && [_debugDelegate respondsToSelector:@selector(requestToServer:forMethod:)] && self.requestParamObject) {
        [_debugDelegate requestToServer:[_params description] forMethod:self.requestParamObject.method];
    }
	/*
     NSString* responseString = [[[NSString alloc] initWithData:[self generatePostBody]
     encoding:NSUTF8StringEncoding]
     autorelease];
     NSLog(@"======：%@",responseString);
     */
	//NSLog(@"Here's the request headers: %@", [urlRequest allHTTPHeaderFields]);
    //NSLog(@"Here's the request body: %@", [urlRequest HTTPBody]);
    _connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

-(BOOL)isKindOfUIImage{
    NSString *iskind=nil;	
    for (NSString *key in [_params keyEnumerator]) {
        if ([key isEqualToString:@"upload"]) {
            iskind=key;
            break;
        }
	}
	return iskind!=nil;	
}


#pragma mark - NSURLConnectionDelegate methods -
//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
	
    if([_delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [_delegate request:self didReceiveResponse:httpResponse];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self handleResponseData:_responseData];
    
    [_responseData release];
    _responseData = nil;
    [_connection release];
    _connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self failWithError:error];
    if(_debugDelegate && [_debugDelegate respondsToSelector:@selector(otherErrors:forMethod:)] && self.requestParamObject){
        [_debugDelegate otherErrors:[error localizedDescription] forMethod:self.requestParamObject.method];
    }
    
    [_responseData release];
    _responseData = nil;
    [_connection release];
    _connection = nil;
}

#pragma mark - Private Methods -
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// private methods
/*
 * private helper function: handle the response data
 */
- (void)handleResponseData:(NSData *)data{
    if([_delegate respondsToSelector:@selector(request:didLoadRawResponse:)]){
        [_delegate request:self didLoadRawResponse:data];
    }
    
    if([_delegate respondsToSelector:@selector(request:didLoad:)] || [_delegate respondsToSelector:@selector(request:didFailWithError:)]){
        NSError* error = nil;  
        id result = [self parseJsonResponse:data error:&error];
        if(_debugDelegate && [_debugDelegate respondsToSelector:@selector(responseFormServer:forMethod:)] && self.requestParamObject) {
            [_debugDelegate responseFormServer:[result description] forMethod:self.requestParamObject.method];
        }
        if(error){
            [self failWithError:error];
        }else if([_delegate respondsToSelector:@selector(request:didLoad:)]){
            [_delegate request:self didLoad:(result == nil ? data : result)];
        }
    }
}

/**
 * 解析返回的data, 只有handleResponseData函数调用.
 */
- (id)parseJsonResponse:(NSData *)data error:(NSError **)error{
    
    NSString* responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"Here's the response string: %@", responseString);
    SBJsonParser *jsonParser = [[SBJsonParser new] autorelease];
    if ([responseString isEqualToString:@"true"]) {
        return [NSDictionary dictionaryWithObject:@"true" forKey:@"result"];
    }else if([responseString isEqualToString:@"false"]) {
        if(error != nil){
            *error = [self formError:kGeneralErrorCode userInfo:[NSDictionary dictionaryWithObject:@"This operation cann't be completed!" forKey:@"error_msg"]];
        }
        return nil;
    }
    
    
    id result = [jsonParser objectWithString:responseString];
    
    self.responseObject = [self.requestParamObject requestResultToResponse:result];
    self.responseObject.param = self.requestParamObject;
    if (![result isKindOfClass:[NSArray class]]) {
        if([result objectForKey:@"error"] != nil){
            if (error != nil) {
                *error = [self formError:kGeneralErrorCode userInfo:result];
            }
            return nil;
        }
        
        if ([result objectForKey:@"error_code"] != nil) {
            if (error != nil) {
                *error = [self formError:[[result objectForKey:@"error_code"] intValue] userInfo:result];
            }
            return nil;
        }
        
        if ([result objectForKey:@"error_msg"] != nil) {
            if (error != nil) {
                *error = [self formError:kGeneralErrorCode userInfo:result];
            }
        }
        
        if ([result objectForKey:@"error_reason"] != nil) {
            if (error != nil) {
                *error = [self formError:kGeneralErrorCode userInfo:result];
            }
        }
    }
    
    return result;
}

- (NSMutableData *)generatePostBody {
	NSMutableData *body = [NSMutableData data];
	NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
	NSMutableArray *pairs = [NSMutableArray array];
    if ([self isKindOfUIImage]) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kStringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        for(NSString *key in [_params keyEnumerator]){
            if ([key isEqualToString:@"upload"]) {
                continue;
            }
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name = \"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[_params valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];
        }
        NSData *_dataParam=[_params valueForKey:@"upload"];
        NSData *imageData = UIImagePNGRepresentation((UIImage*)_dataParam);
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\";filename=no.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:@"Content-Type:image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];  
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kStringBoundary] dataUsingEncoding:NSUTF8StringEncoding]]; 
    }else {
        for (NSString* key  in [_params keyEnumerator]) {
            NSString* value = [_params objectForKey:key];
            NSString* value_str = [ROUtility encodeString:value urlEncode:NSUTF8StringEncoding];
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value_str]];
        }
        NSString* params = [pairs componentsJoinedByString:@"&"];
        [body appendData:[params dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return body;
}

@end

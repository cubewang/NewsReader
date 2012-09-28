//
//  ROError.m
//  SimpleDemo
//
//  Created by Winston on 11-8-15.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "ROError.h"

@implementation ROError

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (ROError*)errorWithOAuthResult:(NSDictionary*)result
{
    NSNumber* errorCode = [result objectForKey:@"error"];
    NSString* errorMessage = [result objectForKey:@"error_description"];
    NSString* errorURL = [result objectForKey:@"error_url"];
    NSMutableDictionary* errorInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (errorCode) {
        [errorInfo setObject:errorCode forKey:@"error_code"];
    }
    if (errorMessage) {
        [errorInfo setObject:errorMessage forKey:@"error_msg"];
    }
    if (errorURL) {
        [errorInfo setObject:errorURL forKey:@"error_url"];
    }
    ROError* error = [ROError errorWithDomain:kROErrorDomain code:[errorCode intValue] userInfo:errorInfo];
    [errorInfo release];
    return error;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (ROError*)errorWithRestInfo:(NSDictionary*)restInfo {
    //TO DO:确定restInfo的获取类型
    ROError* error = nil;
     NSDictionary* errorInfo = [restInfo objectForKey:@"error_response"];
    if (errorInfo) {
        NSNumber* errorCode = [errorInfo objectForKey:@"error_code"];
       error = [ROError errorWithDomain:kROErrorDomain code:[errorCode intValue] userInfo:errorInfo]; 
    }else {
        NSNumber* errorCode = [restInfo objectForKey:@"error_code"];
        error = [ROError errorWithDomain:kROErrorDomain code:[errorCode intValue] userInfo:restInfo];
    }
	return error;
}	

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (ROError*)errorWithNSError:(NSError*)error {
    
	ROError* myError = [ROError errorWithDomain:error.domain code:error.code userInfo:error.userInfo];
	return myError;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (ROError*)errorWithCode:(NSInteger)code errorMessage:(NSString*)errorMessage {
	NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
	[userInfo setObject:[NSString stringWithFormat:@"%d", code] forKey:@"error_code"];
    if (errorMessage) {
        [userInfo setObject:errorMessage forKey:@"error_msg"];
    }
	
	ROError* error = [ROError errorWithDomain:kROErrorDomain code:code userInfo:userInfo];
	[userInfo release];
	return error;
	
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
	if (self = [super initWithDomain:domain code:code userInfo:dict]) {
        
	}
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)localizedDescription
{
    if (![self.domain isEqualToString:kROErrorDomain]) {
        return [super localizedDescription];
    }
    if (![self.userInfo objectForKey:@"error_msg"]) {
        return @"未知错误";
    }
    return [self.userInfo objectForKey:@"error_msg"];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)methodForRestApi {
	NSDictionary* userInfo = self.userInfo;
	if (!userInfo) {
		return nil;
	}
	
	NSArray* requestArgs = [userInfo objectForKey:@"request_args"];
	if (!requestArgs) {
		return nil;
	}
	
	for (NSDictionary* pair in requestArgs) {
		if (NSOrderedSame == [@"method" compare:[pair objectForKey:@"key"]]) {
			return [pair objectForKey:@"value"];
		}
	}
	
	return nil;
}

@end

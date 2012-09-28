//
//  QAsyncHttp.m
//  QWeiboSDK4iOS
//
//  Created on 11-1-18.
//  
//

#import "QAsyncHttp.h"
#import "QMutableURLRequest.h"


@implementation QAsyncHttp

- (NSURLConnection *)httpGet:(NSString *)aUrl queryString:(NSString *)aQueryString delegate:(id)aDelegare {
	
	NSMutableURLRequest *request = [QMutableURLRequest requestGet:aUrl queryString:aQueryString];
	return [NSURLConnection connectionWithRequest:request delegate:aDelegare]; 
	
}

- (NSURLConnection *)httpPost:(NSString *)aUrl queryString:(NSString *)aQueryString delegate:(id)aDelegare {
	
	NSMutableURLRequest *request = [QMutableURLRequest requestPost:aUrl queryString:aQueryString];
	return [NSURLConnection connectionWithRequest:request delegate:aDelegare];
}

- (NSURLConnection *)httpPostWithFile:(NSDictionary *)files url:(NSString *)aUrl queryString:(NSString *)aQueryString delegate:(id)aDelegare {
	
	NSMutableURLRequest *request = [QMutableURLRequest requestPostWithFile:files url:aUrl queryString:aQueryString];
	return [NSURLConnection connectionWithRequest:request delegate:aDelegare];
}

@end

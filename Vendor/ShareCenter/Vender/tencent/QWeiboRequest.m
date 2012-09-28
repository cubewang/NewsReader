//
//  QWeiboRequest.m
//  QWeiboSDK4iOS
//
//  Created on 11-1-13.
//  
//

#import "QWeiboRequest.h"
#import "QOauth.h"
#import "QOauthKey.h"
#import "QSyncHttp.h"
#import "QAsyncHttp.h"


@implementation QWeiboRequest

#pragma mark -
#pragma mark instance methods


- (NSString *)syncRequestWithUrl:(NSString *)aUrl 
					  httpMethod:(NSString *)aHttpMethod 
						oauthKey:(QOauthKey *)aOauthKey 
					  parameters:(NSDictionary *)aParameters 
						   files:(NSDictionary *)aFiles {
	
	if (!aUrl || [aUrl isEqualToString:@""] || !aHttpMethod || [aHttpMethod isEqualToString:@""]) {
		return	nil;
	}
	
	QOauth *oauth = [[QOauth alloc] init];
	
	NSString *queryString = nil;
	NSString *oauthUrl = [oauth	getOauthUrl:aUrl 
								 httpMethod:aHttpMethod 
								consumerKey:aOauthKey.consumerKey 
							 consumerSecret:aOauthKey.consumerSecret 
								   tokenKey:aOauthKey.tokenKey 
								tokenSecret:aOauthKey.tokenSecret 
									 verify:aOauthKey.verify 
								callbackUrl:aOauthKey.callbackUrl 
								 parameters:aParameters 
								queryString:&queryString];
	
	QSyncHttp *http = [[QSyncHttp alloc] init];
	NSString *retString = nil;
	if ([aHttpMethod isEqualToString:@"GET"]) {
		retString = [http httpGet:oauthUrl queryString:queryString];
	} else if (!aFiles || [aFiles count] == 0) {
		retString = [http httpPost:oauthUrl queryString:queryString];
	} else {
		retString = [http httpPostWithFile:aFiles url:oauthUrl queryString:queryString];
	}
	
	[oauth release];
	[http release];
	return retString;
}

- (NSURLConnection *)asyncRequestWithUrl:(NSString *)aUrl 
							  httpMethod:(NSString *)aHttpMethod 
								oauthKey:(QOauthKey *)aOauthKey 
							  parameters:(NSDictionary *)aParameters 
								   files:(NSDictionary *)aFiles 
								delegate:(id)aDelegate {
	
	if (!aUrl || [aUrl isEqualToString:@""] || !aHttpMethod || [aHttpMethod isEqualToString:@""]) {
		return	nil;
	}
	
	QOauth *oauth = [[QOauth alloc] init];
	
	NSString *queryString = nil;
	NSString *oauthUrl = [oauth	getOauthUrl:aUrl 
								 httpMethod:aHttpMethod 
								consumerKey:aOauthKey.consumerKey 
							 consumerSecret:aOauthKey.consumerSecret 
								   tokenKey:aOauthKey.tokenKey 
								tokenSecret:aOauthKey.tokenSecret 
									 verify:aOauthKey.verify 
								callbackUrl:aOauthKey.callbackUrl 
								 parameters:aParameters 
								queryString:&queryString];
	
	QAsyncHttp *http = [[QAsyncHttp alloc] init];
	NSURLConnection *connection;
	if ([aHttpMethod isEqualToString:@"GET"]) {
		connection = [http httpGet:oauthUrl queryString:queryString delegate:aDelegate];
	} else if (!aFiles || [aFiles count] == 0) {
		connection = [http httpPost:oauthUrl queryString:queryString delegate:aDelegate];
	} else {
		connection = [http httpPostWithFile:aFiles url:oauthUrl queryString:queryString delegate:aDelegate];
	}
	
	[oauth release];
	[http release];
	
	return connection;
}

@end

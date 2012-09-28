//
//  QAsyncHttp.h
//  QWeiboSDK4iOS
//
//  Created on 11-1-18.
//  
//

#import <Foundation/Foundation.h>


@interface QAsyncHttp : NSObject {

}

//Start a connection fro http get method and return it to delegate.
- (NSURLConnection *)httpGet:(NSString *)aUrl queryString:(NSString *)aQueryString delegate:(id)aDelegare;

//Start a connection fro http post method and return it to delegate.
- (NSURLConnection *)httpPost:(NSString *)aUrl queryString:(NSString *)aQueryString delegate:(id)aDelegare;

//Start a connection fro http multi-part method and return it to delegate.
- (NSURLConnection *)httpPostWithFile:(NSDictionary *)files url:(NSString *)aUrl queryString:(NSString *)aQueryString delegate:(id)aDelegare;

@end

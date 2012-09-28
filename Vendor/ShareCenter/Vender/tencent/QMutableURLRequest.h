//
//  QSyncHttp.h
//  QWeiboSDK4iOS
//
//  Created on 11-1-13.
//  
//

#import <Foundation/Foundation.h>


@interface QMutableURLRequest : NSObject {

}

//Return a request for http get method
+ (NSMutableURLRequest *)requestGet:(NSString *)aUrl queryString:(NSString *)aQueryString;

//Return a request for http post method
+ (NSMutableURLRequest *)requestPost:(NSString *)aUrl queryString:(NSString *)aQueryString;

//Return a request for http post with multi-part method
+ (NSMutableURLRequest *)requestPostWithFile:(NSDictionary *)files url:(NSString *)aUrl queryString:(NSString *)aQueryString;

@end

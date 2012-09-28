//
//  QSyncHttp.h
//  QWeiboSDK4iOS
//
//  Created on 11-1-13.
//  
//

#import <Foundation/Foundation.h>


@interface QSyncHttp : NSObject {

}

//Do http get method and return the data received.
- (NSString *)httpGet:(NSString *)aUrl queryString:(NSString *)aQueryString;

//Do http post method and return the data received.
- (NSString *)httpPost:(NSString *)aUrl queryString:(NSString *)aQueryString;

//do http multi-part method and return the data received.
- (NSString *)httpPostWithFile:(NSDictionary *)files url:(NSString *)aUrl queryString:(NSString *)aQueryString;

@end

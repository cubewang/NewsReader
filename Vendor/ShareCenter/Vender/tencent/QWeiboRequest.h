//
//  QWeiboRequest.h
//  QWeiboSDK4iOS
//
//  Created on 11-1-13.
//  
//

#import <Foundation/Foundation.h>

@class QOauthKey;


@interface QWeiboRequest : NSObject {

}

/*
 * Do sync request.
 * 
 * param url
 *            The full url that needs to be signed including its non OAuth
 *            url parameters
 * param httpMethod
 *            The http method used. Must be a valid HTTP method verb
 *            (POST,GET,PUT, etc)
 * param key
 *            OAuth key
 * param listParam
 *            Query parameters
 * param listFile
 *            Files for post
 * return the data received.
 * 
 */
- (NSString *)syncRequestWithUrl:(NSString *)aUrl 
					  httpMethod:(NSString *)aHttpMethod 
						oauthKey:(QOauthKey *)aOauthKey 
					  parameters:(NSDictionary *)aParameters 
						   files:(NSDictionary *)aFiles;

/*
 * Do async request
 * 
 * param url
 *            The full url that needs to be signed including its non OAuth
 *            url parameters
 * param httpMethod
 *            The http method used. Must be a valid HTTP method verb
 *            (POST,GET,PUT, etc)
 * param key
 *            OAuth key
 * param listParam
 *            Query parameters
 * param listFile
 *            Files for post
 * param delegate
 *			  Callback delegate.
 * return the connection started.
 */
- (NSURLConnection *)asyncRequestWithUrl:(NSString *)aUrl 
							  httpMethod:(NSString *)aHttpMethod 
								oauthKey:(QOauthKey *)aOauthKey 
							  parameters:(NSDictionary *)aParameters 
								   files:(NSDictionary *)aFiles 
								delegate:(id)aDelegate;

@end

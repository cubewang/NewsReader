//
//  QOauthKey.h
//  QWeiboSDK4iOS
//
//  Created on 11-1-12.
//  
//

#import <Foundation/Foundation.h>


@interface QOauthKey : NSObject {
	
	NSString *consumerKey;
	NSString *consumerSecret;
	NSString *tokenKey;
	NSString *tokenSecret;
	NSString *verify;
	NSString *callbackUrl;

}

@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;
@property (nonatomic, copy) NSString *tokenKey;
@property (nonatomic, copy) NSString *tokenSecret;
@property (nonatomic, copy) NSString *verify;
@property (nonatomic, copy) NSString *callbackUrl;


@end

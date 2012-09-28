//
//  QWeiboSyncApi.h
//  QWeiboSDK4iOSDemo
//
//  Created on 11-1-13.
//   
//

#import <Foundation/Foundation.h>

typedef enum _ResultType {
	
	RESULTTYPE_XML, RESULTTYPE_JSON
	
}ResultType;

typedef enum _PageFlag {
	
	PAGEFLAG_FIRST, 
	PAGEFLAG_NEXT, 
	PAGEFLAG_LAST
	
}PageFlag;

@interface QWeiboSyncApi : NSObject {

}

//Get request token
- (NSString *)getRequestTokenWithConsumerKey:(NSString *)aConsumerKey 
							  consumerSecret:(NSString *)aConsumerSecret;

//Get access token
- (NSString *)getAccessTokenWithConsumerKey:(NSString *)aConsumerKey 
							 consumerSecret:(NSString *)aConsumerSecret 
							requestTokenKey:(NSString *)aRequestTokenKey
						 requestTokenSecret:(NSString *)aRequestTokenSecret 
									 verify:(NSString *)aVerify;

//Request timeline messages.
- (NSString *)getHomeMsgWithConsumerKey:(NSString *)aConsumerKey
						 consumerSecret:(NSString *)aConsumerSecret 
						 accessTokenKey:(NSString *)aAccessTokenKey 
					  accessTokenSecret:(NSString *)aAccessTokenSecret 
							 resultType:(ResultType)aResultType 
							  pageFlage:(PageFlag)aPageFlag 
								nReqNum:(NSInteger)aReqNum;

//Publish a message w/ or w/o image.
- (NSString *)publishMsgWithConsumerKey:(NSString *)aConsumerKey 
						 consumerSecret:(NSString *)aConsumerSecret 
						 accessTokenKey:(NSString *)aAccessTokenKey 
					  accessTokenSecret:(NSString *)aAccessTokenSecret 
								content:(NSString *)aContent 
							  imageFile:(NSString *)aImageFile 
							 resultType:(ResultType)aResultType;

//Publish a message w/ or w/o image.
- (NSString *)publishMsgWithConsumerKey:(NSString *)aConsumerKey 
						 consumerSecret:(NSString *)aConsumerSecret 
						 accessTokenKey:(NSString *)aAccessTokenKey 
					  accessTokenSecret:(NSString *)aAccessTokenSecret 
								content:(NSString *)aContent 
                               imageURL:(NSString *)aImageFile 
							 resultType:(ResultType)aResultType;

@end

//
//  QOauth.m
//  QWeiboSDK4iOS
//
//  Created on 11-1-12.
//  
//

#import <stdlib.h>
#import <CommonCrypto/CommonHMAC.h>
#import "QOauth.h"
#import "NSString+QEncoding.h"
#import "NSData+QBase64.h"
#import "NSURL+QAdditions.h"

#pragma mark -
#pragma mark Constants

#define OAuthVersion @"1.0"
#define OAuthParameterPrefix @"oauth_"
#define OAuthConsumerKeyKey @"oauth_consumer_key"
#define OAuthCallbackKey @"oauth_callback"
#define OAuthVersionKey @"oauth_version"
#define OAuthSignatureMethodKey @"oauth_signature_method"
#define OAuthSignatureKey @"oauth_signature"
#define OAuthTimestampKey @"oauth_timestamp"
#define OAuthNonceKey @"oauth_nonce"
#define OAuthTokenKey @"oauth_token"
#define oAauthVerifier @"oauth_verifier"
#define OAuthTokenSecretKey @"oauth_token_secret"
#define HMACSHA1SignatureType @"HMAC-SHA1"

#pragma mark -
#pragma mark Static methods

static NSInteger SortParameter(NSString *key1, NSString *key2, void *context) {
	NSComparisonResult r = [key1 compare:key2];
	if(r == NSOrderedSame) { // compare by value in this case
		NSDictionary *dict = (NSDictionary *)context;
		NSString *value1 = [dict objectForKey:key1];
		NSString *value2 = [dict objectForKey:key2];
		return [value1 compare:value2];
	}
	return r;
}

static NSData *HMAC_SHA1(NSString *data, NSString *key) {
	unsigned char buf[CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, [key UTF8String], [key length], [data UTF8String], [data length], buf);
	return [NSData dataWithBytes:buf length:CC_SHA1_DIGEST_LENGTH];
}

#pragma mark -
#pragma mark implementation QOauth

@implementation QOauth

#pragma mark -
#pragma mark Private methos

//Normalizes the request parameters according to the spec.
- (NSString *)normalizedRequestParameters:(NSDictionary *)aParameters {
	
	NSMutableArray *parametersArray = [NSMutableArray array];
	for (NSString *key in aParameters) {
		[parametersArray addObject:[NSString stringWithFormat:@"%@=%@", key, [aParameters valueForKey:key]]];
	}
	return [parametersArray componentsJoinedByString:@"&"];
}

//Generate the timestamp for the signature.
- (NSString *)generateTimeStamp {
	
	return [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
}

- (NSString *)generateNonce {
	// Just a simple implementation of a random number between 123400 and 9999999
	return [NSString stringWithFormat:@"%u", arc4random() % (9999999 - 123400) + 123400];
}

//Generate the signature base that is used to produce the signature
- (NSString *)generateSignatureBaseWithUrl:(NSURL *)aUrl 
								httpMethod:(NSString *)aHttpMethod 
								parameters:(NSDictionary *)aParameters 
							 normalizedUrl:(NSString **)aNormalizedUrl 
			   normalizedRequestParameters:(NSString **)aNormalizedRequestParameters {
	
	*aNormalizedUrl = nil;
	*aNormalizedRequestParameters = nil;
	
	if ([aUrl port]) {
		*aNormalizedUrl = [NSString stringWithFormat:@"%@:%@//%@%@", [aUrl scheme], [aUrl port], [aUrl host], [aUrl path]];
	} else {
		*aNormalizedUrl = [NSString stringWithFormat:@"%@://%@%@", [aUrl scheme], [aUrl host], [aUrl path]];
	}
	
	NSMutableArray *parametersArray = [NSMutableArray array];
	NSArray *sortedKeys = [[aParameters allKeys] sortedArrayUsingFunction:SortParameter context:aParameters];
	for (NSString *key in sortedKeys) {
		NSString *value = [aParameters valueForKey:key];
		[parametersArray addObject:[NSString stringWithFormat:@"%@=%@", key, [value URLEncodedString]]];
	}
	*aNormalizedRequestParameters = [parametersArray componentsJoinedByString:@"&"];
	
	NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@",
									 aHttpMethod, [*aNormalizedUrl URLEncodedString], [*aNormalizedRequestParameters URLEncodedString]];

	return signatureBaseString;
}

//Generates a signature using the HMAC-SHA1 algorithm
- (NSString *)generateSignatureWithUrl:(NSURL *)aUrl
						 customeSecret:(NSString *)aConsumerSecret 
						   tokenSecret:(NSString *)aTokenSecret 
							httpMethod:(NSString *)aHttpMethod 
							parameters:(NSDictionary *)aPatameters 
						 normalizedUrl:(NSString **)aNormalizedUrl 
		   normalizedRequestParameters:(NSString **)aNormalizedRequestParameters {
	
	NSString *signatureBase = [self generateSignatureBaseWithUrl:aUrl 
													  httpMethod:aHttpMethod 
													  parameters:aPatameters 
												   normalizedUrl:aNormalizedUrl 
									 normalizedRequestParameters: aNormalizedRequestParameters];
	
	NSString *signatureKey = [NSString stringWithFormat:@"%@&%@", [aConsumerSecret URLEncodedString], aTokenSecret ? [aTokenSecret URLEncodedString] : @""];
	NSData *signature = HMAC_SHA1(signatureBase, signatureKey);
	NSString *base64Signature = [signature base64EncodedString];
	return base64Signature;
}

#pragma mark -
#pragma mark QOauth instance methods


- (NSString *)getOauthUrl:(NSString *)aUrl 
			   httpMethod:(NSString *)aHttpMethod 
				consumerKey:(NSString *)aConsumerKey 
			 consumerSecret:(NSString *)aConsumerSecret 
				 tokenKey:(NSString *)aTokenKey 
			  tokenSecret:(NSString *)aTokenSecret 
				   verify:(NSString *)aVerify 
			  callbackUrl:(NSString *)aCallbackUrl 
			   parameters:(NSDictionary *)aParameters 
			  queryString:(NSString **)aQueryString {
	
	NSString *parameterString = [self normalizedRequestParameters:aParameters];
	NSMutableString *urlWithParameter = [[[NSMutableString alloc] initWithString:aUrl] autorelease];
	if (parameterString && ![parameterString isEqualToString:@""]) {
		[urlWithParameter appendFormat:@"?%@", parameterString];
	}
	
	NSString *encodedUrl = [urlWithParameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL smartURLForString:encodedUrl];
	NSString *nonce = [self generateNonce];
	NSString *timeStamp = [self generateTimeStamp];
	
	NSMutableDictionary *allParameters;
	if (aParameters) {
		allParameters = [[aParameters mutableCopy] autorelease];
	} else {
		allParameters = [NSMutableDictionary dictionary];
	}

	[allParameters setObject:nonce forKey:OAuthNonceKey];
	[allParameters setObject:timeStamp forKey:OAuthTimestampKey];
	[allParameters setObject:OAuthVersion forKey:OAuthVersionKey];
	[allParameters setObject:HMACSHA1SignatureType forKey:OAuthSignatureMethodKey];
	[allParameters setObject:aConsumerKey forKey:OAuthConsumerKeyKey];
	if (aTokenKey) {
		[allParameters setObject:aTokenKey forKey:OAuthTokenKey];
	}
	if (aVerify) {
		[allParameters setObject:aVerify forKey:oAauthVerifier];
	}
	if (aCallbackUrl) {
		[allParameters setObject:aCallbackUrl forKey:OAuthCallbackKey];
	}
	
	NSString *normalizedURL = nil;
	NSMutableString *queryString = nil;
	NSString *signature = [self generateSignatureWithUrl:url 
										   customeSecret:aConsumerSecret 
											 tokenSecret:aTokenSecret 
											  httpMethod:aHttpMethod 
											  parameters:allParameters 
										   normalizedUrl:&normalizedURL 
							 normalizedRequestParameters:&queryString];
	[queryString appendFormat:@"&oauth_signature=%@", [signature URLEncodedString]];
	*aQueryString = [[[NSString alloc] initWithString:queryString] autorelease];
	
	return normalizedURL;
}

@end

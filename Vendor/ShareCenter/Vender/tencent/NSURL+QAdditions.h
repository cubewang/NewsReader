//
//  NSURL+QAdditions.h
//  QWeiboSDK4iOS
//
//  Created on 11-1-13.
//  
//

#import <Foundation/Foundation.h>


@interface NSURL (QAdditions)

+ (NSDictionary *)parseURLQueryString:(NSString *)queryString;

+ (NSURL *)smartURLForString:(NSString *)str;

@end

//
//  NSString+Encoding.h
//  QWeiboSDK4iOS
//
//  Created on 11-1-12.
//  
//

#import <Foundation/Foundation.h>


@interface NSString (QOAEncoding)

- (NSString *)URLEncodedString;

- (NSString *)URLDecodedString;

@end

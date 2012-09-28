//
//  StringUtils.h
//  iKnow
//
//  Created by curer on 11-8-3.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EMAIL_MIN_LENGTH 4
#define EMAIL_MAX_LENGTH 255
#define PASSWORD_MIN_LENGTH 1
#define PASSWORD_MAX_LENGTH 20
#define NAME_MAX_LENGTH 20


@interface StringUtils : NSObject {

}

+(void) xmlCharTransfor:(NSMutableString **)xmlString;

+(void) translateForFavoriteAndWords:(NSMutableString **)string;

+(NSString *)intervalSinceTime:(NSDate *)theBeforeDate 
                       andTime:(NSDate *)theLaterDate;

+(NSString *)translateForSystemHeadImage:(NSString *)string;

+(NSString *)textFromNow:(NSString *)time;
+ (NSTimeInterval)intervalFromNow:(NSString *)time;

+(NSString *)md5:(NSString *)str;

+(NSString *)iKnowTime:(NSDate *)date;

+ (BOOL) isEmailAddress:(NSString*)email;

+ (NSString *)trimString:(NSString *)string toCharCount:(int)charCount;
+ (int)charCountOfString:(NSString *)string;

+ (NSDateFormatter *)getDateFormatter;
+ (NSDateFormatter *)getFullDateFormatter;

+ (long long)getFileSize:(NSString *)folderPath;

@end

@interface NSString (StringUtil)
- (NSString*)encodeAsURIComponent;
- (NSString*)escapeHTML;
- (NSString*)unescapeHTML;
+ (NSString*)localizedString:(NSString*)key;
+ (NSString*)base64encode:(NSString*)str;
@end

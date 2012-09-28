//
//  StringUtils.m
//  iKnow
//
//  Created by curer on 11-8-3.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "StringUtils.h"
#import <sys/stat.h>

@implementation StringUtils



+ (void) xmlCharTransfor:(NSMutableString **)xmlString {
    if (xmlString == nil)
        return;
    
    NSMutableString *str = *xmlString;
    
    [str replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch 
                              range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch 
                              range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch 
                              range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch 
                              range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch 
                              range:NSMakeRange(0, [str length])];
}

+ (void) translateForFavoriteAndWords:(NSMutableString **)string {
    if (string == nil) {
        return;
    }
    
    NSMutableString *str = *string;
    
    [str replaceOccurrencesOfString:@";" withString:@"^^" options:NSLiteralSearch 
                              range:NSMakeRange(0, [str length])];
}

static NSDateFormatter *s_format = nil;

+ (NSDateFormatter *)getDateFormatter
{
    if (s_format == nil) {
        s_format = [[NSDateFormatter alloc] init];
        [s_format setDateFormat:@"yyyy-MM-dd"];
    }
    
    return s_format;
}

static NSDateFormatter *s_fullFormat = nil;

+ (NSDateFormatter *)getFullDateFormatter
{
    if (s_fullFormat == nil) {
        s_fullFormat = [[NSDateFormatter alloc] init];
        [s_fullFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    return s_fullFormat;
}

+(NSString *)intervalSinceTime:(NSDate *)theBeforeDate andTime:(NSDate *)theLaterDate {
    
    if (theBeforeDate == nil || theLaterDate == nil) {
        return @"";
    }

    NSTimeInterval beforeDate = [theBeforeDate timeIntervalSince1970];
    
    NSTimeInterval laterDate = [theLaterDate timeIntervalSince1970];
    
    NSTimeInterval subDate = laterDate - beforeDate;
    
    NSString *res = nil;
    
    if (subDate / 3600 <= 1) {
        res = [NSString stringWithFormat:@"%f", subDate / 60];
        res = [res substringToIndex:res.length - 7];
        if (subDate < 60) {
            res = [NSString stringWithFormat:NSLocalizedString(@"刚刚", @""), res];
        }
        else{
            res = [NSString stringWithFormat:NSLocalizedString(@"%@分钟前", @""), res];
        }
    }
    else if (subDate / 3600 > 1 && subDate / 86400 <= 1) {
        res = [NSString stringWithFormat:@"%f", subDate / 3600];
        res = [res substringToIndex:res.length - 7];
        res = [NSString stringWithFormat:NSLocalizedString(@"%@小时前", @""), res]; 
    }
    else if (subDate / 86400 > 1 && subDate / 86400 <= 3) {
        res = [NSString stringWithFormat:@"%f", subDate / 86400];
        res = [res substringToIndex:res.length - 7];
        res = [NSString stringWithFormat:NSLocalizedString(@"%@天前", @""), res]; 
    }
    else {
        res = [[StringUtils getDateFormatter] stringFromDate:theBeforeDate];
    }

    return [res length] ? res : @" ";
}

+(NSString *)translateForSystemHeadImage:(NSString *)string {
    
    if ([string length] == 0){
        return @"Avatar1.png";
    }     
    else {
        NSString *str = @"loc://";
        NSRange range = [string rangeOfString:str];
        NSString *text = [NSString stringWithFormat:@"%@", string];
        
        if (range.location != NSNotFound) {
            range.location += [str length];
            range.length = [text length] - range.location;
            text = [text substringWithRange:range];
        }
        return text;
    }
}

+ (NSTimeInterval)intervalFromNow:(NSString *)time
{
    if ([time length] == 0) {
        return 0;
    }
    
    NSString *timeStr = [NSString stringWithString:time];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [format dateFromString:timeStr];
    [format release];
    
    NSDate *now = [NSDate date];
    
    NSTimeInterval beforeDate = [date timeIntervalSince1970];
    
    NSTimeInterval laterDate = [now timeIntervalSince1970];
    
    NSTimeInterval subDate = laterDate - beforeDate;
    
    if (subDate < 0 ) {
        //时间比现在还要早，这里，我们认为是和现在一样
        return 0;//means now
    }
    
    return subDate;
}

+ (NSString *)textFromNow:(NSString *)time {
    if ([time length] == 0) {
        return @"";
    }
    
    NSTimeInterval subDate = [self intervalFromNow:time];
    NSDate *now = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [format dateFromString:time];
    [format release];
    
    if (subDate == 0) {
        //now
        NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
        
        [format2 setDateFormat:@"HH:mm"];
        NSString *res = [format2 stringFromDate:now];
        [format2 release];
        
        return res;
    }
    
    if (subDate / 86400 <= 1) {
        //N小时以内，包括几分钟"
        NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
        
        [format2 setDateFormat:@"HH:mm"];
        NSString *res = [format2 stringFromDate:date];
        [format2 release];
        
        return res;
    }
    else if (subDate / 86400 > 1  && subDate / 86400 <= 365) {
        //N day
        NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
        
        [format2 setDateFormat:@"MM-dd HH:mm"];
        NSString *res = [format2 stringFromDate:date];
        [format2 release];
        
        return res;
    }
    
    return time;
}

+(NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
   ]; 
}

+(NSString *)iKnowTime:(NSDate *)date
{
    NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [format stringFromDate:date];
}

+ (BOOL) isEmailAddress:(NSString *)email 
{
    if ([email length] == 0) 
    {
        return NO;
    }
    
    NSString *emailRegex = @"^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$"; 
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:email]; 
} 

+ (int)charCountOfString:(NSString *)string 
{
    int count = 0;
    for (int i = 0; i < [string length]; i++)
    {
        unichar c = [string characterAtIndex:i];
        if (isblank(c) || isascii(c))
        {
            count++;
        }
        else
        {
            count += 2;
        }
    }
    return count;
}

+ (NSString *)trimString:(NSString *)string toCharCount:(int)charCount 
{
    int curCharCount = [self charCountOfString:string];
    
    NSString *trimedStr = [NSString stringWithString:string];
    
    if (curCharCount > charCount)
    {
        int delta = curCharCount - charCount;
        for (int i = [string length] - 1; i >= 0; i--)
        {
            unichar c = [string characterAtIndex:i];
            if (isblank(c) || isascii(c))
            {
                delta--;
            }
            else
            {
                delta -= 2;
            }
            if (delta <= 0)
            {
                trimedStr = [string substringToIndex:i];
                break;
            }
        }
        
        trimedStr = [NSString stringWithFormat:@"%@...", trimedStr];
    }
    
    return trimedStr;
}

+ (long long) fileSizeAtPath:(NSString *)filePath
{
    struct stat st;
    if (lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0)
        return st.st_size;
    
    return 0;
}

+ (long long)getFileSize:(NSString *)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [StringUtils fileSizeAtPath:fileAbsolutePath];
    }
    
    return folderSize;
}

@end

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; 

@implementation NSString (StringUtil)
- (NSString*)encodeAsURIComponent
{
	const char* p = [self UTF8String];
	NSMutableString* result = [NSMutableString string];
	
	for (;*p ;p++) {
		unsigned char c = *p;
		if (('0' <= c && c <= '9') || ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') || c == '-' || c == '_') {
			[result appendFormat:@"%c", c];
		} else {
			[result appendFormat:@"%%%02X", c];
		}
	}
	return result;
}

+ (NSString*)base64encode:(NSString*)str 
{
    if ([str length] == 0)
        return @"";
    
    const char *source = [str UTF8String];
    int strlength  = strlen(source);
    
    char *characters = malloc(((strlength + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    
    NSUInteger length = 0;
    NSUInteger i = 0;
    
    while (i < strlength) {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < strlength)
            buffer[bufferLength++] = source[i++];
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

- (NSString*)escapeHTML
{
	NSMutableString* s = [NSMutableString string];
	
	int start = 0;
	int len = [self length];
	NSCharacterSet* chs = [NSCharacterSet characterSetWithCharactersInString:@"<>&\""];
	
	while (start < len) {
		NSRange r = [self rangeOfCharacterFromSet:chs options:0 range:NSMakeRange(start, len-start)];
		if (r.location == NSNotFound) {
			[s appendString:[self substringFromIndex:start]];
			break;
		}
		
		if (start < r.location) {
			[s appendString:[self substringWithRange:NSMakeRange(start, r.location-start)]];
		}
		
		switch ([self characterAtIndex:r.location]) {
			case '<':
				[s appendString:@"&lt;"];
				break;
			case '>':
				[s appendString:@"&gt;"];
				break;
			case '"':
				[s appendString:@"&quot;"];
				break;
			case '&':
				[s appendString:@"&amp;"];
				break;
		}
		
		start = r.location + 1;
	}
	
	return s;
}

- (NSString*)unescapeHTML
{
	NSMutableString* s = [NSMutableString string];
	NSMutableString* target = [[self mutableCopy] autorelease];
	NSCharacterSet* chs = [NSCharacterSet characterSetWithCharactersInString:@"&"];
	
	while ([target length] > 0) {
		NSRange r = [target rangeOfCharacterFromSet:chs];
		if (r.location == NSNotFound) {
			[s appendString:target];
			break;
		}
		
		if (r.location > 0) {
			[s appendString:[target substringToIndex:r.location]];
			[target deleteCharactersInRange:NSMakeRange(0, r.location)];
		}
		
		if ([target hasPrefix:@"&lt;"]) {
			[s appendString:@"<"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&gt;"]) {
			[s appendString:@">"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&quot;"]) {
			[s appendString:@"\""];
			[target deleteCharactersInRange:NSMakeRange(0, 6)];
		} else if ([target hasPrefix:@"&amp;"]) {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 1)];
		}
	}
	
	return s;
}

+ (NSString*)localizedString:(NSString*)key
{
	return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
}

@end

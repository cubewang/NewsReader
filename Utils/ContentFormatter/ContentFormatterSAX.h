//
//  ContentFormatterSAX.h
//  iKnow
//
//  Created by Mike on 11-5-4.
//  SAX 方式解析过滤页面
//

#import <Foundation/Foundation.h>
#import "IContentFormatter.h"
#import "ContentInfo.h"
#import "RegexKitLite.h"
#import "Client.h"

@interface ContentFormatterSAX : NSObject<IContentFormatter, NSXMLParserDelegate>  
{
    ContentInfo* contentInfo;
    NSString* articleTitle;
    NSMutableString* dataText;
    NSXMLParser *xmlParser;
    NSMutableString *currentText;
    NSString *currentPath;
    NSDictionary *currentAttributes;
    
    NSString* style_defultFontSize; //默认字体大小
}

@property (nonatomic, retain) NSDictionary *currentAttributes;
@property (nonatomic, retain) NSString *currentPath;
@property (nonatomic, retain) NSMutableString* dataText;
@property (nonatomic, retain) NSXMLParser *xmlParser;
@property (nonatomic, retain) NSMutableString *currentText;

@property (nonatomic, copy) NSString* articleTitle;

//解析页面
- (ContentInfo*) formatContent:(NSString*)contentUrl contentData:(NSData*)data articleTitle:(NSString*)title;
- (void) reset;
- (void) addCurrentTextToData:(NSString*)elementName crtName:(NSString*)currentName ;
- (NSString*) filterCurrentName:(NSString*)elementName;

- (void) setStyle:(NSString*)currentName attr:(NSDictionary *)attributes;
- (void) setSource:(NSString*)currentName attr:(NSDictionary *)attributes;

@end

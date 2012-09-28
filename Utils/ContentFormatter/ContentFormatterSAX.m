//
//  ContentFormatterSAX.m
//  iKnow
//
//  Created by Mike on 11-5-4.
//  SAX 方式解析过滤页面
//

#import "ContentFormatterSAX.h"
#import "StringUtil.h"


@implementation ContentFormatterSAX

@synthesize contentInfo;
@synthesize dataText;
@synthesize xmlParser;
@synthesize currentText;
@synthesize currentPath;
@synthesize currentAttributes;
@synthesize articleTitle;

- (void)dealloc {
    [xmlParser release];
    [contentInfo release];
    [dataText release];
    [currentText release];
    [currentPath release];
    [currentAttributes release];

    [style_defultFontSize release];
    
    self.articleTitle = nil;

    [super dealloc];
}

//解析页面
- (ContentInfo*) formatContent:(NSString*)contentUrl contentData:(NSData*)data articleTitle:(NSString*)title
{
    [self reset];
    
    //处理已经从服务器删除掉的文章内容的解析
    NSString *articleString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    if ([articleString isEqualToString:@"\"错误的内容ID\""])
        return nil;
    
    self.articleTitle = title;

    if (data) 
    {
        xmlParser = [[NSXMLParser alloc] initWithData:data];
        xmlParser.delegate = self;
        [xmlParser setShouldProcessNamespaces:YES];
        [xmlParser parse];
        [xmlParser release];
        xmlParser = nil;
    }

    contentInfo.formattedString = dataText;

    return contentInfo;
}

//解析页面
- (ContentInfo*) formatContent:(NSString*)contentUrl contentString:(NSString*)string articleTitle:(NSString*)title
{
    [self reset];
    
    self.articleTitle = title;
    
    if ([string length] > 0) 
    {
        xmlParser = [[NSXMLParser alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        xmlParser.delegate = self;
        [xmlParser setShouldProcessNamespaces:YES];
        [xmlParser parse];
        [xmlParser release];
        xmlParser = nil;
    }
    
    contentInfo.formattedString = dataText;
    
    return contentInfo;
}

/*
 * 重置
 */
-(void) reset 
{
    RELEASE_SAFELY(style_defultFontSize);

    if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ) 
    {
        style_defultFontSize = @"18px";
    }
    else 
    {
        style_defultFontSize = @"20px";
    }

    self.xmlParser.delegate = nil;
    self.xmlParser = nil;
    self.dataText = [[NSMutableString alloc] init];
    self.currentText = [[NSMutableString alloc] init];
    self.currentPath = @"/";
    self.currentAttributes = nil;
    
    self.articleTitle = nil;
}


/*
 * 增加文字到内容
 */
- (void) addCurrentTextToData:(NSString*)elementName crtName:(NSString*) currentName
{
    if (currentText != nil && [currentText length] > 0) 
    {
        if (currentName != nil)
        {
            [dataText appendString:[currentText escapeHTML]];
        } 
                        
        [currentText release];
        currentText = [[NSMutableString alloc] init];
    }
}

//节点名称替换
- (NSString*) filterCurrentName:(NSString*)elementName
{
//    if([elementName isEqualToString:@"audio"])
//    {
//        return nil;
//    }
//    else 
//    {
        return elementName;
//    }
}

/*
 * 设置样式
 */
- (void) setStyle:(NSString*)elementName attr:(NSDictionary *)attributes
{    
    if ([[elementName lowercaseString] isEqualToString:@"body"]) 
    {    
        [dataText appendString:@" style=\""];
        [dataText appendString:[@"font-size:" stringByAppendingString:style_defultFontSize]];
        [dataText appendString:@"\">"];
        
        //添加文章标题
        [dataText appendString:@"<p style=\"text-align:center\"><b>"];
        [dataText appendString:self.articleTitle ? self.articleTitle : @""];
        [dataText appendString:@"</b></p><hr/"];
    }
    else if ([[elementName lowercaseString] isEqualToString:@"img"])
    {
        [dataText appendString:@"width=\"100%\""];
    }
}


- (void) setAttributes:(NSString*)elementName attr:(NSDictionary *)attributes
{
    NSArray *keyArray = [attributes allKeys];
    
    if ([keyArray count] > 0)
    {
        for (NSString* key in keyArray) {
            if ([key length] == 0 || [[key lowercaseString] isEqualToString:@"width"] || [[key lowercaseString] isEqualToString:@"height"])
                continue;
            
            NSString *value = [attributes valueForKey:key];
            
            [dataText appendFormat:@" %@=\"", key];
            [dataText appendString:value];
            [dataText appendString:@"\" "];
        }
    }
    
    [self setStyle:elementName attr:attributes]; //设置样式
}


/*
 * 节点开始
 */
- (void)parser:(NSXMLParser *)parser 
  didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
  attributes:(NSDictionary *)attributeDict 
{
    // Adjust path
    self.currentPath = [currentPath stringByAppendingPathComponent:qName];
    self.currentAttributes = attributeDict;

    NSString* currentName = [self filterCurrentName:elementName];
    [self addCurrentTextToData:elementName crtName:currentName];
    
    if(currentName == nil)
    {
        return;
    }
    
    //让audio播放器居中
    if ([[elementName lowercaseString] isEqualToString:@"audio"]) {
        [dataText appendString:@"<div style=\"margin:0px auto; text-align:center; width:100%\">"];
    }
    
    if ([[elementName lowercaseString] isEqualToString:@"img"]) {
        
        NSString *source = [attributeDict valueForKey:@"src"];
        NSString *imageURL = [self getFullPath:source];

        [dataText appendString:[NSString stringWithFormat:@"<a href=\"iKnow://photo:%@\">", imageURL]];
        
        [self.contentInfo.imageURLList addObject:imageURL];
    }
    
    [dataText appendString:@"<"];
    [dataText appendString:currentName];
    [self setAttributes:elementName attr:attributeDict]; //设置元素的属性
    [dataText appendString:@">"];
    
    //修改正文字体
//    if ([[elementName lowercaseString] isEqualToString:@"html"]) {
//        [dataText appendString:@"<head><style type=\"text/css\">body {font-family:Georgia;} </style></head>"];
//    }
}

/*
 * 找到文字
 */
- (void)parser:(NSXMLParser *)parser 
foundCharacters:(NSString *)string;
{
    NSString* elementName = [currentPath lastPathComponent];
    NSString* currentName = [self filterCurrentName:elementName];
    if(currentName == nil && ![[elementName lowercaseString] isEqualToString:@"audio"]) return;

    [currentText appendString:string];
}

- (NSString*)getFullPath:(NSString*)shortPath
{
    //如果是相对路径改为绝对路径
    if ([shortPath hasPrefix:@"../"]) {
        NSRange range = {0};
        range.location = 2;
        range.length = [shortPath length] - range.location;
        
        NSString *fullPath = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                              MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, DOWNLOAD_RESOURCE_PATH, [shortPath substringWithRange:range]];
        
        return [fullPath autorelease];
    }
    else {
        return shortPath;
    }
}

/*
 * 节点截止
 */
- (void)parser:(NSXMLParser *)parser 
  didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
{    
    //音频封装
    if ([[elementName lowercaseString] isEqualToString:@"audio"]) 
    {
        NSString* path = [NSString stringWithString:currentPath];
        
        NSString* downUrl = [[NSString alloc] initWithString:[currentAttributes valueForKey:@"src"]];
        NSString *audioFullPath = [self getFullPath:downUrl];
        
        NSString* lrc = [NSString stringWithString:currentText];
        
        NSDictionary* audioDictionary = [NSDictionary dictionaryWithObjectsAndKeys:path, @"path", audioFullPath, @"downUrl",lrc, @"lrc", nil];
        [contentInfo.audioList addObject:audioDictionary];
        
        [downUrl release];
    }
    
    NSString* currentName = [self filterCurrentName:elementName];
    [self addCurrentTextToData:elementName crtName:currentName];
    
    if(currentName == nil) return;
    
    [dataText appendString:@"</"];
    [dataText appendString:currentName];
    [dataText appendString:@">"];
    
    //让audio播放器居中
    if ([[elementName lowercaseString] isEqualToString:@"audio"]) {
        [dataText appendString:@"</div>"];
    }
    
    if ([[elementName lowercaseString] isEqualToString:@"img"]) {
        [dataText appendString:@"</a>"];
    }
    
    // Adjust path
    self.currentPath = [currentPath stringByDeletingLastPathComponent];
}

@end

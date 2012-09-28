//
//  IKContnetDataFactory.m
//  iKnow
//
//  Created by Mike on 11-5-4.
//  内容数据工厂(单例)
//

#import "ContentFormatterFactory.h"


@implementation ContentFormatterFactory

//工厂单例
static ContentFormatterFactory* factory = nil; 

//获得实例
+ (ContentFormatterFactory*)example {
    @synchronized(self) 
    {
        if (factory == nil) 
        {
            // assignment not done here
            [[self alloc] init]; 
        }
    } 
    return factory;
} 

+ (id)allocWithZone:(NSZone*)zone {
    @synchronized(self) 
    {
        if (factory == nil) 
        {            
            // assignment and return on first allocation
            factory = [super allocWithZone:zone];
            return factory;
        }
    } 
    //on subsequent allocation attempts return nil
    return nil; 
} 

- (id)copyWithZone:(NSZone*)zone
{
    return self;
} 

- (id)retain
{
    return self;
} 

- (unsigned)retainCount
{
    //denotes an object that cannot be released
    return UINT_MAX;  
} 

- (void)release
{
    //do nothing
} 

- (id)autorelease
{
    return self;
}

/*
 *格式化内容
 */
- (ContentInfo*) formatContent:(NSString*) contentUrl articleTitle:(NSString*) title
{
    NSData* data = nil; //TODO 下载页面数据
    return [self formatContent:contentUrl contentData:data articleTitle:title];
}

/*
 *根据内容数据格式化内容
 */
- (ContentInfo*) formatContent:(NSString*) contentUrl contentData:(NSData*) data articleTitle:(NSString*)title
{
    NSObject<IContentFormatter>* contentFormatter = [self newContentFormatter:contentUrl];
    if(contentFormatter != nil)
    {
        ContentInfo* contentInfo = [[ContentInfo alloc] init];
        contentFormatter.contentInfo = contentInfo;
        [contentFormatter formatContent:contentUrl contentData:data articleTitle:title];
        [contentFormatter release];
        
        return [contentInfo autorelease];
    }
    else return nil;
}

/*
 *根据内容字符串格式化内容
 */
- (ContentInfo*) formatContent:(NSString*) contentUrl contentString:(NSString*) string articleTitle:(NSString*)title
{
    NSObject<IContentFormatter>* contentFormatter = [self newContentFormatter:contentUrl];
    if(contentFormatter != nil)
    {
        ContentInfo* contentInfo = [[ContentInfo alloc] init];
        contentFormatter.contentInfo = contentInfo;
        [contentFormatter formatContent:contentUrl contentString:string articleTitle:title];
        [contentFormatter release];
        
        return [contentInfo autorelease];
    }
    else return nil;
}

/*
 *获得页面解析器
 */
- (NSObject<IContentFormatter>*) newContentFormatter:(NSString*) contentUrl
{
    return [[ContentFormatterSAX alloc] init];
}

@end

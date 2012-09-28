//
//  IKContnetDataFactory.h
//  iKnow
//
//  Created by Mike on 11-5-4.
//  内容数据工厂(单例)
//

#import <Foundation/Foundation.h>
#import "ContentInfo.h"
#import "IContentFormatter.h"
#import "ContentFormatterSAX.h"

@interface ContentFormatterFactory : NSObject {

}

/*
 *获得工厂实例
 */
+ (ContentFormatterFactory*)example;
    
/*
 *根据url格式化内容
 */
- (ContentInfo*) formatContent:(NSString*) contentUrl;

/*
 *根据内容数据格式化内容
 */
- (ContentInfo*) formatContent:(NSString*) contentUrl contentData:(NSData*) data articleTitle:(NSString*)title;

/*
 *根据内容字符串格式化内容
 */
- (ContentInfo*) formatContent:(NSString*) contentUrl contentString:(NSString*) string articleTitle:(NSString*)title;

/*
 *获得页面解析器
 */
- (NSObject<IContentFormatter>*) newContentFormatter:(NSString*) contentUrl;

@end

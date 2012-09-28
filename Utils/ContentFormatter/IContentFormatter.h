//
//  IContentFormatter.h
//  iKnow
//
//  Created by Mike on 11-5-4.
//  内容数据解析接口
//

#import <Foundation/Foundation.h>
#import "ContentInfo.h"

@protocol IContentFormatter 

//数据对象
@property (nonatomic, retain) ContentInfo* contentInfo;

//解析页面
@required
- (void) formatContent:(NSString*)contentUrl contentData:(NSData*)data articleTitle:(NSString*)title;


@end

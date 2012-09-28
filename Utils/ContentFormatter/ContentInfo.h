//
//  ContentInfo.h
//  iKnow
//
//  Created by Mike on 11-5-4.
//  页面内容数据对象
//

#import <Foundation/Foundation.h>


@interface ContentInfo : NSObject {
    
    NSString* formattedString;// 内容字符串
    
    NSMutableArray* audioList; // 音频    
    NSMutableArray *imageURLList; //文章中的图片地址数组，用于离线下载
}

// 内容数据
@property (nonatomic, copy) NSString* formattedString;

// 音频
@property (nonatomic, retain) NSMutableArray* audioList;

@property (nonatomic, retain) NSMutableArray *imageURLList;

@end

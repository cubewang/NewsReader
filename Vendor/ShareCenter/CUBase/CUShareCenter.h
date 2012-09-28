//
//  CUShareCenter.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-13.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CUShareClient.h"

@interface CUShareCenter : NSObject
{
    CUShareClientType type;
    id<CUShareClientData> shareClient;
}

+ (CUShareCenter *)sharedInstanceWithType:(CUShareClientType)type;

+ (void)destory:(CUShareCenter *)instance;

- (void)sendWithText:(NSString *)text;
- (void)sendWithText:(NSString *)text andImage:(UIImage *)image;
- (void)sendWithText:(NSString *)text andImageURLString:(NSString *)imageURLString;

- (BOOL)isBind;
- (void)unBind;
- (void)Bind:(UIViewController *)vc;

@property (nonatomic, assign) CUShareClientType type;

//it really should be retain!
@property (nonatomic, retain) id<CUShareClientData> shareClient;

@end

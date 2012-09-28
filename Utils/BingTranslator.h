//
//  BingTransltor.h
//  EnglishFun
//
//  Created by cg on 12-7-10.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BingTranslator : NSObject {
}

- (NSString *)getAccessToken;
- (NSString *)getTranslatorData:(NSString *)string;
- (NSString *) getTranslatorContent:(NSString *)content articleId:(NSString *) articleId;
 
@end
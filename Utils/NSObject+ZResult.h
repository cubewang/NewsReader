//
//  NSObject+iKnowResult.h
//  iKnow
//
//  Created by curer on 11-9-22.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZResult)

- (BOOL)ZResultSuccess;
- (NSString *)ZErrorDescription;
- (NSString *)ZErrorCode;

- (NSString *) encryptBase64;
- (NSString *) decryptBase64;

@end

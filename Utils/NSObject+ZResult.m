//
//  NSObject+iKnowResult.m
//  iKnow
//
//  Created by curer on 11-9-22.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "SBJson.h"
#import "NSObject+ZResult.h"
#import "GTMBase64.h"


@implementation NSString (ZResult)

- (BOOL)ZResultSuccess
{
    id jsonObject = [self JSONValue];
    if ([jsonObject isKindOfClass:[NSDictionary class]]) 
    {
        NSDictionary *dic = (NSDictionary *)jsonObject;
        return [dic objectForKey:@"error"] == nil;
        
    }
    return NO;
}
- (NSString *)ZErrorDescription
{
    if ([self ZResultSuccess]) 
    {
        return nil;
    }
    
    id jsonObject = [self JSONValue];
    NSDictionary *dic = (NSDictionary *)jsonObject;
    return [dic objectForKey:@"error"];
}
- (NSString *)ZErrorCode
{
    if ([self ZResultSuccess]) 
    {
        return nil; 
    }
    
    id jsonObject = [self JSONValue];
    NSDictionary *dic = (NSDictionary *)jsonObject;
    return [dic objectForKey:@"msg"];
}


- (NSString *) encryptBase64
{
    if (self == nil || [self isEqualToString:@""]) {
        return @"";
    }
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString *accountStr = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    return [accountStr autorelease];
}


- (NSString *) decryptBase64
{
    if (self == nil || [self isEqualToString:@""]) {
        return @"";
    }
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 decodeData:data];
    NSString *accountStr = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    return [accountStr autorelease];
}

@end

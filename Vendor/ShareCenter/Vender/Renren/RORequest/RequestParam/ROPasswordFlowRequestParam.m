//
//  ROPasswordFlowRequestParam.m
//  Renren Open-platform
//
//  Created by xiawenhai on 11-8-17.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import "ROPasswordFlowRequestParam.h"
#import "ROError.h"
#import "Renren.h"

@implementation ROPasswordFlowRequestParam
@synthesize userName = _userName;
@synthesize passWord = _passWord;
@synthesize grantType = _grantType;
@synthesize secretKey = _secretKey;
@synthesize scope = _scope;

-(id)init
{
	if (self = [super init]) {
		self.grantType = [NSString stringWithFormat:@"password"];
	}
	
	return self;
}

-(NSMutableDictionary*)requestParamToDictionary
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.userName,@"username",
																						self.passWord,@"password",
																						self.grantType,@"grant_type",
																						self.apiKey,@"client_id",
																						self.secretKey,@"client_secret",nil];
	if (self.scope != nil && ![self.scope isEqualToString:@""]) {
		[dictionary setObject:self.scope forKey:@"scope"];
	}
	
	return dictionary;
}

-(ROResponse*)requestResultToResponse:(id)result
{
	id responseObject = nil;
	if (![result isKindOfClass:[NSArray class]]) {
		if ([result objectForKey:@"error"] != nil) {
			responseObject = [ROError errorWithOAuthResult:result];
			return [ROResponse responseWithError:responseObject];
		} else {
			
			return [ROResponse responseWithRootObject:result];
		}
	}
		
	return [ROResponse responseWithRootObject:responseObject];
}

-(void)dealloc
{
	self.userName = nil;
	self.passWord = nil;
	self.grantType = nil;
	self.secretKey = nil;
	self.scope = nil;
	[super dealloc];
}

@end

//  ROUserInfoRequestParam.m
//  Renren Open-platform
//
//  Created by xiawenhai on 11-8-12.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import "ROUserInfoRequestParam.h"
#import "ROUserResponseItem.h"
#import "ROError.h"


@implementation ROUserInfoRequestParam
@synthesize userIDs = _userIDs;
@synthesize fields = _fields;

-(id)init
{
	if (self = [super init]) {
		self.method = [NSString stringWithFormat:@"users.getInfo"];
	}
	
	return self;
}

-(void)addParamToDictionary:(NSMutableDictionary*)dictionary
{
	if (dictionary == nil) {
		return;
	}
	
	if (self.fields != nil && ![self.fields isEqualToString:@""]) {
		[dictionary setObject:self.fields forKey:@"fields"];
	}
	
	if (self.userIDs != nil && ![self.userIDs isEqualToString:@""]) {
		[dictionary setObject:self.userIDs forKey:@"uids"];
	}
}

-(ROResponse*)requestResultToResponse:(id)result
{
	id responseObject = nil;
	if ([result isKindOfClass:[NSArray class]]) {
		responseObject = [[[NSMutableArray alloc] init] autorelease];
		
		for (NSDictionary *item in result) {
			ROUserResponseItem *responseItem = [[[ROUserResponseItem alloc] initWithDictionary:item] autorelease];
			[(NSMutableArray*)responseObject addObject:responseItem];
		}
		
		return [ROResponse responseWithRootObject:responseObject];
	} else {
		if ([result objectForKey:@"error_code"] != nil) {
			responseObject = [ROError errorWithRestInfo:result];
			return [ROResponse responseWithError:responseObject];
		}
		
		return [ROResponse responseWithRootObject:responseObject];
	}
}

-(void)dealloc
{
	self.userIDs = nil;
	self.fields = nil;
	[super dealloc];
}
	
@end

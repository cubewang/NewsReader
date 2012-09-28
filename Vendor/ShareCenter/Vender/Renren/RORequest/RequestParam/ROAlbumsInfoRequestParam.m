//  ROAlbumsInfoRequestParam.m
//  Renren Open-platform
//
//  Created by xiawenhai on 11-8-12.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import "ROAlbumsInfoRequestParam.h"
#import "ROAlbumResponseltem.h"
#import "ROError.h"


@implementation ROAlbumsInfoRequestParam
@synthesize page = _page;
@synthesize count = _count;
@synthesize albumIDs = _albumIDs;
@synthesize userID = _userID;

-(id)init
{
	if (self = [super init]) {
		self.method = [NSString stringWithFormat:@"photos.getAlbums"];
		self.page = [NSString stringWithFormat:@"1"];
		self.count = [NSString stringWithFormat:@"10"];
	}
	
	return self;
}

-(void)addParamToDictionary:(NSMutableDictionary*)dictionary
{
	if (dictionary == nil) {
		return;
	}
	
	if ([self.page intValue] > 0) {
		[dictionary setObject:self.page forKey:@"page"];
	}
	
	if ([self.count intValue] > 0) {
		[dictionary setObject:self.count forKey:@"count"];
	}
	
	if (self.albumIDs != nil && ![self.albumIDs isEqualToString:@""]) {
		[dictionary setObject:self.albumIDs forKey:@"aids"];
	}
	
	[dictionary setObject:self.userID forKey:@"uid"];
}

-(ROResponse*)requestResultToResponse:(id)result
{
	id responseObject = nil;
	if ([result isKindOfClass:[NSArray class]]) {
		responseObject = [[[NSMutableArray alloc] init] autorelease];
		
		for (NSDictionary *item in result) {
			ROAlbumResponseltem *responseItem = [[[ROAlbumResponseltem alloc] initWithDictionary:item] autorelease];
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
	self.page = nil;
	self.count = nil;
	self.albumIDs = nil;
	self.userID = nil;
	[super dealloc];
}

@end

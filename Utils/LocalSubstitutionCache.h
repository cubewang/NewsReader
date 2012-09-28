//
//  LocalSubstitutionCache.h
//  iKnow
//
//  Created by Cube on 12-13-20.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalSubstitutionCache : NSURLCache
{
	NSMutableDictionary *cachedResponses;
}

+ (NSString *)pathForURL:(NSURL*)url;

@end

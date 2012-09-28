//
//  ROResponseItem.m
//  SimpleDemo
//
//  Created by Winston on 11-8-12.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import "ROResponseItem.h"

@implementation ROResponseItem

@synthesize result = _result;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(ROResponseItem*)itemWithDictionary:(NSDictionary*)responseDictionary
{
    return [[[self alloc] initWithDictionary:responseDictionary] autorelease];
}

-(id)initWithDictionary:(NSDictionary*)responseDictionary
{
    self = [self init];
    if (self) {
        _responseDictionary = [responseDictionary retain];
        _result = [self valueForItemKey:@"result"];
    }
    return self;
}

-(NSDictionary*)responseDictionary
{
    return _responseDictionary;
}

-(id)valueForItemKey:(NSString*)key
{
    if (!key) {
        return nil;
    }
    id value = [[self responseDictionary] objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    return value;
    
}

-(void)dealloc
{
    [_responseDictionary release];
    [super dealloc];
}

@end

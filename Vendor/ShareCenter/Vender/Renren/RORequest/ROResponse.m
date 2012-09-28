//
//  ROResponse.m
//  SimpleDemo
//
//  Created by Winston on 11-8-16.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "ROResponse.h"

@implementation ROResponse

@synthesize rootObject = _rootObject;
@synthesize error = _error;
@synthesize param = _param;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)dealloc
{
    [_rootObject release];
    [_error release];
    [_param release];
    [super dealloc];
}

+(ROResponse *)responseWithRootObject:(id)rootObject
{
    ROResponse *response = [[self alloc] init];
    response.rootObject = rootObject;
    return [response autorelease];
    
}

+(ROResponse *)responseWithError:(ROError *)error
{
    ROResponse *response = [[self alloc] init];
    response.error = error;
    return [response autorelease];
}

@end

//
//  Session.m
//  iKnow
//
//  Created by Cube on 11-7-15.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "Session.h"


@implementation Session

@synthesize Name, Description, DataTime;

#pragma mark NSObject

- (NSString *)description {
    NSMutableString *string = [[NSMutableString alloc] initWithString:@"Session: "];
    if (Name)   [string appendFormat:@"Name:%@", Name];
    if (Description)   [string appendFormat:@"Description:%@", Description];
    
    return [string autorelease];
}

- (void)dealloc {
    
    [Name release];
    [Description release];
    [DataTime release];
    
    [super dealloc];
}

@end

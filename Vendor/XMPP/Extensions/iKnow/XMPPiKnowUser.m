//
//  XMPPiKnowUser.m
//  iKnow
//
//  Created by curer on 11-9-27.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPiKnowUser.h"


@implementation XMPPiKnowUser

//@synthesize userName;
@synthesize password;

@synthesize displayName;
@synthesize email;

-(void)dealloc
{
    //[userName release];
    [password release];
    [displayName release];
    [email release];
    
    [super dealloc];
}

@end

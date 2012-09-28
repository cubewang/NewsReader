//
//  ContentInfo.m
//  iKnow
//
//  Created by Mike on 11-5-4.
//  页面内容数据对象
//

#import "ContentInfo.h"


@implementation ContentInfo

@synthesize formattedString;
@synthesize audioList;
@synthesize imageURLList;

- (id) init
{
    audioList = [[NSMutableArray alloc] init];
    imageURLList = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc 
{
    [imageURLList release];
    [formattedString release];
    [audioList release];
    [super dealloc];
}

@end

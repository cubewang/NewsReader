//
//  ROAlbumResponseltem.m
//  SimpleDemo
//
//  Created by Winston on 11-8-16.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "ROAlbumResponseltem.h"

@implementation ROAlbumResponseltem

@synthesize albumId = _albumId;
@synthesize coverUrl = _coverUrl;
@synthesize userId = _userId;
@synthesize name = _name;
@synthesize createTime = _createTime;
@synthesize updateTime = _updateTime;
@synthesize description = _description;
@synthesize location = _location;
@synthesize size = _size;
@synthesize visibleType = _visibleType;
@synthesize commentCount = _commentCount;
@synthesize type = _type;

-(id)initWithDictionary:(NSDictionary*)responseDictionary
{
    self = [super initWithDictionary:responseDictionary];
    if (self) {
        _albumId = [self valueForItemKey:@"aid"];
        _coverUrl = [self valueForItemKey:@"url"];
        _userId = [self valueForItemKey:@"uid"];
        _name = [self valueForItemKey:@"name"];
        _createTime = [self valueForItemKey:@"create_time"];
        _updateTime = [self valueForItemKey:@"update_time"];
        _description = [self valueForItemKey:@"description"];
        _location = [self valueForItemKey:@"location"];
        _size = [[self valueForItemKey:@"size"] intValue];
        _visibleType = [[self valueForItemKey:@"visible"] intValue];
        _commentCount = [[self valueForItemKey:@"comment_count"] intValue];
        _type = [[self valueForItemKey:@"type"] intValue];
    }
    return self;
}

@end

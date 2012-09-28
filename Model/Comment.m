//
//  Comment.m
//  iKnow
//
//  Created by Cube on 11-4-24.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "Comment.h"


@implementation Comment

@synthesize MemberName = _MemberName;
@synthesize UserId     = _UserId;
@synthesize Content    = _Content;
@synthesize PublishedDate     = _PublishedDate;
@synthesize IsOfficialComment = _IsOfficialComment;
@synthesize avatarImagePath = _avatarImagePath;


- (void)updateWithJsonDictionary:(NSDictionary*)dictionary {
    
    [self reset];
    
    _MemberName = [[dictionary objectForKey:@"user_name"] retain];
    _UserId = [[dictionary objectForKey:@"user_id"] retain];
    _Content = [[dictionary objectForKey:@"text"] retain];
    _PublishedDate = [[dictionary objectForKey:@"time"] retain];

    if ([_MemberName isEqualToString:IKNOW_OFFICIAL_ID]) {
        _IsOfficialComment = YES;
    }
}

- (id)initWithJsonDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        [self updateWithJsonDictionary:dictionary];
    }
    
    return self;
}

- (void)reset {
    RELEASE_SAFELY(_MemberName);
    RELEASE_SAFELY(_UserId);
    RELEASE_SAFELY(_Content);
    RELEASE_SAFELY(_PublishedDate);
    RELEASE_SAFELY(_avatarImagePath);
}


- (void)dealloc {
    [self reset];
    [super dealloc];
}


@end

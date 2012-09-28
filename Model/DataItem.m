//
//  Article.m
//  iKnow
//
//  Created by Cube on 11-4-23.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "DataItem.h"


@implementation DataItem

@synthesize ItemId     = _ItemId;
@synthesize ItemType   = _ItemType;
@synthesize CreateTime = _CreateTime;
@synthesize LastUpdateTime = _LastUpdateTime;
@synthesize Data1 = _Data1;
@synthesize Data2 = _Data2;
@synthesize Data3 = _Data3;
@synthesize Data4 = _Data4;
@synthesize Data5 = _Data5;


- (id)initWithJsonDictionary:(NSDictionary*)dictionary {
}


- (void)dealloc {
    RELEASE_SAFELY(_ItemId);
    RELEASE_SAFELY(_ItemType);
    RELEASE_SAFELY(_CreateTime);
    RELEASE_SAFELY(_LastUpdateTime);
    RELEASE_SAFELY(_Data1);
    RELEASE_SAFELY(_Data2);
    RELEASE_SAFELY(_Data3);
    RELEASE_SAFELY(_Data4);
    RELEASE_SAFELY(_Data5);
    
    [super dealloc];
}


@end
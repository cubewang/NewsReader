//
//  TagGroup.m
//  iKnow
//
//  Created by curer on 11-12-13.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "TagGroup.h"


@implementation TagGroup

@synthesize tagName;
@synthesize tags;

+ (NSArray *)TagGroupWithJSON:(id)jsonObject
{
    if (![jsonObject isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSArray *array = (NSArray *)jsonObject;
    
    NSMutableArray *returnArr = [[NSMutableArray alloc] initWithCapacity:3];
    for (NSDictionary *item in array) {
        TagGroup *group = [[TagGroup alloc] init];
        group.tagName = [item objectForKey:@"name"];
        
        NSArray *tagsTemp = [item objectForKey:@"tags"];
        for (NSDictionary *dic in tagsTemp) {
            NSString *tempName = [dic objectForKey:@"name"];
            if (tempName) {
                [group.tags addObject:tempName];
            }
        }
        
        [returnArr addObject:group];
        [group release];
    }
    
    return [returnArr autorelease];
}

- (id)init
{
    if ((self = [super init])) {
        tags = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    return self;
}

- (void)dealloc
{
    [tags release];
    [tagName release];
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", tagName, [tags description]];
}

@end

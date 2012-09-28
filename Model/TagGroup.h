//
//  TagGroup.h
//  iKnow
//
//  Created by curer on 11-12-13.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>

//tags
//  name

@interface TagGroup : NSObject {
    NSString *tagName;
    NSMutableArray *tags;
}

@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, copy) NSMutableArray *tags;

@end

//
//  Session.h
//  iKnow
//
//  Created by Cube on 11-7-15.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Session : NSObject {

    NSString *Name;
    NSString *Description;
    NSString *DataTime;
    
    int MessageCount;
}

@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *Description;
@property (nonatomic, copy) NSString *DataTime;

@end

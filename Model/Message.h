//
//  Message.h
//  iKnow
//
//  Created by VMware on 11-7-15.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MessageCoreDataObject;

@interface Message : NSObject {

    NSString *UserId;
    NSString *UserName;
    NSString *Content;
    NSString *DataTime;
    NSString *HeadImage;
    
    int MessageType;
    NSString *messageResourceName;
    NSString *messageIdentify;
    BOOL FromMe;
    
    NSString *localDataTime;
    int status;
}

@property (nonatomic, copy) NSString *UserId;
@property (nonatomic, copy) NSString *UserName;
@property (nonatomic, copy) NSString *Content;
@property (nonatomic, copy) NSString *DataTime;
@property (nonatomic, copy) NSString *HeadImage;
@property (nonatomic, copy) NSString *messageResourceName;
@property (nonatomic, assign) int MessageType;
@property (nonatomic, copy) NSString *messageIdentify;
@property (nonatomic, assign) BOOL FromMe;
@property (nonatomic, copy) NSString *localDataTime;
@property (nonatomic, assign) int status;

-(id)initWithiMessage:(MessageCoreDataObject *)message;


@end

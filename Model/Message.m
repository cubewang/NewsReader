//
//  Message.m
//  iKnow
//
//  Created by VMware on 11-7-15.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "Message.h"
#import "XMPPMessage.h"
#import "MessageCoreDataObject.h"
#import "SessionCoreDataObject.h"


@implementation Message

@synthesize UserId, UserName, Content, DataTime, HeadImage, messageResourceName, 
    MessageType;
@synthesize messageIdentify;

@synthesize FromMe;
@synthesize localDataTime;
@synthesize status;

#pragma mark NSObject

// with out init headImage
-(id)initWithiMessage:(MessageCoreDataObject *)message
{
    self = [super init];
    if (self) {
        UserId = [message.session.userId copy];
        UserName = [message.name copy];
        Content = [message.content copy];
        messageResourceName = [message.resourceName copy];
        MessageType = [message.type intValue];
        DataTime = message.dataTime;
        messageIdentify = [message.identify copy];
    }
    return self;
}

- (NSString *)description {
    NSMutableString *string = [[NSMutableString alloc] initWithString:@"Message: "];
    if (UserName)   [string appendFormat:@"Name:%@", UserName];
    if (Content)   [string appendFormat:@"Content:%@", Content];
    
    return [string autorelease];
}

- (void)dealloc {
    [UserId release];
    [UserName release];
    [Content release];
    [DataTime release];
    [HeadImage release];
    [messageResourceName release];
    [messageIdentify release];
    [localDataTime release];
    
    [super dealloc];
}

@end

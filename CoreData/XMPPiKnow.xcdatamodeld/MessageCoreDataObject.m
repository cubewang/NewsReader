// 
//  MessageCoreDataObject.m
//  iKnow
//
//  Created by curer on 11-9-29.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "MessageCoreDataObject.h"
#import "Message.h"
#import "SessionCoreDataObject.h"

@implementation MessageCoreDataObject 

@dynamic identify;
@dynamic content;
@dynamic fromMe;
@dynamic localDataTime;
@dynamic dataTime;
@dynamic status;
@dynamic userId;
@dynamic type;
@dynamic name;
@dynamic resourceName;
@dynamic session;

+ (id)insertInManagedObjectWithMessage:(Message *)message 
               inSessionCoreDataObject:(SessionCoreDataObject *)session
                               context:(NSManagedObjectContext *)context
{
    NSParameterAssert(session);
    NSParameterAssert(message);
    
    if (context == nil) {
        return nil;
    }
    
    MessageCoreDataObject *newMessageObject;
	
    newMessageObject = [NSEntityDescription insertNewObjectForEntityForName:@"MessageCoreDataObject"
                                                     inManagedObjectContext:context];
    
    newMessageObject.userId = session.userId;
    
    newMessageObject.fromMe = message.FromMe ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0];
    newMessageObject.dataTime = message.DataTime;
    newMessageObject.content = message.Content;
    newMessageObject.localDataTime = message.localDataTime;
    newMessageObject.type = [NSNumber numberWithInt:message.MessageType];
    newMessageObject.resourceName = message.messageResourceName;
    newMessageObject.identify = message.messageIdentify;
    newMessageObject.status = [NSNumber numberWithInt:message.status];
    
    session.content = newMessageObject.content;
    session.dataTime = newMessageObject.dataTime;
    
    [session addMessagesObject:newMessageObject];
    
    return newMessageObject;
}

@end

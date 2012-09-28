//
//  MessageCoreDataObject.h
//  iKnow
//
//  Created by curer on 11-9-29.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SessionCoreDataObject;
@class Message;

@interface MessageCoreDataObject :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * identify;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * fromMe;
@property (nonatomic, retain) NSString * localDataTime;
@property (nonatomic, retain) NSString * dataTime;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * resourceName;
@property (nonatomic, retain) SessionCoreDataObject * session;

+ (id)insertInManagedObjectWithMessage:(Message *)message 
               inSessionCoreDataObject:(SessionCoreDataObject *)session
                               context:(NSManagedObjectContext *)context;

@end




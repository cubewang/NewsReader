//
//  SessionCoreDataObject.h
//  iKnow
//
//  Created by curer on 11-9-29.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MemberCoreDataObject;
@class MessageCoreDataObject;

@interface SessionCoreDataObject :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * dataTime;
@property (nonatomic, retain) NSNumber * unReadCount;
@property (nonatomic, retain) NSString * memberName;
@property (nonatomic, retain) NSSet* messages;
@property (nonatomic, retain) MemberCoreDataObject * member;

+ (SessionCoreDataObject *)newSessionWithId:(NSString *)userId 
                     inManagedObjectContext:(NSManagedObjectContext *)context;


+ (int)QueryUnReadMsgCountInContext:(NSManagedObjectContext *)context;

@end


@interface SessionCoreDataObject (CoreDataGeneratedAccessors)
- (void)addMessagesObject:(MessageCoreDataObject *)value;
- (void)removeMessagesObject:(MessageCoreDataObject *)value;
- (void)addMessages:(NSSet *)value;
- (void)removeMessages:(NSSet *)value;

@end


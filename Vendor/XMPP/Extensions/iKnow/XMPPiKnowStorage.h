//
//  XMPPiKnowStorage.h
//  iKnow
//
//  Created by curer on 11-9-27.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Message;
@class MessageCoreDataObject;
@class SessionCoreDataObject;
@class MemberCoreDataObject;

//不和其他XMPPCoreData 数据库一样，此类目前只可以在main thread 

@interface XMPPiKnowStorage : NSObject {
    NSManagedObjectContext *_context;
    
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

- (MessageCoreDataObject *)handleReceivedMessage:(Message *)message;
- (MessageCoreDataObject *)handleReceivedNotify:(Message *)notify;

- (int)QueryUnReadMsgCount;
- (int)QueryUnReadMsgCountWithUserID:(NSString *)userID;

- (MessageCoreDataObject *)fetchMessageWithIdentify:(NSString *)identify;

- (MemberCoreDataObject *)insertOrModifyMemberWidhUserID:(NSString *)userID;
- (MemberCoreDataObject *)fetchMemberWithUserID:(NSString *)userID;
- (NSArray *)fetchMembersWithPredicate:(NSPredicate *)predicate;

- (void)clearAllMessage;
- (NSManagedObjectContext *)getContext;
- (void)mayBeSave;
- (BOOL)save;

@property (nonatomic, retain) NSManagedObjectContext *context;


@end

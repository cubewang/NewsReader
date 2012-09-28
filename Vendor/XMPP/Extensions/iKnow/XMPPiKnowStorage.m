//
//  XMPPiKnowStorage.m
//  iKnow
//
//  Created by curer on 11-9-27.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMPPiKnowStorage.h"
#import "Message.h"
#import "SessionCoreDataObject.h"
#import "MemberCoreDataObject.h"
#import "MessageCoreDataObject.h"


@implementation XMPPiKnowStorage

@synthesize context = _context;

#pragma mark -
#pragma mark coreData

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    NSString *momPath = [[NSBundle mainBundle] pathForResource:@"XMPPiKnow" ofType:@"momd"];
    NSURL *momUrl = [NSURL fileURLWithPath:momPath];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momUrl];
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/XMPPiKnow.sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    
    NSError *error;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
                                  initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                  configuration:nil 
                                                            URL:storeURL
                                                        options:options 
                                                          error:&error]) {
        NSLog(@"Error: %@ error code = %d", [error localizedDescription], error.code);
        NSLog(@"unResolved error %@, %@", error, [error userInfo]);
    }
    
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)getContext
{
    if (_context != nil) {
        return _context;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:coordinator];
    }
    return _context;
}

static int pendingSaveRequest = 0;
const static int maxPendingSaveRequest = 10;

- (void)mayBeSave
{
    pendingSaveRequest++;
    
    if (pendingSaveRequest >= maxPendingSaveRequest) {
        pendingSaveRequest = 0;
        
        [self save];
    }
}

- (BOOL)save
{
    if (![[self getContext] hasChanges]) 
    {
        return NO;
    }
    
    NSError *error = nil;
    if (![[self getContext] save:&error]) {
        NSLog(@"%@", error.localizedDescription);
        abort();
    } 
    
    return YES;
}

#pragma mark message

- (MessageCoreDataObject *)handleReceivedMessage:(Message *)message 
{
    NSParameterAssert(message.UserId);
    
    SessionCoreDataObject *findSession = [SessionCoreDataObject newSessionWithId:message.UserId 
                                                         inManagedObjectContext:[self getContext]];
    
    
    MessageCoreDataObject *newMsg = [MessageCoreDataObject insertInManagedObjectWithMessage:message 
                                                                    inSessionCoreDataObject:findSession
                                                                                    context:[self getContext]];
    
    
    int unReadCount = [findSession.unReadCount intValue];
    unReadCount++;
    findSession.unReadCount = [NSNumber numberWithInt:unReadCount];
    findSession.memberName = message.UserName;
    
    if (findSession.member == nil) {
        findSession.member = [self insertOrModifyMemberWidhUserID:message.UserId];
    }
    
    NSError *error = nil;
    if (![[self getContext] save:&error]) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    return newMsg;
}

- (MessageCoreDataObject *)handleReceivedNotify:(Message *)notify
{
    if (notify == nil) {
        return nil;
    }
    
    notify.UserId = @"iKnowNotify";
    
    return [self handleReceivedMessage:notify];
}

- (int) QueryUnReadMsgCount 
{
    NSFetchRequest *requestSession = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SessionCoreDataObject" 
                                              inManagedObjectContext:[self getContext]];
    
    NSError *error=nil;
    [requestSession setEntity:entity];
    NSArray *result = [[[self getContext] executeFetchRequest:requestSession error:&error] copy];
    
    [requestSession release];
    int i = 0;
    
    int res = 0;
    //查看session 是否存在
    for (; i < [result count]; ++i) {
        SessionCoreDataObject *session = [result objectAtIndex:i];
        
        res += [session.unReadCount intValue];
    }
    
    [result release];
    return res;
}

- (int)QueryUnReadMsgCountWithUserID:(NSString *)userID
{
    MemberCoreDataObject *memberCoreDataObject = [self fetchMemberWithUserID:userID];
    if (memberCoreDataObject == nil) {
        return 0;
    }
    
    return [memberCoreDataObject.session.unReadCount intValue];
}

- (MessageCoreDataObject *)fetchMessageWithIdentify:(NSString *)identify
{
    if ([identify length] == 0) 
    {
        return nil;
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MessageCoreDataObject"
	                                          inManagedObjectContext:[self getContext]];
	
	NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"identify == %@", identify];
    
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setIncludesPendingChanges:YES];
	[fetchRequest setFetchLimit:1];
	
    NSError *error = nil;
	NSArray *results = [[self getContext] executeFetchRequest:fetchRequest error:&error];
	
    NSLog(@"%@",identify);
    
	return (MessageCoreDataObject *)[results lastObject];
}

- (void)clearAllMessage
{
    NSFetchRequest *requestSession = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SessionCoreDataObject" 
                                              inManagedObjectContext:[self getContext]];
    
    NSError *error=nil;
    [requestSession setEntity:entity];
    NSArray *result = [[[self getContext] executeFetchRequest:requestSession error:&error] copy];
    
    [requestSession release];
    
    for (SessionCoreDataObject *session in result)
	{
        [[self getContext] deleteObject:session];
	}
    
    [[self getContext] save:&error];
    
    [result release];
}

#pragma mark member

- (MemberCoreDataObject *)fetchMemberWithUserID:(NSString *)userID
{
    if ([userID length] == 0) 
    {
        return nil;
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MemberCoreDataObject"
	                                          inManagedObjectContext:[self getContext]];
	
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"userId == %@", userID];
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setReturnsObjectsAsFaults:NO]; //TODO why?
	
    NSError *error = nil;
    NSArray *results = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    return (MemberCoreDataObject *)[results lastObject];
}

- (NSArray *)fetchMembersWithPredicate:(NSPredicate *)predicate
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MemberCoreDataObject"
	                                          inManagedObjectContext:[self getContext]];
	
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entity];
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setReturnsObjectsAsFaults:NO];
	
    NSError *error = nil;
    return [[self getContext] executeFetchRequest:fetchRequest error:&error];
}

- (MemberCoreDataObject *)insertOrModifyMemberWidhUserID:(NSString *)userID;
{
    NSAssert(userID, @"userID can't be nil");
    
    MemberCoreDataObject *member;
    member = [self fetchMemberWithUserID:userID];
    
    if (member == nil) 
    {
        MemberCoreDataObject *newMember = [MemberCoreDataObject newMemberWithUserId:userID 
                                                             inManagedObjectContext:[self getContext]];
        member = newMember;
    }
    
    return member;
}

#pragma mark life

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Init the fetched results controller
        //NSError *error;
        
        //if (![[self fetchedResultsController] performFetch:&error])
            //NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    return self;
}

- (void)dealloc
{
    [_context release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [super dealloc];
}

@end

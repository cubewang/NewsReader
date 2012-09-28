// 
//  SessionCoreDataObject.m
//  iKnow
//
//  Created by curer on 11-9-29.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "SessionCoreDataObject.h"

#import "MemberCoreDataObject.h"
#import "MessageCoreDataObject.h"

@implementation SessionCoreDataObject 

@dynamic userId;
@dynamic content;
@dynamic dataTime;
@dynamic unReadCount;
@dynamic memberName;
@dynamic messages;
@dynamic member;

+ (SessionCoreDataObject *)newSessionWithId:(NSString *)userId 
                     inManagedObjectContext:(NSManagedObjectContext *)context;
{
    if (userId == nil) {
        return nil;
    }
    
    NSFetchRequest *requestSession = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SessionCoreDataObject" 
                                              inManagedObjectContext:context];
    
    NSError *error = nil;
    [requestSession setEntity:entity];
    NSArray *result = [[context executeFetchRequest:requestSession error:&error] copy];
    
    [requestSession release];
    
    int i = 0;
    for (; i < [result count]; ++i) {
        SessionCoreDataObject *session = [result objectAtIndex:i];
        
        if ([session.userId isEqualToString:userId]) {
            break;
        }
    }
    
    if (i < [result count]) {
        SessionCoreDataObject *session = [result objectAtIndex:i];
        
        [result release];
        return session;
    }
    else {
        //没有找到session 我们创建一个session
        SessionCoreDataObject *newSession = [NSEntityDescription insertNewObjectForEntityForName:@"SessionCoreDataObject" 
                                                                          inManagedObjectContext:context];
        newSession.userId = userId;
        [result release];
        return newSession;
    }
}

+ (int)QueryUnReadMsgCountInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *requestSession = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SessionCoreDataObject" 
                                              inManagedObjectContext:context];
    
    NSError *error = nil;
    [requestSession setEntity:entity];
    NSArray *result = [[context executeFetchRequest:requestSession error:&error] copy];
    
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

@end

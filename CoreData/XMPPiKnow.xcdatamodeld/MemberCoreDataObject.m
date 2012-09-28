// 
//  MemberCoreDataObject.m
//  iKnow
//
//  Created by curer on 11-10-9.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "MemberCoreDataObject.h"

#import "SessionCoreDataObject.h"

@implementation MemberCoreDataObject 

@dynamic name;
@dynamic userFlag;
@dynamic subscribeFlag;
@dynamic longitude;
@dynamic latitude;
@dynamic userId;
@dynamic signature;
@dynamic region;
@dynamic imageAvator;
@dynamic photoUrl;
@dynamic email;
@dynamic status;
@dynamic gender;
@dynamic session;

+ (MemberCoreDataObject *)newMemberWithUserId:(NSString *)userId 
                       inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (userId == nil) {
        return nil;
    }
    
    MemberCoreDataObject *newMember = [NSEntityDescription insertNewObjectForEntityForName:@"MemberCoreDataObject" 
                                                                    inManagedObjectContext:context];
    newMember.userId = userId;
    return newMember;
}

@end

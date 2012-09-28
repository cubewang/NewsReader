//
//  MemberCoreDataObject.h
//  iKnow
//
//  Created by curer on 11-10-9.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SessionCoreDataObject;

@interface MemberCoreDataObject :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * userFlag;
@property (nonatomic, retain) NSString * subscribeFlag;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * imageAvator;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) SessionCoreDataObject * session;

+ (MemberCoreDataObject *)newMemberWithUserId:(NSString *)userId 
                       inManagedObjectContext:(NSManagedObjectContext *)context;

@end




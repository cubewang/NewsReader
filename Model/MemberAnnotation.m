//
//  MemberAnnotation.m
//  iKnow
//
//  Created by Cube on 11-7-13.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "MemberAnnotation.h"

@implementation MemberAnnotation

@synthesize Latitude  = _Latitude; 
@synthesize Longitude = _Longitude;
@synthesize Name      = _Name;
@synthesize Email     = _Email;
@synthesize Url       = _Url;
@synthesize Tags      = _Tags;
@synthesize UserId    = _UserId;
@synthesize Gender    = _Gender;
@synthesize Signature = _Signature;
@synthesize AvatarImageUrl = _AvatarImageUrl;
@synthesize IsFriend       = _IsFriend;
@synthesize WordCount      = _WordCount;
@synthesize FavoritesCount = _FavoritesCount;
@synthesize DistanceFromMe = _DistanceFromMe;

/*
 
 @"gender",
 @"latitude",
 @"longitude",
 @"user_id",
 @"email",
 @"nickName",
 @"signature",
 @"userFlag",
 @"subscribeFlag",
 @"photoUrl",
 
 */

- (id)initWithUserInfoDictionary:(NSDictionary*)dictionary {
    
    if (self = [super init]) {
        self.UserId = [dictionary objectForKey:@"user_id"];
        self.Name = [dictionary objectForKey:@"nickName"];
        self.Latitude = [dictionary objectForKey:@"latitude"];
        self.Longitude = [dictionary objectForKey:@"longitude"];
        self.Signature = [dictionary objectForKey:@"signature"];
        self.AvatarImageUrl = [dictionary objectForKey:@"photoUrl"];
    }
    
    return self;
}

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = (_Latitude == nil || [_Latitude length] == 0) ? 40.041869 : [_Latitude doubleValue];
    theCoordinate.longitude = (_Longitude == nil || [_Longitude length] == 0) ? 116.414507 : [_Longitude doubleValue];
    
    return theCoordinate; 
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return (_Name != nil && [_Name length] > 0) ? _Name : DEFAULT_NAME;
}

// optional
- (NSString *)subtitle
{
    return (_Tags != nil && [_Tags length] > 0) ? _Tags : @"";
}

- (void)dealloc
{
    RELEASE_SAFELY(_Latitude);
    RELEASE_SAFELY(_Latitude);
    RELEASE_SAFELY(_Name);
    RELEASE_SAFELY(_UserId);
    RELEASE_SAFELY(_Email);
    RELEASE_SAFELY(_Gender);
    RELEASE_SAFELY(_Signature);
    RELEASE_SAFELY(_Url);
    RELEASE_SAFELY(_Tags);
    RELEASE_SAFELY(_AvatarImageUrl);
    RELEASE_SAFELY(_WordCount);
    RELEASE_SAFELY(_FavoritesCount);
    
    [super dealloc];
}

@end
//
//  MemberAnnotation.h
//  iKnow
//
//  Abstract: 默认的iKnow成员地图标识
//
//  Created by Cube on 11-7-13.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MemberAnnotation : NSObject <MKAnnotation>
{
    NSString *_Latitude;
    NSString *_Longitude;
    
    NSString *_Name;           //用户姓名
    NSString *_UserId;         //iKnow Id
    NSString *_Gender;         //性别
    NSString *_Email;          //用户Email
    NSString *_Signature;      //签名
    NSString *_Url;            //用户详细信息的Url
    NSString *_Tags;           //用户描述
    NSString *_AvatarImageUrl; //头像Url
    NSString *_WordCount;      //收藏词汇数
    NSString *_FavoritesCount; //收藏文章数
    BOOL _IsFriend;            //是否好友
    
    CLLocationDistance _DistanceFromMe; //与我的距离
}

@property (nonatomic, copy) NSString *Latitude;
@property (nonatomic, copy) NSString *Longitude;
@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *UserId;
@property (nonatomic, copy) NSString *Gender;
@property (nonatomic, copy) NSString *Email;
@property (nonatomic, copy) NSString *Signature;
@property (nonatomic, copy) NSString *Url;
@property (nonatomic, copy) NSString *Tags;
@property (nonatomic, copy) NSString *AvatarImageUrl;
@property (nonatomic, copy) NSString *WordCount;
@property (nonatomic, copy) NSString *FavoritesCount;
@property (nonatomic, assign) BOOL IsFriend;
@property (nonatomic, assign) CLLocationDistance DistanceFromMe;

- (id)initWithUserInfoDictionary:(NSDictionary*)dictionary;

@end
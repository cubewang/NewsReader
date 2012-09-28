//
//  ROAlbumResponseltem.h
//  SimpleDemo
//
//  Created by Winston on 11-8-16.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "ROResponseItem.h"


enum {
    ROAlbumVisibleTypeEveryone = 99,        //所有人可见
    ROAlbumVisibleTypeNeedPassword = 4,     //密码保护
    ROAlbumVisibleTypeSameNetwork = 3,      //同网络：同城，同校，同公司等
    ROAlbumVisibleTypeFriend = 1,           //仅好友可见
    ROAlbumVisibleTypePersonal = -1         //仅自己可见
};
typedef NSUInteger ROAlbumVisibleType;     //相册的隐私设置类型

enum {
    ROAlbumTypeNormal = 0,          //普通相册
    ROAlbumTypeAvatar= 1,           //头像相册
    ROAlbumTypeMMS = 3,             //彩信相册
    ROAlbumTypeUpload = 5,          //上传相册
    ROAlbumTypePhotoSticker = 7,    //大头贴相册
    ROAlbumTypeApplication = 12     //应用相册
};
typedef NSUInteger ROAlbumType;     //相册的类型

//封装的相册Responseltem ，album
@interface ROAlbumResponseltem : ROResponseItem{
   

    NSString* _albumId;
 
    NSString* _coverUrl;

    NSString* _userId;

    NSString* _name;
 
    NSString* _createTime;
 
    NSString* _updateTime;

    NSString* _description;
 
    NSString* _location;
   
    NSUInteger _size;
  
    ROAlbumVisibleType _visibleType;
   
    NSUInteger _commentCount;

    ROAlbumType _type;
    
}
//注释解释：属性描述;JSON字段名;个别属性值含义
/**
 *表示相册的ID;aid; 
 */
@property(nonatomic, readonly) NSString* albumId;
/**
 *表示相册的封面图片地址;url 
 */
@property(nonatomic, readonly) NSString* coverUrl;
/**
 *表示相册的所有者的id;uid 
 */
@property(nonatomic, readonly) NSString* userId;
/**
 *表示相册的名字; name
 */
@property(nonatomic, readonly) NSString* name;
/**
 *表示相册创建时间;create_time;
 *yyyy-mm-dd
 */
@property(nonatomic, readonly) NSString* createTime;
/**
 *表示相册更新的时间;upload_time
 *yyyy-mm-dd
 */
@property(nonatomic, readonly) NSString* updateTime;
/**
 *表示相册的描述;description 
 */
@property(nonatomic, readonly) NSString* description;
/**
 *表示相册拍摄的地点;location 
 */
@property(nonatomic, readonly) NSString* location;
/**
 *表示相册的大小，照片的数量;size 
 */
@property(nonatomic, readonly) NSUInteger size;
/**
 *表示相册的隐私设置;visible 
 */
@property(nonatomic, readonly) ROAlbumVisibleType visibleType;
/**
 *表示相册的评论数量;comment_count 
 */
@property(nonatomic, readonly) NSUInteger commentCount;
/**
 *表示相册的类型;type 
 */
@property(nonatomic, readonly) ROAlbumType type;

@end

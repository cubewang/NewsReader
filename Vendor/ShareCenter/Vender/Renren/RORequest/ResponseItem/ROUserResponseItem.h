//
//  ROUserResponseItem.h
//  SimpleDemo
//
//  Created by Winston on 11-8-12.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import "ROResponseItem.h"

//家乡信息
@interface ROUserHometownItem : ROResponseItem {

    NSString *_country;

    NSString *_province;

    NSString *_city;
}

//注释解释：属性描述;JSON字段名;个别属性值含义
/*
 *表示所在国家;country 
 */
@property(nonatomic,readonly)NSString *country;
/*
 *表示所在省份;province 
 */
@property(nonatomic,readonly)NSString *province;
/*
 *表示所在城市;city
 */
@property(nonatomic,readonly)NSString *city;

@end

//工作信息
@interface ROUserWorkInfoItem : ROResponseItem {

    NSString* _companyName;

    NSString* _description;

    NSString* _startDate;

    NSString* _endDate;
    
}
//注释解释：属性描述;JSON字段名;个别属性值含义
/*
 *表示所在公司;company_name; 
 */
@property(nonatomic,readonly)NSString *companyName;
/*
 *表示工作描述;description 
 */
@property(nonatomic,readonly)NSString *description;
/*
 *表示入职时间;start_date;
 *yyyy-mm-dd
 */
@property(nonatomic,readonly)NSString *startDate;
/*
 *表示离职职时间;end_date;
 *yyyy-mm-dd
 */
@property(nonatomic,readonly)NSString *endDate;

@end

//大学信息
@interface ROUserUniversityInfoItem : ROResponseItem {

    NSString *_name;

    NSString *_year;
 
    NSString *_department;
    
}
//注释解释：属性描述;JSON字段名;个别属性值含义
/*
 *表示大学名;name; 
 */
@property(nonatomic,readonly)NSString *name;
/*
 *表示入学时间;year; 
 */
@property(nonatomic,readonly)NSString *year;
/*
 *表示学院;department; 
 */
@property(nonatomic,readonly)NSString *department;

@end

//中学信息
@interface ROUserHighSchoolInfoItem : ROResponseItem {

    NSString *_name;

    NSString *_gradYear;
}
//注释解释：属性描述;JSON字段名;个别属性值含义
/*
 *表示中学学校名;name; 
 */
@property(nonatomic,readonly)NSString *name;
/*
 *表示入学时间;grad_year; 
 */
@property(nonatomic,readonly)NSString *gradYear;
@end

//用户信息
@interface ROUserResponseItem : ROResponseItem{

    NSString* _userId;

    NSString* _name;

    NSString* _tinyUrl;

    NSString* _headUrl;

    NSString* _starUser;

    NSString* _vipUser;
    
    NSString* _sex;

    NSString* _vipLevel;

    NSString* _brithday;

    NSString* _emailHash;

    NSString* _mainUrl;

    ROUserHometownItem *_hometownLocation;

    NSArray* _workHistory;

    NSArray* _universityHistory;

    NSArray* _highSchoolHistory;
    
}
//注释解释：属性描述;JSON字段名;个别属性值含义
/*---默认基本信息---*/
/*
 *表示用户id;uid 
 */
@property(nonatomic,readonly)NSString *userId;
/*
 *表示用户名;name 
 */
@property(nonatomic,readonly)NSString *name;
/*
 *表示头像链接;tinyurl;
 *50*50大小。
 */
@property(nonatomic,readonly)NSString *tinyUrl;
/*
 *表示头像链接;headurl
 *100*100大小
 */
@property(nonatomic,readonly)NSString *headUrl;
/*
 *表示是否为星级用户;star;
 *人人用户：1=是，0=不是;开心用户：0=非真实头像和姓名，1=非真实姓名，2=非真实头像，3=真实用户。
 */
@property(nonatomic,readonly)NSString *starUser;
/*
 *表示是否为vip用户;zidou; 
 *1=是，0=不是。
 */
@property(nonatomic,readonly)NSString *vipUser;
/*---详细信息---请求时需传fields参数*/
/*
 *表示用户性别;sex;
 *1=男性，0=女性。
 */
@property(nonatomic,readonly)NSString *sex;
/*
 *表示vip等级;vip;
 *当是vipUser为1时可用此属性。
 */
@property(nonatomic,readonly)NSString *vipLevel;
/*
 *表示出生时间;brithday
 *格式：yyyy-mm-dd
 */
@property(nonatomic,readonly)NSString* brithday;
/*
 *表示用户经过验证的email信息字符串;email_hash;
 *字符串包含的email经过crc32和md5的编码
 */
@property(nonatomic,readonly)NSString* emailHash;
/*
 *表示头像链接;mainurl 
 *200*200大小
 */
@property(nonatomic,readonly)NSString* mainUrl;
/*
 *表示家乡信息;hometown_location;
 */
@property(nonatomic,readonly)ROUserHometownItem *hometownLocation;
/*
 *表示工作经历;work_history;
 *其中object：ROUserWorkInfoItem
 */
@property(nonatomic,readonly)NSArray* workHistory;
/*
 *表示大学以上教育经历;university_history;
 *其中object：ROUserUniversityInfoItem
 */
@property(nonatomic,readonly)NSArray* universityHistory;
/*
 *表示中学以下教育经历;hs_history;
 *其中object：ROUserHighSchoolInfoItem
 */
@property(nonatomic,readonly)NSArray* highSchoolHistory;

@end

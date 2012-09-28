//
//  ROUserResponseItem.m
//  SimpleDemo
//
//  Created by Winston on 11-8-12.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "ROUserResponseItem.h"

@implementation ROUserHometownItem

@synthesize country = _country;
@synthesize province = _province;
@synthesize city = _city;

-(id)initWithDictionary:(NSDictionary*)responseDictionary
{
    self = [super initWithDictionary:responseDictionary];
    if (self) {
        _country = [self valueForItemKey:@"country"];
        _province = [self valueForItemKey:@"province"];
        _city = [self valueForItemKey:@"city"];
    }
    return self;
}
@end

@implementation ROUserWorkInfoItem

@synthesize companyName = _companyName;
@synthesize description = _description;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;

-(id)initWithDictionary:(NSDictionary*)responseDictionary
{
    self = [super initWithDictionary:responseDictionary];
    if (self) {
        _companyName = [self valueForItemKey:@"company_name"];
        _description = [self valueForItemKey:@"desription"];
        _startDate = [self valueForItemKey:@"start_date"];
        _endDate = [self valueForItemKey:@"end_date"];
    }
    return self;
}

@end

@implementation ROUserUniversityInfoItem

@synthesize name = _name;
@synthesize year = _year;
@synthesize department = _department;

-(id)initWithDictionary:(NSDictionary*)responseDictionary
{
    self = [super initWithDictionary:responseDictionary];
    if (self) {
        _name = [self valueForItemKey:@"name"];
        _year = [self valueForItemKey:@"year"];
        _department = [self valueForItemKey:@"department"];
    }
    return self;
}
@end

@implementation ROUserHighSchoolInfoItem

@synthesize name = _name;
@synthesize gradYear = _gradYear;

-(id)initWithDictionary:(NSDictionary*)responseDictionary
{
    self = [super initWithDictionary:responseDictionary];
    if (self) {
        _name = [self valueForItemKey:@"name"];
        _gradYear = [self valueForItemKey:@"grad_year"];
    }
    return self;
}

@end

@implementation ROUserResponseItem

@synthesize userId = _userId;
@synthesize name = _name;
@synthesize tinyUrl = _tinyUrl;
@synthesize headUrl = _headUrl;
@synthesize starUser = _starUser;
@synthesize vipUser = _vipUser;
@synthesize sex = _sex;
@synthesize vipLevel = _vipLevel;
@synthesize brithday = _brithday;
@synthesize emailHash = _emailHash;
@synthesize mainUrl = _mainUrl;
@synthesize hometownLocation = _hometownLocation;
@synthesize workHistory = _workHistory;
@synthesize universityHistory = _universityHistory;
@synthesize highSchoolHistory = _highSchoolHistory;

-(id)initWithDictionary:(NSDictionary*)responseDictionary
{
    self = [super initWithDictionary:responseDictionary];
    if (self) {
        _userId = [self valueForItemKey:@"uid"];
        _name = [self valueForItemKey:@"name"];
        _sex = [self valueForItemKey:@"sex"];
        _starUser = [self valueForItemKey:@"star"];
        _vipUser = [self valueForItemKey:@"zidou"];
        _vipLevel = [self valueForItemKey:@"vip"];
        _brithday = [self valueForItemKey:@"brithday"];
        _emailHash = [self valueForItemKey:@"email_hash"];
        _tinyUrl = [self valueForItemKey:@"tinyurl"];
        _headUrl = [self valueForItemKey:@"headurl"];
        _mainUrl = [self valueForItemKey:@"mainurl"];
        if ([self valueForItemKey:@"hometown_location"]) {
            _hometownLocation = [[ROUserHometownItem alloc] initWithDictionary:[self valueForItemKey:@"hometown_location"]];
        }
        if ([self valueForItemKey:@"work_history"]) {
            NSMutableArray* wh = [[NSMutableArray alloc] init];
            NSArray* workHistoryArray = (NSArray*)[self valueForItemKey:@"work_history"];
            for (NSDictionary *workInfoDic in workHistoryArray) {
                ROUserWorkInfoItem *item = [[ROUserWorkInfoItem alloc] initWithDictionary:workInfoDic];
                [wh addObject:item];
                [item release];
            }
            _workHistory = wh;
        }
        if ([self valueForItemKey:@"university_history"]) {
            NSMutableArray* uh = [[NSMutableArray alloc] init];
            NSArray* universityHistoryArray = (NSArray*)[self valueForItemKey:@"university_history"];
            for (NSDictionary *universityInfoDic in universityHistoryArray) {
                ROUserUniversityInfoItem *item = [[ROUserUniversityInfoItem alloc] initWithDictionary:universityInfoDic];
                [uh addObject:item];
                [item release];
            }
            _universityHistory = uh;
        }
        if ([self valueForItemKey:@"hs_history"]) {
            NSMutableArray* hsh = [[NSMutableArray alloc] init];
            NSArray* highSchoolHistoryArray = (NSArray*)[self valueForItemKey:@"hs_history"];
            for (NSDictionary *highSchoolInfoDic in highSchoolHistoryArray) {
                ROUserHighSchoolInfoItem *item = [[ROUserHighSchoolInfoItem alloc] initWithDictionary:highSchoolInfoDic];
                [hsh addObject:item];
                [item release];
            }
            _highSchoolHistory = hsh;
        }
        
    }
    return self;
}

-(void)dealloc
{
    [_hometownLocation release];
    [_highSchoolHistory release];
    [_universityHistory release];
    [_workHistory release];
    [super dealloc];
}

@end

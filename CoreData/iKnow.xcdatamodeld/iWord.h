//
//  iWord.h
//  EnglishFun
//
//  Created by curer on 12-1-3.
//  Copyright 2012 iKnow Team. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface iWord :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * queryTimes;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * acceptation;
@property (nonatomic, retain) NSString * createDate;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSString * remark;

@end




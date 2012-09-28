//
//  Word.h
//  iKnow
//
//  Created by Cube on 11-5-16.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Word : NSObject {
    
    NSString *_Key;
    NSString *_PhoneticSymbol; //音标
    NSString *_Pronunciation;  //发音的链接
    NSString *_Description;
    NSMutableDictionary *_AcceptationList;  //词性、词义
    NSMutableArray *_SentenceList;    //例句
    
    NSString *_CreateTime;
}

@property (nonatomic, copy) NSString *Key;
@property (nonatomic, copy) NSString *PhoneticSymbol;
@property (nonatomic, copy) NSString *Pronunciation;
@property (nonatomic, copy) NSString *Description;
@property (nonatomic, retain) NSMutableDictionary *AcceptationList;
@property (nonatomic, retain) NSMutableArray *SentenceList;

@property (nonatomic, retain) NSString *CreateTime;

- (id)initWithJsonDictionary:(NSDictionary*)dictionary;

@end

@interface Sentence : NSObject {
    
    NSString *_Orig;
    NSString *_Pron;
    NSString *_Trans;
}

@property (nonatomic, copy) NSString *Orig;
@property (nonatomic, copy) NSString *Pron;
@property (nonatomic, copy) NSString *Trans;

@end
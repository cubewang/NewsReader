//
//  Word.m
//  iKnow
//
//  Created by Cube on 11-5-16.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "Word.h"


@implementation Word

@synthesize Key = _Key;
@synthesize PhoneticSymbol = _PhoneticSymbol;
@synthesize Pronunciation = _Pronunciation;
@synthesize Description = _Description;
@synthesize AcceptationList = _AcceptationList;
@synthesize SentenceList = _SentenceList;
@synthesize CreateTime = _CreateTime;

- (id)init {
    if (self = [super init]) {
        
        _AcceptationList = [[NSMutableDictionary alloc] init];
        _SentenceList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)updateWithJsonDictionary:(NSDictionary*)dictionary {
    
    [self reset];
    
    _AcceptationList = [[NSMutableDictionary alloc] init];
    _SentenceList = [[NSMutableArray alloc] init];
    
    _Key = [[dictionary objectForKey:@"word"] retain];
    _PhoneticSymbol = [[dictionary objectForKey:@"pron"] retain];
    _Pronunciation = [[dictionary objectForKey:@"audio_url"] retain];
    _Description = [[dictionary objectForKey:@"description"] retain];
    _CreateTime = [[dictionary objectForKey:@"create_time"] retain];
    
    NSString *acceptation = [dictionary objectForKey:@"def"];
    
    [_AcceptationList setObject:[NSString stringWithString:acceptation] forKey:@""];
}

- (id)initWithJsonDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        [self updateWithJsonDictionary:dictionary];
    }
    
    return self;
}

- (void)reset {
    RELEASE_SAFELY(_Key);
    RELEASE_SAFELY(_PhoneticSymbol);
    RELEASE_SAFELY(_Pronunciation);
    RELEASE_SAFELY(_Description);
    RELEASE_SAFELY(_AcceptationList)
    RELEASE_SAFELY(_SentenceList);
    RELEASE_SAFELY(_CreateTime);
}

- (void)dealloc {
    [self reset];
    
    [super dealloc];
}

@end



@implementation Sentence

@synthesize Orig = _Orig;
@synthesize Pron = _Pron;
@synthesize Trans = _Trans;

- (void)dealloc {
    RELEASE_SAFELY(_Orig);
    RELEASE_SAFELY(_Pron);
    RELEASE_SAFELY(_Trans);
    
    [super dealloc];
}

@end

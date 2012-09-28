//
//  ParserPrivate.h
//  iKnow
//
//  Created by Cube on 11-4-23.
//  Copyright 2011 iKnow Team. All rights reserved.
//

@interface Parser ()

#pragma mark Private Properties

// Downloading Properties
@property (nonatomic, copy) NSString *url;
@property (nonatomic, retain) NSDictionary *postDictionary;


#pragma mark Private Methods

// Parsing Methods
- (void)reset;
- (void)parsingFinished;
- (void)parsingFailedWithDescription:(NSString *)description;
- (void)startParsingData:(NSData *)data textEncodingName:(NSString *)textEncodingName;


@end

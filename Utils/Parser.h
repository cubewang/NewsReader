//
//  Parser.h
//  iKnow
//
//  Created by Cube on 11-9-21.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Downloader.h"
#import "Article.h"
#import "Comment.h"
#import "Word.h"
#import "DataItem.h"

// Class
@class Parser;


// Delegate
@protocol ParserDelegate <NSObject>
@optional
- (void)parserDidStart:(Parser *)parser;
- (void)parser:(Parser *)parser didParseKeyValuePair:(NSString *)key andValue:(NSString *)value;
- (void)parser:(Parser *)parser didParseArticle:(Article *)article;
- (void)parser:(Parser *)parser didParseComment:(Comment *)comment;
- (void)parser:(Parser *)parser didParseWord:(Word *)word;
- (void)parser:(Parser *)parser didParseDataItem:(DataItem *)item;
- (void)parserDidFinish:(Parser *)parser;
- (void)parser:(Parser *)parser didFailWithError:(NSString *)error;
@end



@interface Parser : NSObject {

    // Required
    id <ParserDelegate> _delegate;
    BOOL _canceled;
    BOOL _useCacheFirst;
    
    // Connection
    ConnectionType _connectionType;
    Downloader *_downloader;
    
    // Parsing State
    NSString *url;
    NSDictionary *_postDictionary;
    BOOL aborted; // Whether parse stopped due to abort
    BOOL parsing; // Whether the Parser has started parsing
    BOOL stopped; // Whether the parse was stopped
    BOOL failed;  // Whether the parse failed
    BOOL parsingComplete; // Whether parsing has completed
}

// Whether parsing was stopped
@property (nonatomic, readonly, getter=isStopped) BOOL stopped;

// Whether parsing failed
@property (nonatomic, readonly, getter=didFail) BOOL failed;

// Whether parsing is in progress
@property (nonatomic, readonly, getter=isParsing) BOOL parsing;

@property (nonatomic, assign) BOOL useCacheFirst;

// Init Parser with a Url string, and have no post dictionary
- (id)initWithString:(NSString *)Url
            delegate:(id<ParserDelegate>)delegate
      postDictionary:(NSDictionary*)dictionary
      connectionType:(ConnectionType)type;

// Init Parser with a Url string
- (id)initWithString:(NSString *)Url
            delegate:(id<ParserDelegate>)delegate 
      connectionType:(ConnectionType)type;

// Begin parsing
- (BOOL)parse;

// Stop parsing
- (void)stopParsing;

// Returns the URL
- (NSString *)url;

- (void)cancel;

@end

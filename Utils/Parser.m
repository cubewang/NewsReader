//
//  Parser.m
//  iKnow
//
//  Created by Cube on 11-9-21.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "Parser.h"
#import "ParserPrivate.h"

static const int ddLogLevel = LOG_FLAG_ERROR;

@implementation Parser

// Properties
@synthesize url;
@synthesize postDictionary = _postDictionary;
@synthesize stopped, failed, parsing;
@synthesize useCacheFirst = _useCacheFirst;

#pragma mark -
#pragma mark NSObject

- (id)init {
    if (self = [super init]) {
        
        _canceled = FALSE;
        _useCacheFirst = YES;
    }
    return self;
}

// Initialise with a URL
- (id)initWithString:(NSString *)Url 
            delegate:(id<ParserDelegate>)delegate
      connectionType:(ConnectionType)type 
{
    return [self initWithString:Url delegate:delegate postDictionary:nil connectionType:type];
}

- (id)initWithString:(NSString *)Url 
         delegate:(id<ParserDelegate>)delegate
      postDictionary:(NSDictionary*)dictionary
      connectionType:(ConnectionType)type 
{
    if (delegate == nil)
        return nil;
    
    if (type != ConnectionTypeSynchronously && type != ConnectionTypeAsynchronously)
        return nil;
    
    if (self = [self init]) {
        
        // Remember url
        self.url = Url;
        _delegate = delegate;
        _connectionType = type;
        
        if (dictionary)
            self.postDictionary = dictionary;
    }
    
    return self;
}

- (void)dealloc {
    RELEASE_SAFELY(url);
    RELEASE_SAFELY(_postDictionary);
    
    [_downloader cancel];
    RELEASE_SAFELY(_downloader);
    
    [super dealloc];
}

#pragma mark -
#pragma mark Parsing

- (void)cancel 
{
    _canceled = TRUE;
    _delegate = nil;
    [_downloader cancel];
    RELEASE_SAFELY(_downloader);
}


- (BOOL)parse {
    if (_canceled)
        return TRUE;
    
    // Perform checks before parsing
    if (!url || !_delegate) { 
        [self parsingFailedWithDescription:@"Delegate or URL not specified"]; 
        return NO; 
    }
    
    if (parsing) { 
        [self parsingFailedWithDescription:@"Cannot start parsing as parsing is already in progress"]; 
        return NO; 
    }
    
    // Reset state for next parse
    parsing = YES;
    aborted = NO;
    stopped = NO;
    failed = NO;
    parsingComplete = NO;
    
    // Start
    BOOL success = YES;
    
    if (_downloader) {
        [_downloader cancel];
        RELEASE_SAFELY(_downloader);
    }
    
    _downloader = [[Downloader alloc] initWithString:url 
                                         delegate:self
                                      postDictionary:_postDictionary
                                      connectionType:_connectionType 
                                      downloaderType:DownloaderTypeData];
    _downloader.useCacheFirst = self.useCacheFirst;
    [_downloader download];
}


// Stop parsing
- (void)stopParsing {
    
    // Only if we're parsing
    if (parsing && !parsingComplete) {

        DDLogInfo(@"Parsing stopped");
        
        // Stop
        stopped = YES;
        
        // Abort
        aborted = YES;
        
        [_downloader cancel];
        RELEASE_SAFELY(_downloader);
        
        // Finished
        [self parsingFinished];
        
    }
}

// Finished parsing document successfully
- (void)parsingFinished {
    
    // Finish
    if (!parsingComplete) {
        
        // Set state and notify delegate
        parsing = NO;
        parsingComplete = YES;
        if (!_canceled && [_delegate respondsToSelector:@selector(parserDidFinish:)])
        {
            [_delegate parserDidFinish:self];
        }
    }
}

// If an error occurs, create NSError and inform delegate
- (void)parsingFailedWithDescription:(NSString *)description {
    
    // Finish & create error
    if (!parsingComplete) {
        
        // State
        failed = YES;
        parsing = NO;
        parsingComplete = YES;

        DDLogInfo(@"%@", description);
    }
    
    // Inform delegate
    if (!_useCacheFirst && !_canceled && [_delegate respondsToSelector:@selector(parser:didFailWithError:)])
        [_delegate parser:self didFailWithError:description];
}

#pragma mark -
#pragma mark DownloaderDelegate

- (void)downloader:(Downloader *)downloader didFailWithError:(NSString *)error{

    // Error
    [self parsingFailedWithDescription:error];
}

- (void)downloader:(Downloader *)downloader didDownloadData:(NSData *)data {

    // Parse
    if (!stopped) [self startParsingData:data];
}

@end

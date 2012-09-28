//
//  WordDownloader.m
//  iKnow_iPad
//
//  Created by curer yg on 12-3-3.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "WordDownloader.h"
#import "Parser.h"
#import "iKnowAPI.h"

@implementation WordDownloader

@synthesize delegate;
@synthesize parseList;
@synthesize word;

#pragma mark life

- (id)init
{
    if (self = [super init]) {
        parseList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [self cancel];
    
    [parseList release];
    [word release];
    
    [super dealloc];
}

#pragma mark common

- (void)downloadWord:(NSString *)selection
{
    [self cancel];
    
    Parser *parser = [iKnowAPI queryWordOnline:selection delegate:self useCacheFirst:YES];
    if (parser) {
        [parseList addObject:parser];
    }
}

- (void)cancel
{
    for (Parser *item in parseList) {
        [item cancel];
    }
    
    [parseList removeAllObjects];
}

- (void)resultFailed
{
    if ([delegate respondsToSelector:@selector(wordDownloadError)]) {
        [delegate wordDownloadError];
    }
}

- (void)resultSuccess:(Word *)aWord
{
    if ([delegate respondsToSelector:@selector(wordDownloadFinished:)]) {
        [delegate wordDownloadFinished:aWord];
    }
}

#pragma mark Parse

- (void)parser:(Parser *)parser didFailWithError:(NSString *)error {
    
    [self resultFailed];
}

- (void)parserDidFinish:(Parser *)parser {
    
    if (self.word && [self.word.AcceptationList count] > 0) {
        //
        [self resultSuccess:self.word];
    }
    else {
        [self resultFailed];
    }
}

- (void)parser:(Parser *)parser didParseWord:(Word *)parsedWord {
    
    if (parsedWord)
    {
        self.word = parsedWord;
    }
}

@end

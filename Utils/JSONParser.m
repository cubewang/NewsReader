//
//  Parser.m
//  iKnow
//
//  Created by Cube on 11-9-21.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "JSONParser.h"

static const int ddLogLevel = LOG_FLAG_ERROR;

@implementation JSONParser


#pragma mark -
#pragma mark Parsing


// Begin JSON parsing
- (void)startParsingData:(NSData *)data {
    
    if (_canceled)
        return;
        
    if (data == nil) 
    {
        [self parsingFailedWithDescription:@"Error with encoding"];
        return;
    }

    NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //打印获得的数据信息
    DDLogInfo(@"%@", jsonString);
    
    id jsonObject = [jsonString JSONValue];
    
    if ([jsonObject isKindOfClass:[NSDictionary class]]) //对象字典
    {
        if ([[jsonObject objectForKey:@"error"] length] > 0) {
            [self parsingFailedWithDescription:@"Server get error"];
            
            return;
        }
        
        // Inform delegate
        if (!_canceled && [_delegate respondsToSelector:@selector(parserDidStart:)])
            [_delegate parserDidStart:self];
        
        [self _informDelegate:jsonObject];
    }
    else if ([jsonObject isKindOfClass:[NSArray class]]) //对象数组
    {
        // Inform delegate
        if (!_canceled && [_delegate respondsToSelector:@selector(parserDidStart:)])
            [_delegate parserDidStart:self];
        
        NSArray* array = (NSArray*)jsonObject;
        
        for (id object in array)
        {
            [self _informDelegate:object];
        }
    }
    
    // Inform delegate
    [self parsingFinished];
}


- (void)_informDelegate:(id)object
{
    if (object == nil)
        return;

    if ([url rangeOfString:CONTENT_LIST_PATH].location != NSNotFound) {
        
        Article *newArticle = [[Article alloc] initWithJsonDictionary:(NSDictionary*)object];
        
        if ([_delegate respondsToSelector:@selector(parser:didParseArticle:)])
            [_delegate parser:self didParseArticle:newArticle];
        
        DDLogVerbose(@"Parser: Article for \"%@\" successfully parsed", newArticle.Name);
        
        [newArticle release];
    }
    else if ([url rangeOfString:TAG_LIST_PATH].location != NSNotFound) {
        
        if ([object isKindOfClass:[NSArray class]] &&
            [_delegate respondsToSelector:@selector(parser:didParseKeyValuePair:andValue:)]) {
            
            NSArray *array = (NSArray *)object;
            
            if ([array count] != 2)
                return;
            
            NSString *value1 = [array objectAtIndex:0];
            NSString *value2 = [array objectAtIndex:1];
            
            [_delegate parser:self didParseKeyValuePair:[value2 isEqualToString:@"1"] ? @"Tag1" : @"Tag2"
                     andValue:value1];
        }
    }
    else if ([url rangeOfString:COMMENT_LIST_PATH].location != NSNotFound) {
        
        Comment *newComment = [[Comment alloc] initWithJsonDictionary:(NSDictionary*)object];
        
        // Dispatch Chapter to delegate
        if ([_delegate respondsToSelector:@selector(parser:didParseComment:)])
            [_delegate parser:self didParseComment:newComment];
        
        DDLogVerbose(@"Parser: Comment for \"%@\" successfully parsed", newComment.Content);
        
        [newComment release];
    }
    else if ([url rangeOfString:WORD_LIST_PATH].location != NSNotFound) {
        
        Word *newWord = [[Word alloc] initWithJsonDictionary:(NSDictionary*)object];
        
        // Dispatch Word to delegate
        if ([_delegate respondsToSelector:@selector(parser:didParseWord:)])
            [_delegate parser:self didParseWord:newWord];
        
        DDLogVerbose(@"Parser: Word for \"%@\" successfully parsed", newWord.Key);
        
        [newWord release];
    }
    else if ([url rangeOfString:FAVORITE_LIST_PATH].location != NSNotFound) {
        
        NSDictionary *favoriteDictionary = (NSDictionary*)object;
        
        Article *newArticle = [[Article alloc] initWithJsonDictionary:(NSDictionary*)[favoriteDictionary objectForKey:@"content"]];
        
        // Dispatch Favorite to delegate
        if ([_delegate respondsToSelector:@selector(parser:didParseArticle:)])
            [_delegate parser:self didParseArticle:newArticle];
        
        DDLogVerbose(@"Parser: Favorite for \"%@\" successfully parsed", newArticle.Name);
        
        [newArticle release];
    }
    else  if ([url rangeOfString:SHORT_URL_PATH].location != NSNotFound) {
        
        NSString *shortUrl = [(NSDictionary*)object objectForKey:@"url_short"];
        
        // Dispatch Chapter to delegate
        if ([_delegate respondsToSelector:@selector(parser:didParseKeyValuePair:andValue:)])
            [_delegate parser:self didParseKeyValuePair:@"url_short" andValue:shortUrl];
    }

}

@end

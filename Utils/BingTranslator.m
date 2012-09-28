//
//  BingTransltor.m
//  EnglishFun
//
//  Created by cg on 12-7-10.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import "BingTranslator.h"
#import "ASIFormDataRequest.h"
#import "iKnowAPI.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "XMLParser.h"
#import "ASIDownloadCache.h"
#import "Client.h"

@interface BingTranslator () {
    
    NSMutableDictionary *dictionary;
    NSMutableDictionary *keyDictionary;
    
    int keyIndex;
    
    NSString *translatorContent;
}

@property (nonatomic, retain) NSMutableDictionary *dictionary;
@property (nonatomic, retain) NSMutableDictionary *keyDictionary;
@property (nonatomic, retain) NSString *translatorContent;


@end

@implementation BingTranslator

@synthesize dictionary;
@synthesize keyDictionary;
@synthesize translatorContent;


- (void) dealloc {
    
    self.dictionary = nil;
    self.keyDictionary = nil;
    self.translatorContent = nil;
    
    [super dealloc];
}

- (NSString *) getAccessToken {
    
    NSString *req = [BING_TOKEN stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:req]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    request.requestMethod = @"post";
    
    NSString *bingKey = [ self.keyDictionary objectForKey:@"ID"];
    NSString *bingSecretKey = [ self.keyDictionary objectForKey:@"Secret"];
    
    [request addPostValue:GRANTTYPE forKey:@"grant_type"];
    [request addPostValue:bingKey forKey:@"client_id"];
    [request addPostValue:bingSecretKey forKey:@"client_secret"];
    [request addPostValue:SCOPE forKey:@"scope"];    
    
    request.responseEncoding = NSUTF8StringEncoding;
    
    [request startSynchronous];

    NSError *error = [request error];
    
    NSString *str = nil;
    
    if (!error) {
        
        if (request.responseString == nil) {
            return nil;
        }
        else {
            str = request.responseString;
        }
    }
    
    NSDictionary *dict = [str JSONValue];
    NSString *accessToken = [dict objectForKey:@"access_token"];
    
    [request release];

    return accessToken;
}

- (NSString *)getTranslatorData:(NSString *)string {
    
    NSString *accessToken = [self getAccessToken];

    if (accessToken == nil) {
        return nil;
    }

    NSString *str = [string stringByReplacingOccurrencesOfString:@"&" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"?" withString:@" "];
    
    NSString *text = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *from = @"en";
    NSString *to  = nil;
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    if ([currentLanguage isEqualToString:@"zh-Hant"]) {
        
        to = @"zh-CHT";
    }
    else if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        
        to = @"zh-CHS";
    }
    else  {
        to = currentLanguage;
    } 
        
    NSString *url = [NSString stringWithFormat:@"%@%@&from=%@&to=%@",BINGURL,text,from,to];
    NSString *authToken = [NSString stringWithFormat:@"Bearer %@",accessToken];
    
    ASIHTTPRequest *request =[[[ASIHTTPRequest alloc] init] autorelease];
    
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    
    [request addRequestHeader:@"Authorization" value:authToken];
    [request setURL:[NSURL URLWithString:url]];
    request.delegate = self;
    
    request.requestMethod = @"GET";
    
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (error != nil) {
        return nil;
    } 
    
    NSData *data = [request responseData];
    NSString* responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    XMLParser *parser = [[[XMLParser alloc] init] autorelease];
    
    [parser startParsingData:data];
    
    self.translatorContent = parser.currentText;
    
    return responseString;
}

- (NSString *) getTranslatorContent:(NSString *)content articleId:(NSString *) articleId {
    
    NSString *savePath = [TRANSLATOR_CACHE stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",articleId]];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:TRANSLATOR_CACHE withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSString *cache = [NSString stringWithContentsOfFile:savePath encoding:NSUTF8StringEncoding error:nil];
     
    if (cache != nil) {

        return cache;
     }
     
    if ([content length] > 3000) {
        
        content = [content substringToIndex:3000];
    }
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Translator" ofType:@"plist"];
    
    self.dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    self.keyDictionary = [self.dictionary objectForKey:[NSString stringWithFormat:@"%d",keyIndex]];
    
    while ([self.keyDictionary objectForKey:@"isValid"] == NO) {
        
        keyIndex ++;
        self.keyDictionary = [self.dictionary objectForKey:[NSString stringWithFormat:@"%d",keyIndex]];
    }
    
    NSString *translatorRetString = [self getTranslatorData:content];
    
    while (![translatorRetString hasPrefix:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">"]) {
        
        [self.keyDictionary setValue:NO forKey:@"isValid"];
        [self.dictionary setValue:self.keyDictionary forKey:[NSString stringWithFormat:@"%d",keyIndex]];
        [self.dictionary writeToFile:plistPath atomically:YES];
        
        keyIndex++;
        
        NSString *key = [NSString stringWithFormat:@"%d",keyIndex];
        self.keyDictionary = [self.dictionary objectForKey:key];
        
        translatorRetString = [self getTranslatorData:content];
        
        if (keyIndex > 5) {
            return nil;
        }
    }
    
     if (![translatorRetString hasPrefix:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">"]) {
     
         return nil;
     }
   
    if (self.translatorContent == nil) {
        return nil;
    }
    
    NSError *error;
    [self.translatorContent writeToFile:savePath atomically:YES 
            encoding:NSUTF8StringEncoding error:&error];

    return self.translatorContent;
}

@end
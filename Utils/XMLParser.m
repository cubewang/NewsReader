//
//  Parser.m
//  iKnow
//
//  Created by Cube on 11-4-23.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "XMLParser.h"

static const int ddLogLevel = LOG_FLAG_ERROR;

// Implementation
@implementation XMLParser

// Properties
@synthesize xmlParser, currentPath, currentText, temporaryText, currentElementAttributes;
@synthesize word = _word;
@synthesize pathOfElement;

- (void)dealloc {
    RELEASE_SAFELY(xmlParser);
    RELEASE_SAFELY(currentPath);
    RELEASE_SAFELY(currentText);
    RELEASE_SAFELY(temporaryText);
    RELEASE_SAFELY(currentElementAttributes);
    RELEASE_SAFELY(pathOfElement);
    
    RELEASE_SAFELY(_word);

    [super dealloc];
}

#pragma mark -
#pragma mark Parsing

// Begin XML parsing
- (void)startParsingData:(NSData *)data {
    if (!_canceled && !xmlParser) {
        
        // Create NSXMLParser
        if (data) 
        {
            //打印获得的数据信息
            DDLogInfo([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
            
            self.currentPath = @"/";
            self.currentText = [[[NSMutableString alloc] init] autorelease];
            
            xmlParser = [[NSXMLParser alloc] initWithData:data];
            if (xmlParser)
            {
                // Parse!
                xmlParser.delegate = self;
                [xmlParser setShouldProcessNamespaces:YES];
                [xmlParser parse];
                RELEASE_SAFELY(xmlParser); // Release after parse
            } 
            else 
            {
                [self parsingFailedWithDescription:@"Not a valid XML document"];
            }
        } 
        else 
        {
            [self parsingFailedWithDescription:@"Error with encoding"];
        }
        
    }
}

#pragma mark -
#pragma mark XML Parsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {

    if (_canceled)
        return;
    
    // Pool
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Adjust path
    self.currentPath = [currentPath stringByAppendingPathComponent:qualifiedName];
    self.currentElementAttributes = attributeDict;
    
    // Reset
    [self.currentText setString:@""];
    
    // Entering new item element
    if ([currentPath isEqualToString:@"/dict"]) {
        
        // New Word
        Word *newWord = [[Word alloc] init];
        self.word = newWord;
        [newWord release];
    }
    
    // Drain
    [pool drain];
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

    if (_canceled)
        return;
    
    // Pool
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString* sentenceString = nil;
    
    // Store data
    if (currentText) {
        
        if ([currentPath isEqualToString:@"/dict/key"]) {
            
            if (_word == nil)
                _word = [[Word alloc] init];
            
            _word.Key = currentText;
        }
        else if ([currentPath isEqualToString:@"/dict/ps"] 
                 || [currentPath isEqualToString:@"/dict/pron"] && [url rangeOfString:@"dict.cn"].length > 0) {

            _word.PhoneticSymbol = currentText;
        }
        else if ([currentPath isEqualToString:@"/dict/pron"] && [url rangeOfString:@"iciba.com"].length > 0
                 || [currentPath isEqualToString:@"/dict/audio"]) {

            _word.Pronunciation = currentText;
        }
        else if ([currentPath isEqualToString:@"/dict/pos"]) {

            self.temporaryText = currentText;
        }
        else if ([currentPath isEqualToString:@"/dict/acceptation"]) {

            [_word.AcceptationList setObject:[NSString stringWithString:currentText] forKey:temporaryText ? temporaryText : @""];
            
            self.temporaryText = nil;
        }
        else if ([currentPath isEqualToString:@"/dict/def"]) {
            
            [_word.AcceptationList setObject:[NSString stringWithString:currentText] forKey:@""];
        }
        else if ([currentPath isEqualToString:@"/dict/sent/orig"]) {

            Sentence *newSentence = [[Sentence alloc] init];
            newSentence.Orig = currentText;
            [_word.SentenceList addObject:newSentence];
            
            [newSentence release];
        }
        else if ([currentPath isEqualToString:@"/dict/sent/pron"]) {

            Sentence *lastSentence = [_word.SentenceList lastObject];
            lastSentence.Pron = currentText;
        }
        else if ([currentPath isEqualToString:@"/dict/sent/trans"]) {

            Sentence *lastSentence = [_word.SentenceList lastObject];
            lastSentence.Trans = currentText;
        }
        else if ([currentPath isEqualToString:@"/string"]) {
            sentenceString = [NSString stringWithString:currentText];
        }
    }
    
    // If end of an item then tell delegate
    if ([currentPath isEqualToString:@"/dict"]) {
        
        // Dispatch Word to delegate
        if ([_delegate respondsToSelector:@selector(parser:didParseWord:)])
            [_delegate parser:self didParseWord:_word];
        
        DDLogVerbose(@"Parser: Word for \"%@\" successfully parsed", _word.Key);
    }
    else if ([currentPath isEqualToString:@"/string"]) {
        
        // Dispatch delegate
        if ([_delegate respondsToSelector:@selector(parser:didParseKeyValuePair:andValue:)])
            [_delegate parser:self didParseKeyValuePair:@"string" andValue:sentenceString];
    }
    
    // Adjust path
    self.currentPath = [currentPath stringByDeletingLastPathComponent];
    
    // Drain pool
    [pool drain];
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName
    forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue {
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    // Add characters
    [currentText appendString:string];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
    // Inform delegate
    if (!_canceled && [_delegate respondsToSelector:@selector(parserDidStart:)])
        [_delegate parserDidStart:self];
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {

    [self parsingFinished];
    
}

// Call if parsing error occured or parse was aborted
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
    DDLogError(@"NSXMLParser: parseErrorOccurred: %@", parseError);
    
    // Fail with error
    if (!aborted) {
        // This method is called when legimitaly aboring the parser so ignore if this is the case
        [self parsingFailedWithDescription:[parseError localizedDescription]];
    }
    
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
    DDLogError(@"NSXMLParser: validationErrorOccurred: %@", validError);
    
    // Fail with error
    [self parsingFailedWithDescription:[validError localizedDescription]];
    
}


@end
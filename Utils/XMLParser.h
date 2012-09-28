//
//  Parser.h
//  iKnow
//
//  Created by Cube on 11-4-23.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Word.h"
#import "Parser.h"


// Parser
@interface XMLParser : Parser <NSXMLParserDelegate> {
    
@private

    // Parsing
    NSXMLParser *xmlParser;
    
    // Parsing of XML structure as content
    NSString *pathOfElement; // Hold the path of the element
    
    // Parsing Data
    NSString *currentPath;
    NSMutableString *currentText;
    NSMutableString *temporaryText;
    NSDictionary *currentElementAttributes;
    
    Word *_word;
}

@property (nonatomic, retain) NSXMLParser *xmlParser;
@property (nonatomic, retain) NSString *currentPath;
@property (nonatomic, retain) NSMutableString *currentText;
@property (nonatomic, retain) NSMutableString *temporaryText;
@property (nonatomic, retain) NSDictionary *currentElementAttributes;
@property (nonatomic, retain) Word *word;
@property (nonatomic, retain) NSString *pathOfElement;

@end

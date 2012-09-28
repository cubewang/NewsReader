//
//  HTMLBuilder.m
//  iKnow
//
//  Created by curer on 11-10-24.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "HTMLBuilder.h"


@implementation HTMLBuilder


+ (NSString *)CreateHTMLWithText:(NSString *)text
{
    if ([text length] == 0) {
        return nil;
    }
    
    NSMutableString *htmlString = [[NSMutableString alloc] initWithCapacity:100];
    [htmlString appendFormat:@"<html><body>"];
    
    int j = 0;
    for (int i = 0; i < [text length]; i++)
    {
        unichar c = [text characterAtIndex:i];
        if (c == '\n' && i != j) {
            NSRange range;
            range.location = j;
            range.length = i - j;
            j = i;
            
            [htmlString appendFormat:@"<p>%@</p>", 
                 [text substringWithRange:range]];
        }
    }
    
    NSRange range;
    range.location = j;
    range.length = [text length] - j;
    [htmlString appendFormat:@"<p>%@</p>", 
         [text substringWithRange:range]];
    
    [htmlString appendFormat:@"</body></html>"];
    
    return [htmlString autorelease];
}

+ (NSString *)CreateHTMLWithText:(NSString *)text 
              imageServerPath:(NSString *)imageServerPath
                           width:(int)width 
                          height:(int)height
{
    if ([imageServerPath length] == 0 ) 
    {
        return nil;
    }
    
    NSMutableString *htmlString = [[NSMutableString alloc] initWithCapacity:100];
    [htmlString appendFormat:@"<html><body>"];
    [htmlString appendFormat:@"<p><img src='..%@' width='%d' height='%d'></img></p>", 
                    imageServerPath, width, height];
    if ([text length]) 
    {
        int j = 0;
        for (int i = 0; i < [text length]; i++)
        {
            unichar c = [text characterAtIndex:i];
            if (c == '\n' && i != j) {
                NSRange range;
                range.location = j;
                range.length = i - j;
                j = i;
            
                [htmlString appendFormat:@"<p>%@</p>", 
                     [text substringWithRange:range]];
            }
        }
    
        NSRange range;
        range.location = j;
        range.length = [text length] - j;
        [htmlString appendFormat:@"<p>%@</p>", 
             [text substringWithRange:range]];
    }
    
    [htmlString appendFormat:@"</body></html>"];
    
    return [htmlString autorelease];
}

@end

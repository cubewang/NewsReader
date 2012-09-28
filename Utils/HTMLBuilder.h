//
//  HTMLBuilder.h
//  iKnow
//
//  Created by curer on 11-10-24.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTMLBuilder : NSObject {
    
}

+ (NSString *)CreateHTMLWithText:(NSString *)text;
+ (NSString *)CreateHTMLWithText:(NSString *)text 
              imageServerPath:(NSString *)imageServerPath
                           width:(int)width 
                          height:(int)height;


@end

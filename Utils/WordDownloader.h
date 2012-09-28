//
//  WordDownloader.h
//  iKnow_iPad
//
//  Created by curer yg on 12-3-3.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Parser;
@class ParserDelegate;
@class Word;

@interface WordDownloader : NSObject
<ParserDelegate>
{
    id delegate;

    NSMutableArray *parseList;
    
    Word *word;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSMutableArray *parseList;
@property (nonatomic, retain) Word *word;

- (void)downloadWord:(NSString *)word;
- (void)cancel;

@end

@protocol WordDownloadDelegate <NSObject>

- (void)wordDownloadFinished:(Word *)word;
- (void)wordDownloadError;

@end


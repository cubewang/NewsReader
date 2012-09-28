//
//  VisualDownloader.h
//  iKnow
//
//  Created by Sdhjt on 11-5-12.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VisualDownloader;

@protocol VisualDownloaderDelegate <NSObject>
- (void) visualDownloaderDidFinish:(NSString *)fileName 
                          download:(VisualDownloader *)downloader;
- (void) visualDownloaderDidFail: (NSString *) reason;
- (void) visualDownloaderCancel;
@end

@interface VisualDownloader : NSObject {
    
@private
    id <VisualDownloaderDelegate> _delegate;
    
    NSString    *_title;
    NSURL       *_fileURL;
    NSString    *_fileName;

    NSUInteger _currentSize;
    NSNumber *_totalFileSize;
    
    UIProgressView *_progressView;
    UIAlertView *_progressAlertView;
    
    NSURLConnection *_urlConnection;
    
    int tag;
}

@property (nonatomic, assign) id <VisualDownloaderDelegate> delegate;
@property (nonatomic, retain) NSString   *title;
@property (nonatomic, retain) NSURL      *fileURL;
@property (nonatomic, retain) NSString   *fileName;
@property (nonatomic, assign) NSUInteger currentSize;
@property (nonatomic, retain) NSNumber   *totalFileSize;
@property (nonatomic, retain) UIProgressView  *progressView;
@property (nonatomic, retain) UIAlertView     *progressAlertView;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, assign) int tag;


- (void)start;
- (void)close;
- (void)createProgressAlertWithMessage:(NSString *)message;

- (void)writeToFile:(NSData *)data;
- (UILabel *)label;

@end




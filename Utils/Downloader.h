//
//  Client.h
//  iKnow
//
//  Created by Cube on 11-4-23.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"


typedef enum { 
    DownloaderTypeUnknown, 
    DownloaderTypeData, 
    DownloaderTypeImage, 
    DownloaderTypeAudio, 
    DownloaderTypeVideo, 
    DownloaderTypeFile 
} DownloaderType;


// Types
typedef enum { 
    ConnectionTypeAsynchronously, 
    ConnectionTypeSynchronously 
} ConnectionType;


// Class
@class Downloader;

// Delegate
@protocol DownloaderDelegate <NSObject>
@optional
- (void)downloaderDidStart:(Downloader *)downloader;
- (void)downloader:(Downloader *)downloader didDownloadImage:(UIImage *)image;
- (void)downloader:(Downloader *)downloader didDownloadData:(NSMutableData *)data;
- (void)downloader:(Downloader *)downloader didDownloadFile:(NSString *)path;
- (void)downloader:(Downloader *)downloader didFailWithError:(NSString *)error;
@end



@interface Downloader : NSObject<ASIHTTPRequestDelegate> {

    NSString *_url;
    NSDictionary *_postDictionary;
    NSMutableData   * _asyncData;
    NSString *_filePath;
    NSOutputStream * _fileStream;
    BOOL _canceled;
    BOOL _useCacheFirst;
    
    id <DownloaderDelegate> _delegate;
    
    ConnectionType _connectionType;
    DownloaderType downloaderType;
    
    ASIHTTPRequest *asiRequest;
}

@property (nonatomic) DownloaderType downloaderType;
@property (nonatomic, retain) ASIHTTPRequest *asiRequest;
@property (nonatomic, retain) NSDictionary *postDictionary;
@property (nonatomic, assign) BOOL useCacheFirst;

// Init Downloader with a Url string, and have no post dictionary
- (id)initWithString:(NSString *)Url
            delegate:(id<DownloaderDelegate>)delegate
      connectionType:(ConnectionType)cType
      downloaderType:(DownloaderType)dType;

// Init Downloader with a Url string
- (id)initWithString:(NSString *)Url
            delegate:(id<DownloaderDelegate>)delegate
      postDictionary:(NSDictionary*)dictionary
      connectionType:(ConnectionType)cType
      downloaderType:(DownloaderType)dType;

// Begin downloading
- (void)download;
- (void)cancel;

// Stop downloading
- (void)stopDownloading;

// Returns the URL
- (NSString *)url;

@end

//
//  Client.m
//  iKnow
//
//  Created by Cube on 11-4-23.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "Downloader.h"
#import "ASIDownloadCache.h"


static const int ddLogLevel = LOG_FLAG_ERROR;

@interface Downloader ()

// Properties that don't need to be seen by the outside world.

@property (nonatomic, copy)     NSString *url;
@property (nonatomic, retain)   NSMutableData   * asyncData;
@property (nonatomic, copy)     NSString *        filePath;
@property (nonatomic, retain)   NSOutputStream *  fileStream;

@end


@implementation Downloader

@synthesize downloaderType;
@synthesize url            = _url;
@synthesize postDictionary = _postDictionary;
@synthesize asyncData      = _asyncData;
@synthesize filePath       = _filePath;
@synthesize fileStream     = _fileStream;
@synthesize asiRequest;
@synthesize useCacheFirst  = _useCacheFirst;


#pragma mark -
#pragma mark NSObject

- (id)init {
    if (self = [super init]) {
        downloaderType = DownloaderTypeUnknown;
        _canceled = FALSE;
        _useCacheFirst = YES;
    }
    
    return self;
}


- (id)initWithString:(NSString *)Url
            delegate:(id<DownloaderDelegate>)delegate
      connectionType:(ConnectionType)cType
      downloaderType:(DownloaderType)dType
{
    return [self initWithString:Url
                       delegate:delegate
                 postDictionary:nil
                 connectionType:cType
                 downloaderType:dType];
}


// Initialise with a URL
- (id)initWithString:(NSString *)Url
         delegate:(id<ParserDelegate>)delegate
      postDictionary:(NSDictionary*)dictionary
      connectionType:(ConnectionType)cType 
      downloaderType:(DownloaderType)dType
{
    if (delegate == nil)
        return nil;
    
    self.postDictionary = dictionary;
    
    if (cType != ConnectionTypeSynchronously && cType != ConnectionTypeAsynchronously)
        return nil;
    
    if (self = [self init]) {
        
        // Remember url
        self.url = Url;
        _delegate = delegate;
        _connectionType = cType;
        downloaderType = dType;
    }
    
    return self;
}

- (void)dealloc
{
    [self _stopReceiveWithStatus:@"Stopped"];
    RELEASE_SAFELY(_url);
    RELEASE_SAFELY(_asyncData);
    RELEASE_SAFELY(_postDictionary);
    
    if (asiRequest) {
        [asiRequest clearDelegatesAndCancel];
        RELEASE_SAFELY(asiRequest);
    }
    
    [super dealloc];
}

- (void)cancel
{
    _canceled = TRUE;
    if (asiRequest) {
        [asiRequest clearDelegatesAndCancel];
        RELEASE_SAFELY(asiRequest);
    }
    
    _delegate = nil;
}

// Begin to download
- (void)download 
{
    if (!_canceled)
        [self _startReceive];
}

// Stop downloading
- (void)stopDownloading
{
    [self _stopReceiveWithStatus:@"Cancelled"];
}

- (void)_startReceive
// Starts a connection to download the current URL.
{
    BOOL                success;
    
    // First get and check the URL.
    success = (self.url != nil);
    
    if (!success)
    {
        DDLogError(@"Downloader: Invalid URL");
        return;
    } 
    
    NSMutableString *requestedUrl = [[NSMutableString alloc] initWithString:self.url];

    //如果优先使用本地数据
    ASICachePolicy policy = _useCacheFirst ? ASIOnlyLoadIfNotCachedCachePolicy 
        : (ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy);
    
    //如果Post字典不为空，添加到asiRequest中
    if (_postDictionary) {
        NSArray *keys = [_postDictionary allKeys];
        
        for (int i = 0; i < [keys count]; i++) {
            NSString *key = [keys objectAtIndex:i];
            NSString *value = [_postDictionary objectForKey:key];
            
            if ([key length] == 0 || [value length] == 0) {
                continue;
            }
            
            [requestedUrl appendString:i==0 ? @"?" : @"&"];
            [requestedUrl appendFormat:@"%@=%@", key, value];
        }
    }

    self.asiRequest = [ASIHTTPRequest requestWithURL:
                       [NSURL URLWithString:[requestedUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    [asiRequest setDownloadCache:[ASIDownloadCache sharedCache]];
    [asiRequest setCachePolicy:policy];
    [asiRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
    if (downloaderType != DownloaderTypeData) {

        self.filePath = [[EnglishFunAppDelegate sharedAppDelegate] pathForTemporaryFileWithPrefix:@"iKnow"];
        [asiRequest setDownloadDestinationPath:self.filePath];
        
        [asiRequest setTemporaryFileDownloadPath:[NSString stringWithFormat:@"%@.download", self.filePath]];
    }
    
    // Connection
    if (_connectionType == ConnectionTypeAsynchronously) {
        
        [asiRequest setDelegate:self];
        [asiRequest startAsynchronous];
        
        // Tell we're receiving.
        if (!_canceled && [_delegate respondsToSelector:@selector(downloaderDidStart:)])
            [_delegate downloaderDidStart:self];
    }
    else 
    {
        [asiRequest startSynchronous];
        
        NSError *error = [asiRequest error];
        
        if (!error) 
        {
            [self requestFinished:asiRequest];
        }
        else 
        {
            [self requestFailed:asiRequest];
        }
    }
    
    [requestedUrl release];
}

- (void)_informDelegate:(NSString *)statusString
{
    if (statusString == nil || [statusString isEqualToString:@"Use Cached Response"]) 
    {
        if (downloaderType == DownloaderTypeImage) {

            if (!_canceled && [_delegate respondsToSelector:@selector(downloader:didDownloadImage:)])
                [_delegate downloader:self didDownloadImage:[UIImage imageWithContentsOfFile:self.filePath]];
        }
        else if (downloaderType == DownloaderTypeFile) {

            if (!_canceled && [_delegate respondsToSelector:@selector(downloader:didDownloadFile:)])
                [_delegate downloader:self didDownloadFile:self.filePath];
        }
        else if (downloaderType == DownloaderTypeData) {

            if (!_canceled && [_delegate respondsToSelector:@selector(downloader:didDownloadData:)])
                [_delegate downloader:self didDownloadData:[[_asyncData retain] autorelease]];
        }
        
        if (statusString == nil)
        {
            statusString = @"GET/POST succeeded";
        }
        else
        {
            // Inform delegate
            if (!_useCacheFirst && !_canceled && [_delegate respondsToSelector:@selector(downloader:didFailWithError:)])
                [_delegate downloader:self didFailWithError:@"Use Cached Response"];
        }
    }
    
    DDLogInfo(@"Downloader: %@", statusString);
}

- (void)_stopReceiveWithStatus:(NSString *)statusString
{
    
    if (self.fileStream != nil) 
    {
        [self.fileStream close];
        self.fileStream = nil;
    }
    
    [self _informDelegate:statusString];
    
    self.filePath = nil;
    self.asyncData = nil;
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    
    if ([request didUseCachedResponse]) 
    {
        NSString *filePath = [[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:request];
        self.asyncData = [request responseData];
        self.filePath = filePath;
        
        [self _stopReceiveWithStatus:@"Use Cached Response"];
    }
    else 
    {
       self.asyncData = [request responseData];
        
        [self _stopReceiveWithStatus:nil];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    [self _stopReceiveWithStatus:@"Connection failed"];
    
    // Inform delegate
    if (!_canceled && [_delegate respondsToSelector:@selector(downloader:didFailWithError:)])
        [_delegate downloader:self didFailWithError:[error description]];
}

@end

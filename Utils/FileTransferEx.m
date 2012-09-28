//
//  FileTransForEx.m
//  iKnow
//
//  Created by curer on 11-9-20.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "FileTransFerEx.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "iKnowXMPPClient.h"
#import "NSObject+ZResult.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_ERROR;


@implementation NSString (CookieValueEncodingAdditions)

- (NSString *)decodedCookieValue
{
	NSMutableString *s = [NSMutableString stringWithString:[self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	//Also swap plus signs for spaces
	[s replaceOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [s length])];
	return [NSString stringWithString:s];
}

- (NSString *)encodedCookieValue
{
	return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end


@implementation FileTransferEx

@synthesize delegate;

+ (NSString *)GetUUID 
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}

- (BOOL)downloadFile:(NSString *)fileName
             andType:(FileTransferType)type
     andProgressView:(id)progressView
           andUserID:(NSString *)userID
         andUserInfo:(NSDictionary *)userInfo
{
    if ([fileName length] == 0 || [userID length] == 0) {
        return NO;
    }
    
    NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@%@%@/%@", 
                        MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, DOWNLOAD_MSG_RESOURCE_PATH, fileName];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [urlStr release];
    
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
    [request setUseCookiePersistence:YES];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
    NSString *downFilePath; 
    
    if (type == FileTransferTypeImage) {
        downFilePath = [EnglishFunAppDelegate getImagePathInDocument];
        downFilePath = [downFilePath stringByAppendingPathComponent:fileName];
    }
    else {
        downFilePath = [EnglishFunAppDelegate getAudoPathInDocument];
        downFilePath = [downFilePath stringByAppendingPathComponent:fileName];
    }

    [request setDownloadDestinationPath:downFilePath];
    [request setTemporaryFileDownloadPath:[NSString stringWithFormat:@"%@.download", downFilePath]];
    [request setDelegate:self];
    [request setDownloadProgressDelegate:progressView];
    [request setShowAccurateProgress:YES];
    
    if (userInfo) {
        request.userInfo = userInfo;
    }
    
    [progressView setProgress:0];
    [request startSynchronous];
    
    return YES;
}

- (BOOL)uploadFile:(NSString *)filePath
           andType:(FileTransferType)type 
   andProgressView:(id)progressView
         andUserID:(NSString *)userID
       andUserInfo:(NSDictionary *)userInfo 
{
    if ([filePath length] == 0 || [userID length] == 0) {
        return NO;
    }
    
    NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                        MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, FILE_PATH, UPLOAD_MSG_RESOURCE_PATH];
    
    DDLogInfo(@"upload filePath = %@, userID = %@", filePath, userID);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.userInfo = userInfo;
    
    [urlStr release];
    
    [request addFile:filePath 
        withFileName:@"iknow.jpeg" 
      andContentType:@"image/jpeg" 
              forKey:@"file"];

    [request setUploadProgressDelegate:progressView];
    [request setShowAccurateProgress:YES];
    [request setDelegate:self];
    
    [progressView setProgress:0];
   
    [request setUseCookiePersistence:YES];
    
    
    [request setRequestCookies:[ASIHTTPRequest sessionCookies]];
    NSArray *cookies = [request requestCookies];
    
    if (cookies == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error" 
                                                            message:@"http no cookie"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"ok" 
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        return NO;
    }
    
    
    [request startAsynchronous];
    
    return YES;
}

+ (NSString *)uploadFileSyncAndGetResourcePath:(NSString *)filePath
                                       andType:(FileTransferType)type
{
    if ([filePath length] == 0) {
        return nil;
    }
    
    NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                        MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, FILE_PATH, UPLOAD_MSG_RESOURCE_PATH];
    
    DDLogInfo(@"upload filePath = %@", filePath);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setUseCookiePersistence:YES];
    
    [request setRequestCookies:[ASIHTTPRequest sessionCookies]];
    NSArray *cookies = [request requestCookies];
    
    if (cookies == nil) {
#ifdef DEBUG
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error" 
                                                            message:@"http no cookie"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"ok" 
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
#endif 
        return nil;
    }
    
    [request addFile:filePath 
        withFileName:@"iknow.jpeg" 
      andContentType:@"image/jpeg" 
              forKey:@"file"];
    
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (error) {
        DDLogError(@"upload failed");
        return nil;
    }

    if (![[request responseString] ZResultSuccess]) 
    {
        DDLogError(@"upload failed %@", [request responseString]);
        return nil;
    }
    
    NSDictionary *dic = [[request responseString] JSONValue];
    //获得服务器返回的path
    NSString *serverPath = [dic objectForKey:@"path"];
    return serverPath;
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request{
    
    //TODO 检查返回
    NSString *response = [request responseString];
    DDLogInfo(@"%@", response);
    
    if ([response ZResultSuccess]) 
    {
        NSString *fileName = [request downloadDestinationPath];
        
        if (fileName) 
        {
            if ([delegate respondsToSelector:@selector(fileTransferDidDownLoad:)]) 
            {
                [delegate fileTransferDidDownLoad:request];
            }
        }
        else {
            if ([delegate respondsToSelector:@selector(fileTransferDidUpLoad:)]) {
                [delegate fileTransferDidUpLoad:request];
            }
        }
    }
    else 
    {
        if ([delegate respondsToSelector:@selector(fileTransferDidError:)]) 
        {
            [delegate fileTransferDidError:request];
        } 
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    
    DDLogError(@"%@: %@: error error = %@", 
               THIS_FILE, THIS_METHOD, request.error);
    
    if ([delegate respondsToSelector:@selector(fileTransferDidError:)]) 
    {
        [delegate fileTransferDidError:request];
    }
}

@end

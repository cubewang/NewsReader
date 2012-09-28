//
//  LocalSubstitutionCache.m
//  iKnow
//
//  Created by Cube on 12-13-20.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "LocalSubstitutionCache.h"

@implementation LocalSubstitutionCache

+ (NSString *)pathForURL:(NSString*)url
{
    NSString* localFilePath = [LocalSubstitutionCache getFileSuffix:url];
    localFilePath = [NSString stringWithFormat:@"%@%@", [StringUtils md5:url], localFilePath];
    localFilePath = [IMAGE_CACHE_FOLDER stringByAppendingPathComponent:localFilePath]; 
    
    return localFilePath;
}

- (NSString *)substitutionPath:(NSString *)path
{
    NSString* localFilePath = [LocalSubstitutionCache getFileSuffix:path];
    
    localFilePath = [NSString stringWithFormat:@"%@%@", [StringUtils md5:path], localFilePath];
    
    localFilePath = [IMAGE_CACHE_FOLDER stringByAppendingPathComponent:localFilePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:localFilePath])
        return localFilePath;
    
    return nil;
}

- (NSString *)mimeTypeForPath:(NSString *)originalPath
{
    return @"image/jpg";    
}

-(void)writeToFile:(NSData *)data filePath:(NSString *)filePath
{
    //NSAssert(![[NSFileManager defaultManager] fileExistsAtPath:filePath], @"cached file already exists");
    
    //如果文件已存在，不做如何处理
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return;

    if (![[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil])
    {
        NSLog(@"Error was code: %d - message: %s", errno, strerror(errno));
    }

}

- (BOOL)willCacheFile:(NSString*)filePath
{
    if ([[filePath lowercaseString] hasSuffix:@".png"] ||
        [[filePath lowercaseString] hasSuffix:@".jpg"] ||
        [[filePath lowercaseString] hasSuffix:@".gif"] ||
        [[filePath lowercaseString] hasSuffix:@".jpeg"])
        return YES;
    
    return NO;
}

+ (NSString*)getFileSuffix:(NSString*)filePath
{
    if ([[filePath lowercaseString] hasSuffix:@".jpg"])
        return @".jpg";
    
    if ([[filePath lowercaseString] hasSuffix:@".png"])
        return @".png";
    
    if ([[filePath lowercaseString] hasSuffix:@".gif"])
        return @".gif";
    
     if ([[filePath lowercaseString] hasSuffix:@".jpeg"])
        return @".jpeg";
    
    return @"";
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    if ([cachedResponse.data length] == 0)
        return;
    
    if (![self willCacheFile:request.URL.absoluteString])
        return;
    
    NSString* localFilePath = [LocalSubstitutionCache pathForURL:request.URL.absoluteString];
    
    
    //cache文件到本地
    [self writeToFile:cachedResponse.data filePath:localFilePath];
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    //
    // Get the path for the request
    //
    NSString *pathString = [[request URL] absoluteString];
    
    //
    // See if we have a substitution file for this path
    //
    NSString *substitutionFilePath = [self substitutionPath:pathString];
    if (!substitutionFilePath)
    {
        //
        // No substitution file, return the default cache response
        //
        return [super cachedResponseForRequest:request];
    }
    
    //
    // If we've already created a cache entry for this path, then return it.
    //
    NSCachedURLResponse *cachedResponse = [cachedResponses objectForKey:pathString];
    if (cachedResponse)
    {
        return cachedResponse;
    }
    
    //
    // Get the path to the substitution file
    //
    //NSString *substitutionFilePath =
    //    [[NSBundle mainBundle]
    //        pathForResource:[substitutionFileName stringByDeletingPathExtension]
    //        ofType:[substitutionFileName pathExtension]];
    //NSAssert(substitutionFilePath, @"File %@ in substitutionPaths didn't exist", substitutionFileName);
    
    //
    // Load the data
    //
    NSData *data = [NSData dataWithContentsOfFile:substitutionFilePath];
    
    //
    // Create the cacheable response
    //
    NSURLResponse *response = [[[NSURLResponse alloc] initWithURL:[request URL]
                                                         MIMEType:[self mimeTypeForPath:pathString]
                                            expectedContentLength:[data length]
                                                 textEncodingName:nil] autorelease];
    
    cachedResponse = [[[NSCachedURLResponse alloc] initWithResponse:response data:data] autorelease];
    
    //
    // Add it to our cache dictionary
    //
    if (!cachedResponses)
    {
        cachedResponses = [[NSMutableDictionary alloc] init];
    }
    [cachedResponses setObject:cachedResponse forKey:pathString];
    
    return cachedResponse;
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    //
    // Get the path for the request
    //
    NSString *pathString = [[request URL] path];
    if ([cachedResponses objectForKey:pathString])
    {
        [cachedResponses removeObjectForKey:pathString];
    }
    else
    {
        [super removeCachedResponseForRequest:request];
    }
}

- (void)dealloc
{
    [cachedResponses release];
    cachedResponses = nil;
    [super dealloc];
}

@end

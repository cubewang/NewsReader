//
//  FileTransForEx.h
//  iKnow
//
//  Created by curer on 11-9-20.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIHTTPRequest;

typedef enum { 
    FileTransferTypeText = 0,
    FileTransferTypeImage = 1,
    FileTransferTypeAudio = 2
} FileTransferType;


@interface FileTransferEx : NSObject {
    id delegate;
}

@property(nonatomic, assign) id delegate; 

+ (NSString *)GetUUID;

+ (NSString *)uploadFileSyncAndGetResourcePath:(NSString *)filePath
                                       andType:(FileTransferType)type;

- (BOOL)downloadFile:(NSString *)fileName
             andType:(FileTransferType)type
     andProgressView:(id)progressView
           andUserID:(NSString *)userID
         andUserInfo:(NSDictionary *)userInfo;

- (BOOL)uploadFile:(NSString *)filePath
           andType:(FileTransferType)type 
   andProgressView:(id)progressView
         andUserID:(NSString *)userID
       andUserInfo:(NSDictionary *)userInfo;

@end

@protocol FileTransferDelegate

- (void)fileTransferDidDownLoad:(ASIHTTPRequest *)request;
- (void)fileTransferDidUpLoad:(ASIHTTPRequest *)request;
- (void)fileTransferDidError:(ASIHTTPRequest *)request;

@optional
 
@end

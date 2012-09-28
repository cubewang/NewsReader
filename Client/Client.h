//
//  Client.h
//  iKnow
//
//  Created by Cube on 11-5-2.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#define IKNOW_WILL_REGISTER_TEXT                NSLocalizedString(@"注册中...", @"")

#define IKNOW_REGISTER_FAILED_TEXT              NSLocalizedString(@"注册失败", @"")
#define IKNOW_REGISTER_FAILED_BY_EMAIL          NSLocalizedString(@"该邮箱已注册", @"")

#define IKNOW_WILL_LOGIN_TEXT                   NSLocalizedString(@"登录中...", @"")
#define IKNOW_LOGIN_FAILED_BY_EMAIL_OR_PASSEORD NSLocalizedString(@"登录失败", @"")

#define IKNOW_XMPP_WAIT                         NSLocalizedString(@"请稍候...", @"")

//xmpp
#define IKNOW_XMPP_REGISTER_FAILED_TEXT         NSLocalizedString(@"注册失败", @"")
#define IKNOW_XMPP_REGISTER_SUCCESSED_TEXT      @""

#define IKNOW_XMPP_MESSAGE_SEND_FAILED_TEXT     NSLocalizedString(@"消息发送失败", @"")
#define IKNOW_XMPP_MESSAGE_SEND_SUCCESSED_TEXT  @""
#define IKNOW_XMPP_MESSAGE_WILL_SEND_TEXT       NSLocalizedString(@"消息发送中", @"")

#define DEFAULT_NAME NSLocalizedString(@"匿名", @"")
#define DEFAULT_MSG_NAME DEFAULT_NAME


#define DOCUMENT_FOLDER	   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define AUDIO_CACHE_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/ASIHTTPRequestCache/PermanentStore"]
#define IMAGE_CACHE_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/ASIHTTPRequestCache/PermanentStore"]

#define TRANSLATOR_CACHE  [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/ASIHTTPRequestCache/PermanentStore/Translator"]

#define UPLOAD_MSG_RESOURCE_PATH    @"upload.do"  
#define DOWNLOAD_MSG_RESOURCE_PATH      @"/iks/" 

#define DOWNLOAD_RESOURCE_PATH          @"/iks" 

#define FILE_PATH             MAIN_PATH_U


#define DEFAULT_LONGITUDE 116.414507
#define DEFAULT_LATITUDE 40.041869
#define DEFAULT_DELTA 5.0


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"


@interface Client : NSObject {
    CLLocation *userLocation;
    
    NSManagedObjectContext *context;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) CLLocation *userLocation;
@property (nonatomic, retain) MBProgressHUD *HUD;

+ (BOOL)userHasRegistered;

- (NSManagedObjectContext *)getContext;
- (void)showNetworkFailed:(UIView *)view;
- (void)showInformation:(UIView *)view info:(NSString *)info;
- (void)showPopProgress:(UIView *)view andText:(NSString *)text; 
- (void)hidePopProgress:(BOOL) bSuccess andText:(NSString *)text;
- (void)changePopProgress:(NSString *)text;

//分析POST格式键值对，以字典形式返回
+ (NSMutableDictionary *)analysePOSTData:(NSString *)data;

@end

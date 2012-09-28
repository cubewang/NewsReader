//
//  Client.m
//  iKnow
//
//  Created by Cube on 11-5-2.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "Client.h"

static const int ddLogLevel = LOG_FLAG_ERROR;


@implementation Client

@synthesize userLocation, HUD;

+ (BOOL)userHasRegistered
{
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), 
             @"Invoked on incorrect queue");

    return [[iKnowAPI getUserId] length] != 0;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    NSString *momPath = [[NSBundle mainBundle] pathForResource:@"iKnow" ofType:@"momd"];
    NSURL *momUrl = [NSURL fileURLWithPath:momPath];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momUrl];
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/iKnowV2.sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    
    NSError *error;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
                                  initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                 configuration:nil 
                                                           URL:storeURL
                                                       options:options 
                                                         error:&error]) 
    {
        DDLogError(@"Error: %@ error code = %d", [error localizedDescription], error.code);
        DDLogError(@"unResolved error %@, %@", error, [error userInfo]);
    }
    
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)getContext
{
    //if (context == nil) {
    //   [self initCoreData];
    //}
    
    //return [context retain];
    
    if (context != nil) {
        return context;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:coordinator];
    }
    return context;
}

/* ###################
 工具方法
 ###################
 */
//分析POST格式键值对，以字典形式返回
+(NSDictionary *)analysePOSTData:(NSString *)data
{
    NSDictionary *rtn = [data JSONValue];
    
    return rtn;
}

- (void)showNetworkFailed:(UIView *)view {
    
    [self showInformation:view info:NSLocalizedString(@"网络连接失败，请检查网络...", @"")];
}

- (void)showInformation:(UIView *)view info:(NSString *)info {
    if (HUD) {
        [HUD removeFromSuperview];
        [HUD release];
        HUD = nil;
    }
    
    if (view == nil) {
        view = [[EnglishFunAppDelegate sharedAppDelegate] window];
    }
    
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:view];
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]] autorelease];
        
        // Set custom view mode
        HUD.mode = MBProgressHUDModeCustomView;
        //HUD.dimBackground = YES;
        
        HUD.labelText = info;
        HUD.labelFont = [UIFont systemFontOfSize:18];
    }
    
    if ([view isKindOfClass:[UIWindow class]]) {
        [view addSubview:HUD];    
    }
    else {
        [view.window addSubview:HUD];
    }
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:0.8];
}

- (void)showPopProgress:(UIView *)view andText:(NSString *)text {
    if (HUD) {
        [HUD removeFromSuperview];
        [HUD release];
        HUD = nil;
    }
    
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:[EnglishFunAppDelegate sharedAppDelegate].window];
        HUD.mode = MBProgressHUDModeIndeterminate;
        
        HUD.labelText = text;
        HUD.labelFont = [UIFont systemFontOfSize:13];
    }
    
    [[EnglishFunAppDelegate sharedAppDelegate].window addSubview:HUD];
    
    [HUD show:YES];
}

- (void)changePopProgress:(NSString *)text
{
    HUD.labelText = text;
}

- (void)hidePopProgress:(BOOL) bSuccess andText:(NSString *)text {
    
    HUD.labelText = text;
    
    if (bSuccess) {
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
        HUD.mode = MBProgressHUDModeCustomView;
    }
    else {
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete.png"]] autorelease];
        HUD.mode = MBProgressHUDModeCustomView;
    }
    
    [HUD hide:YES afterDelay:0.8];
}

- (void)dealloc {
    
    [super dealloc];
    
    [context release];
    [userLocation release];
    [HUD release];
}

@end

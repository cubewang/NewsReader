//
//  ROWebDialogViewController.h
//  RenrenSDKDemo
//
//  Created by xiawh on 11-11-11.
//  Copyright (c) 2011年 renren－inc. All rights reserved.
//

#import "ROBaseDialogViewController.h"
#import "RORequest.h"
enum {
    RODialogOperateSuccess,
    RODialogOperateFailure,
    RODialogOperateCancel
};
typedef NSUInteger RODialogOperateType;     //Dialog操作类型

@protocol RODialogDelegate;

@interface ROWebDialogViewController : ROBaseDialogViewController <UIWebViewDelegate>{
    UIWebView *_webView;
    NSString *_serverURL;
    ROResponse* _response;
    NSMutableDictionary *_params;
    id<RODialogDelegate> _delegate;
    UIActivityIndicatorView *_indicatorView;
}
@property(nonatomic, assign)id<RODialogDelegate> delegate;
@property (nonatomic,retain)UIWebView *webView;
@property (nonatomic,retain)NSString *serverURL;
@property (nonatomic,retain)ROResponse *response;
@property (nonatomic,retain)NSMutableDictionary *params;
@property (nonatomic,retain)UIActivityIndicatorView *indicatorView;

@end

@protocol RODialogDelegate <NSObject>

@optional

- (void)authDialog:(id)dialog withOperateType:(RODialogOperateType )operateType;

- (void)widgetDialog:(id)dialog withOperateType:(RODialogOperateType )operateType;

@end
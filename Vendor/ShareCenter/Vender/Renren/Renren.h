//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "ROWebDialogViewController.h"
#import "ROResponse.h"
#import "RORequest.h"
#import "ROPasswordFlowRequestParam.h"
 
 
 
/**
 * For 3rd-party developers:
 * Please replace following strings with app id, api key and secret 
 * of your own application registeried on http://app.renren.com/developers
 * before any using of API methods.
 */


@protocol RenrenDelegate;
@protocol RORequestDelegate;
@protocol RODialogDelegate;
@protocol RenrenPayDelegate;

@class RORequest;
@class ROPublishPhotoRequestParam;
@class ROPasswordFlowRequestParam;
@class RenrenPay;

@interface Renren: NSObject <RODialogDelegate, RORequestDelegate> {
	NSString *_accessToken;
	NSString *_secret;
	NSString *_sessionKey;
	NSDate *_expirationDate;
	NSString *_createTime;
	RORequest *_request;
	NSString *_appId;
	NSString *_appKey;
	NSArray *_permissions;
	id <RenrenDelegate> _renrenDelegate;
}

@property(nonatomic, copy) NSString *accessToken;

@property(nonatomic, copy) NSString *secret;

@property(nonatomic, copy) NSString *sessionKey;

@property(nonatomic, copy) NSDate *expirationDate;

@property(nonatomic, copy) NSString *appKey;

@property(nonatomic, copy) NSString *appId;

@property(nonatomic, assign) id<RenrenDelegate> renrenDelegate;

@property(nonatomic, retain) NSArray *permissions;

@property(nonatomic, retain) RORequest *request;

-(void)saveUserSessionInfo;

#pragma mark - Initialization -

/*
 * 获取静态、共享的Renren实例对象。Renren类的单例方法。
 * @return 返回共享的Renren单例对象。
 */
+ (Renren *)sharedRenren;

/*
 * 获取新的Renren实例对象。Renren类的工厂方法。
 * 需要自行控制Renren对象的生命周期以保证调用的完成
 * @return 返回Renren类实例。
 */
+ (Renren *)newRenRen;

#pragma mark - General Public Methods -

/*
 * 判断用户登录后的当前会话生命周期是否有效。
 * @return 当前session有效,返回YES,否则, NO.
 */
-(BOOL)isSessionValid;

/*
 * 取得登录用户的userID
 */
- (void)getLoggedInUserId;

/*
 * 获得支付功能对象
 * @param secret APP的secret。
 * @param isUsed 是否使用本地存储。
 * @return 返回RenrenPay对象。
 */
-(RenrenPay *)getRenrenPayWithSecret:(NSString *)secret andLocalMem:(BOOL)isUsed;

/*
 * 提供给其他扩展功能使用，可以发出http请求，取得Json数据
 */
- (RORequest*)openUrl:(NSString *)url params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod delegate:(id<RORequestDelegate>)delegate;


#pragma mark - Authorize & Logout -

/**
 * 授权页面方式获取授权——弹层页面
 * @param permissions 需要开通的权限字符串数组。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
- (void)authorizationWithPermisson:(NSArray *)permissions andDelegate:(id<RenrenDelegate>)delegate;

/**
 * 授权页面方式获取授权——Navigation页面
 * @param permissions 需要开通的权限字符串数组。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
- (void)authorizationInNavigationWithPermisson:(NSArray *)permissions 
                       andDelegate:(id<RenrenDelegate>)delegate;

/**
 * 使用password flow方式获取授权
 * @param param 用户密码认证方式的ROPasswordFlowRequestParam对象
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
- (void)passwordFlowAuthorizationWithParam:(ROPasswordFlowRequestParam *)param andDelegate:(id<RenrenDelegate>)delegate;

/**
 * 用户登出时调用本方法。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
- (void)logout:(id<RenrenDelegate>)delegate;

#pragma mark - Customlized API Request Methods -

/*
 * 通过组装传入的params字典中包含的信息，向服务器对应接口发出请求。
 * @param param 包含接口请求参数的字典对象。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
- (RORequest *)requestWithParams:(NSMutableDictionary *)params andDelegate:(id <RenrenDelegate>)delegate;

/**
 * 调用指定的widget dialog.通过widget Dialog的方式使用SDK.——弹层页面
 * @param action 通过dialog调用的接口标记字符串。
 * @param params 接口调用参数字典对象。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
- (void)dialog:(NSString *)action andParams:(NSMutableDictionary *)params andDelegate:(id <RenrenDelegate>)delegate;

/**
 * 调用指定的widget dialog.通过widget Dialog的方式使用SDK.——Navigation页面
 * @param action 通过dialog调用的接口标记字符串。
 * @param params 接口调用参数字典对象。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
- (void)dialogInNavigation:(NSString *)action andParams:(NSMutableDictionary *)params andDelegate:(id <RenrenDelegate>)delegate;

#pragma mark - One-Click API Function Methods -

/**
 * 一键发布照片流程方法
 * @param image 准备上传图片对象
 * @param caption 照片的描述
 * @param url 图片链接
 @return 一键上传图片界面所用视图
 */
-(void)publishPhotoSimplyWithImage:(UIImage *)image caption:(NSString *)caption imageurl:(NSURL *)imageurl;
 #pragma mark - Packaged API Function Methods -

-(void)ShareToRenrenwithImage:(UIImage *)image Url:(NSURL *)url;
/**
 * 创建相册，返回新相册的相关信息
 * @param param包含接口参数所需数据成员的ROCreateAlbumRequestParam对象。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
//-(void)createAlbum:(ROCreateAlbumRequestParam *)param andDelegate:(id<RenrenDelegate>)delegate;

/**
 * 获取相册信息，可以返回全部相册列表，也可指定相册id
 * @param param包含接口参数所需数据成员的ROAlbumsInfoRequestParam对象。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
//-(void)getAlbums:(ROAlbumsInfoRequestParam *)param andDelegate:(id<RenrenDelegate>)delegate;

/**
 * 获取用户详细信息，可以指定多个用户id
 * @param param包含接口参数所需数据成员的ROUserInfoRequestParam对象。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
//-(void)getUsersInfo:(ROUserInfoRequestParam *)param andDelegate:(id<RenrenDelegate>)delegate;

/**
 * 上传照片，默认上传至“快速上传”相册。
 * @param param包含接口参数所需数据成员的ROPublishPhotoRequestParam对象。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
//-(void)publishPhoto:(ROPublishPhotoRequestParam *)param andDelegate:(id<RenrenDelegate>)delegate;

/**
 * 获取好友id列表
 * @param param包含接口参数所需数据成员的ROGetFriendsRequestParam对象。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
//-(void)getFriends:(ROGetFriendsRequestParam *)param andDelegate:(id<RenrenDelegate>)delegate;

/**
 * 获取好友详细信息
 * @param param包含接口参数所需数据成员的ROGetFriendsInfoRequestParam对象。
 * @param delegate 实现RenrenDelegate协议的类型对象。
 */
//-//(void)getFriendsInfo:(ROGetFriendsInfoRequestParam *)param andDelegate:(id<RenrenDelegate>)delegate;


@end

/**
 * Renren的代理协议，包含了各种接口回调方法。
 * 如需要接收接口返回数据或实现自定义错误处理过程，请实现此协议。
 */
@protocol RenrenDelegate <NSObject>

@optional

/**
 * 接口请求成功，第三方开发者实现这个方法
 * @param renren 传回代理服务器接口请求的Renren类型对象。
 * @param response 传回接口请求的响应。
 */
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response;

/**
 * 接口请求失败，第三方开发者实现这个方法
 * @param renren 传回代理服务器接口请求的Renren类型对象。
 * @param response 传回接口请求的错误对象。
 */
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error;

/**
 * renren取消Dialog时调用，第三方开发者实现这个方法
 * @param renren 传回代理授权登录接口请求的Renren类型对象。
 */
- (void)renrenDialogDidCancel:(Renren *)renren;
/**
 * 授权登录成功时被调用，第三方开发者实现这个方法
 * @param renren 传回代理授权登录接口请求的Renren类型对象。
 */
- (void)renrenDidLogin:(Renren *)renren;

/**
 * 用户登出成功后被调用 第三方开发者实现这个方法
 * @param renren 传回代理登出接口请求的Renren类型对象。
 */
- (void)renrenDidLogout:(Renren *)renren;

/**
 * 授权登录失败时被调用，第三方开发者实现这个方法
 * @param renren 传回代理授权登录接口请求的Renren类型对象。
 */
- (void)renren:(Renren *)renren loginFailWithError:(ROError*)error;

@end

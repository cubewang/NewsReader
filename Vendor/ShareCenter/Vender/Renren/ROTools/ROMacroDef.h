//
//  ROMacroDef.h
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-11-14.
//  Copyright (c) 2011年 renren－inc. All rights reserved.
//

//授权及api相关
#define kAuthBaseURL            @"http://graph.renren.com/oauth/authorize"
#define kDialogBaseURL          @"http://widget.renren.com/dialog/"
#define kRestserverBaseURL      @"http://api.renren.com/restserver.do"
#define kRRSessionKeyURL        @"http://graph.renren.com/renren_api/session_key"
#define kRRSuccessURL           @"http://widget.renren.com/callback.html"
#define kSDKversion             @"3.0"
#define kPasswordFlowBaseURL    @"https://graph.renren.com/oauth/token"

//支付相关
#define kPaySuccessURL      @"rrpay://success"
#define kPayFailURL         @"rrpay://error"
#define kRepairSuccessURL   @"rrpay://repairsuccess"
#define kRepairFailURL      @"rrpay://repairerror"
#define kDirectPayURL       @"http://mpay.renren.com/pay/main/ui/entry/deposit/payment.do"
#define kIPhonePaySDK       @"1"
#define kSubmitOrderURL     @"https://graph.renren.com/spay/iphone/test/submitOrder"
#define kFixOrderURL        @"https://graph.renren.com/spay/iphone/test/fixOrder"
#define kTestSubmitOrderURL     @"https://graph.renren.com/spay/iphone/test/submitOrder"
#define kTestFixOrderURL        @"https://graph.renren.com/spay/iphone/test/fixOrder"
#define kCheckAppStatusURL  @"https://graph.renren.com/spay/appStatus"
#define kIsTestOrder        @"true"
#define kIsNotTestOrder     @"false"
#define kPaySuccessCode     @"102"

//dialog相关
#define kWidgetURL @"http://widget.renren.com/callback.html"
#define kWidgetDialogURL @"//widget.renren.com/dialog"
#define kWidgetDialogUA @"18da8a1a68e2ee89805959b6c8441864"
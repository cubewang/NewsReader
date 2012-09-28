//
//  CURenrenShareClient.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-14.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUShareClient.h"
#import "Renren.h"

@interface CURenrenShareClient : CUShareClient
<CUShareClientData, RenrenDelegate>
{
    Renren *renren;
    /**************************************
     * Inherited from CUShareClient:
     * 
     * UIWebView *webView;
     * UINavigationBar	*navBar;
     * UIInterfaceOrientation orientation;
     * UIToolbar *pinCopyPromptBar;    
     * id<CUShareClientDelegate> delegate;
     ***************************************/
}

- (BOOL)sendWithDictionary:(NSMutableDictionary *)dic;

//CUShareClientData
- (BOOL)isCUAuth;
- (void)CULogout;

- (void)CUSendWithText:(NSString *)text;
- (void)CUSendWithText:(NSString *)text andImage:(UIImage *)image;

- (NSURLRequest *)CULoginURLRequest;

@end

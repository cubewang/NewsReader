//
//  CUTencentShareClient.h
//  ShareCenterExample
//
//  Created by curer yg on 12-3-16.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "CUShareClient.h"
#import "CUTencentEngine.h"

@interface CUTencentShareClient : CUShareClient
<CUShareClientData, CUTencentEngineDelegate>
{
    CUTencentEngine *engine;
    
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

@end

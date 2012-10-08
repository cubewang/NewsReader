//
//  iKnowError.h
//  iKnow
//
//  Created by curer on 11-10-7.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#define XMPP_iKNOW_ERROR_DOMIN @"iknow.xmpp"


//NSError code

typedef enum _XMPPiKnowErrorType {
    XMPPiKnowNetWorkError = 1,
    XMPPiKnowDefaultError          //可能服务器也可能是网络错误,反正就是没成功

} XMPPiKnowErrorType;

/*
typedef enum _ASINetworkErrorType {
    ASIConnectionFailureErrorType = 1,
    ASIRequestTimedOutErrorType = 2,
    ASIAuthenticationErrorType = 3,
    ASIRequestCancelledErrorType = 4,
    ASIUnableToCreateRequestErrorType = 5,
    ASIInternalErrorWhileBuildingRequestType  = 6,
    ASIInternalErrorWhileApplyingCredentialsType  = 7,
    ASIFileManagementError = 8,
    ASITooMuchRedirectionErrorType = 9,
    ASIUnhandledExceptionError = 10,
    ASICompressionError = 11
    
} ASINetworkErrorType;
*/
 
/*
NSString *errorMsg = nil;

if ([[error domain] isEqualToString:NSURLErrorDomain]) {
    switch ([error code]) {
        case NSURLErrorCannotFindHost:
            errorMsg = NSLocalizedString(@"Cannot find specified host. Retype URL.", nil);
            break;
        case NSURLErrorCannotConnectToHost:
            errorMsg = NSLocalizedString(@"Cannot connect to specified host. Server may be down.", nil);
            break;
        case NSURLErrorNotConnectedToInternet:
            errorMsg = NSLocalizedString(@"Cannot connect to the internet. Service may not be available.", nil);
            break;
        default:
            errorMsg = [error localizedDescription];
            break;
    }
} else {
    errorMsg = [error localizedDescription];
    }
*/
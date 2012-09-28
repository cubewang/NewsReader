//
//  XMPPiKnowUser.h
//  iKnow
//
//  Created by curer on 11-9-27.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XMPPiKnowUser : NSObject {
    //NSString *userName;//login
    NSString *password;//login
    
    // user info extern 
    NSString *displayName;
    NSString *email;
}

//@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;

@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *email;

@end

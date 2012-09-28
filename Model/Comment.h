//
//  Comment.h
//  iKnow
//
//  Created by Cube on 11-4-24.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Comment : NSObject {

    NSString *_MemberName;
    NSString *_UserId;     //iKnow Id，没有绑定Email的为空
    NSString *_Content;
    NSString *_PublishedDate;
    
    NSString *_avatarImagePath;
    
    BOOL _IsOfficialComment;
}

@property (nonatomic, copy) NSString *MemberName;
@property (nonatomic, copy) NSString *UserId;
@property (nonatomic, copy) NSString *Content;
@property (nonatomic, copy) NSString *PublishedDate;
@property (nonatomic, copy) NSString *avatarImagePath;

@property (nonatomic, assign) BOOL IsOfficialComment;

- (id)initWithJsonDictionary:(NSDictionary*)dictionary;


@end

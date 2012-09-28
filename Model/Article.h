//
//  Article.h
//  iKnow
//
//  Created by Cube on 11-4-23.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum { 
    ContentTypeText  = 0, 
    ContentTypeImage = 1, 
    ContentTypeAudio = 2, 
    ContentTypeVideo = 3, 
    ContentTypeOther = 4 
} ContentType;

@interface Article : NSObject {
    
    NSString *_Name;
    NSString *_Id;
    NSString *_UserId;
    NSString *_UserName;
    NSString *_ImageUrl;
    NSString *_SourceImageUrl;
    NSString *_CreateTime;
    NSString *_OpenCount;
    NSString *_FavoriteCount;
    NSString *_CommentCount;
    NSString *_Description;
    NSMutableArray *_Tags;
    NSString *_AvatarImageUrl;
    ContentType _Type;
    
    //performance need
    CGSize descriptionLabelSizeForPerformance;
}

@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *UserId;
@property (nonatomic, copy) NSString *UserName;
@property (nonatomic, copy) NSString *SourceImageUrl;
@property (nonatomic, copy) NSString *ImageUrl;
@property (nonatomic, copy) NSString *CreateTime;
@property (nonatomic, copy) NSString *OpenCount;
@property (nonatomic, copy) NSString *FavoriteCount;
@property (nonatomic, copy) NSString *CommentCount;
@property (nonatomic, copy) NSString *Description;
@property (nonatomic, retain) NSMutableArray *Tags;
@property (nonatomic, copy) NSString *AvatarImageUrl;
@property (nonatomic, assign) ContentType Type;

@property (nonatomic, assign)BOOL isFavorite;

@property (nonatomic, assign) CGSize descriptionLabelSizeForPerformance;

- (id)initWithJsonDictionary:(NSDictionary*)dictionary;

@end
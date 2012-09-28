//
//  Article.m
//  iKnow
//
//  Created by Cube on 11-4-23.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "Article.h"
#import "RTTableViewCell.h"
#import "FavoriteHelper.h"


@implementation Article

@synthesize Name        = _Name;
@synthesize Id          = _Id;
@synthesize UserId      = _UserId;
@synthesize UserName    = _UserName;
@synthesize ImageUrl    = _ImageUrl;
@synthesize SourceImageUrl = _SourceImageUrl;
@synthesize CreateTime  = _CreateTime;
@synthesize OpenCount   = _OpenCount;
@synthesize FavoriteCount = _FavoriteCount;
@synthesize CommentCount = _CommentCount;
@synthesize Description = _Description;
@synthesize Tags        = _Tags;
@synthesize AvatarImageUrl = _AvatarImageUrl;
@synthesize Type        = _Type;

@synthesize isFavorite;

@synthesize descriptionLabelSizeForPerformance;

- (void)updateWithJsonDictionary:(NSDictionary*)dictionary {

    [self reset];
    
    _Name = [[dictionary objectForKey:@"name"] retain];
    _Id = [[dictionary objectForKey:@"id"] retain];
    _UserId = [[dictionary objectForKey:@"user_id"] retain];
    _UserName = [[dictionary objectForKey:@"user_name"] retain];
    _ImageUrl = [[dictionary objectForKey:@"image_url"] copy];
    _CreateTime = [[dictionary objectForKey:@"create_time"] retain];
    _OpenCount = [[dictionary objectForKey:@"open_count"] retain];
    _FavoriteCount = [[dictionary objectForKey:@"favorite_count"] retain];
    _CommentCount = [[dictionary objectForKey:@"comment_count"] retain];
    _AvatarImageUrl = [[dictionary objectForKey:@"user_photo"] retain];
    
    //过滤文章简介中的"\r"和"\n"标签
    NSString *source = [NSString stringWithFormat:@"%@...", [dictionary objectForKey:@"des"]];
    _Description = [[[source stringByReplacingOccurrencesOfString:@"\r" withString:@""] 
                    stringByReplacingOccurrencesOfString:@"\n" withString:@""]
                    retain];
    
    //如果文章封面图片的路径是相对路径改为绝对路径
    if ([_ImageUrl hasPrefix:@"../"]) {
        NSRange range = {0};
        range.location = 2;
        range.length = [_ImageUrl length] - range.location;
        
        NSString *imageFullPath = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                              MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, DOWNLOAD_RESOURCE_PATH, [_ImageUrl substringWithRange:range]];
        
        [_ImageUrl release];
        _ImageUrl = imageFullPath;
        
        NSString *imageFullPath2 = [[NSString alloc] initWithFormat:@"%@%@%@%@", 
                                   MAIN_PROCOTOL, MAIN_HOST, DOWNLOAD_RESOURCE_PATH, [[dictionary objectForKey:@"image_url"] substringWithRange:range]];
        
        _SourceImageUrl = imageFullPath2;
    }
    else
    {
        _SourceImageUrl = [_ImageUrl copy];
    }
    
    //将作者头像的路径改为绝对路径
    if ([_AvatarImageUrl hasPrefix:@"../"]) {
        NSRange range = {0};
        range.location = 2;
        range.length = [_AvatarImageUrl length] - range.location;
        
        NSString *imageFullPath = [[NSString alloc] initWithFormat:@"%@%@%@%@%@", 
                              MAIN_PROCOTOL, MAIN_HOST, MAIN_PORT, DOWNLOAD_RESOURCE_PATH, [_AvatarImageUrl substringWithRange:range]];
        
        [_AvatarImageUrl release];
        _AvatarImageUrl = imageFullPath;
    }

    //取得文章的类型：文字、音频还是视频
    NSString *contentType = [dictionary objectForKey:@"type"];
    if ([contentType rangeOfString:@"video"].length > 0) {
        _Type = ContentTypeVideo;
    }
    else if ([contentType rangeOfString:@"audio"].length > 0) {
        _Type = ContentTypeAudio;
    }
    else {
        _Type = ContentTypeText;
    }
    
    //将标签字符串添加进Tags数组
    id tagObject = [dictionary objectForKey:@"tags"];
    if ([tagObject isKindOfClass:[NSArray class]])
    {
        NSArray *tagArray = (NSArray *)tagObject;
        if ([tagArray count] > 0)
        {
            self.Tags = [[[NSMutableArray alloc] init] autorelease];
            
            for (NSString *tag in tagArray) {
                [self.Tags addObject:[NSString stringWithString:tag]];
            }
        }
    }
    
    if ([[FavoriteHelper instance] isFavorite:_Id])
    {
        self.isFavorite = YES;
    }
    else
    {
        self.isFavorite = NO;
    }
}

- (id)initWithJsonDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        [self updateWithJsonDictionary:dictionary];
    }
    
    return self;
}

- (id)initWithFavorite:(NSManagedObject *)managedObject
{
    if (self = [super init]) {
        self.Name = [managedObject valueForKey:@"name"];
        self.Description = [managedObject valueForKey:@"articleDescription"];
        self.Type = (ContentType)[managedObject valueForKey:@"contentType"];
        self.ImageUrl = [managedObject valueForKey:@"imageUrl"];
        self.Id = [managedObject valueForKey:@"articleId"];
        self.Tags = [NSArray arrayWithObject:[managedObject valueForKey:@"contentTags"] ? [managedObject valueForKey:@"contentTags"] : IKNOW_TAG];
        self.CreateTime = [managedObject valueForKey:@"createDate"];
        self.OpenCount = [managedObject valueForKey:@"openCount"];
        self.isFavorite = YES;
    }
    
    return self;
}

- (void)reset {
    RELEASE_SAFELY(_Name);
    RELEASE_SAFELY(_Id);
    RELEASE_SAFELY(_UserId);
    RELEASE_SAFELY(_UserName)
    RELEASE_SAFELY(_ImageUrl);
    RELEASE_SAFELY(_SourceImageUrl);
    RELEASE_SAFELY(_CreateTime);
    RELEASE_SAFELY(_OpenCount);
    RELEASE_SAFELY(_FavoriteCount);
    RELEASE_SAFELY(_CommentCount);
    RELEASE_SAFELY(_AvatarImageUrl);
    RELEASE_SAFELY(_Description);
    RELEASE_SAFELY(_Tags);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"articleID = %@, ImageURL = %@", _Id, _ImageUrl];
}

- (void)dealloc {
    [self reset];
    [super dealloc];
}

@end
//
//  RTTableViewCell.h
//  iKnow
//
//  Abstract: 富文本单元格样式
//
//  Created by Cube on 11-5-5.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

#define TYPE_IMAGE_HEIGHT       16
#define TYPE_IMAGE_WIDTH        TYPE_IMAGE_HEIGHT

#define COVER_IMAGE_HEIGHT      168
#define COVER_IMAGE_WIDTH       308

#define COVER_BACKGROUND_HEIGHT 180
#define COVER_BACKGROUND_WIDTH  308

#define SUBTITLE_HEIGHT         40
#define FAVORITE_BUTTON_WIDTH   44

#define TAG_WIDTH               120
#define TAG_HEIGHT              TAG_WIDTH

#define CELL_CONTENT_WIDTH   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? SCREEN_WIDTH : ARTICLE_AREA_WIDTH_IPAD)


@interface RTTableViewCell : UITableViewCell 
{
    ContentType _type;
    
    UILabel *_nameLabel;
    UILabel *_descriptionLabel;
    UILabel *_openCountLabel;
    UILabel *_publishDateLabel;
    
    UIImageView *_typeImageView;
    
    UIImageView* _coverImageView;
    NSString *coverImageUrl;
    
    UIButton *_favoriteButton;
    
    UIImageView* _systemTagImageView;
    UIImageView* _seriesTagImageView;
    UIButton *_systemTagButton; //主标签，即系统标签
    UIButton *_seriesTagButton; //系列标签
    
    BOOL _bRead;
}

@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, readonly) UILabel *descriptionLabel;
@property (nonatomic, readonly) UILabel *openCountLabel;
@property (nonatomic, readonly) UILabel *publishDateLabel;

@property (nonatomic, readonly) UIImageView *typeImageView;

@property (nonatomic, readonly) UIImageView *coverImageView;

@property (nonatomic, readonly) UIButton *favoriteButton;

@property (nonatomic, readonly) UIImageView *seriesTagImageView;
@property (nonatomic, readonly) UIImageView *systemTagImageView;
@property (nonatomic, readonly) UIButton *systemTagButton;
@property (nonatomic, readonly) UIButton *seriesTagButton;

- (void)setDataSource:(id)data;
- (void)setFavorite:(BOOL)favorite tagId:(NSInteger)tagId target:(id)target action:(SEL)selector;
- (void)setArticleTags:(NSArray*)tags target:(id)target action:(SEL)selector;

- (void)setRead:(BOOL)read;

+ (CGFloat)rowHeightForObject:(id)object;

@end

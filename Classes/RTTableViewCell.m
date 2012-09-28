//
//  RTTableViewCell.m
//  iKnow
//
//  Created by Cube on 11-5-5.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "RTTableViewCell.h"
#import "UIImageView+WebCache.h"


@implementation RTTableViewCell


static UIImage* defaultCoverImage;
static UIImage* defaultBackgroundImage;
static UIImage* defaultTagBgImage;


@synthesize nameLabel = _nameLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize publishDateLabel = _publishDateLabel;
@synthesize typeImageView = _typeImageView;

@synthesize coverImageView = _coverImageView;
@synthesize systemTagImageView = _systemTagImageView;
@synthesize seriesTagImageView = _seriesTagImageView;
@synthesize systemTagButton = _systemTagButton;
@synthesize seriesTagButton = _seriesTagButton;

@synthesize openCountLabel = _openCountLabel;
@synthesize favoriteButton = _favoriteButton;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier]) {
        
        [self setBackgroundImage:nil];
	}
	
	return self;
}

static NSDateFormatter *s_format = nil;

- (void)setDataSource:(id)data
{
    if (data == nil) 
        return;
    
    Article *article = data;
    [self setBackgroundImage:nil];
    [self setName:article.Name];
    [self setDescription:article.Description];
    [self setOpenCount:article.OpenCount];
     
    if (s_format == nil) {
        s_format = [[NSDateFormatter alloc] init];
        [s_format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSDate *beforeData = [s_format dateFromString:article.CreateTime];
    if (beforeData) {
        [self setPublishDate:[StringUtils intervalSinceTime:beforeData 
                                                    andTime:[NSDate date]]];
    }
    else {
        [self setPublishDate:article.CreateTime];
    }

    [self setType:article.Type];
    [self setCoverImageUrl:article.ImageUrl];
}


- (void)setType:(ContentType)flag
{
    if (!_typeImageView) {
        _typeImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_typeImageView];
    }
    
    if (flag != _type)
    {
        _type = flag;
        
        if (_type == ContentTypeVideo) {
            UIImage *typeImage = [UIImage imageNamed:@"video.png"];
            _typeImageView.image = typeImage;
        }
        else if (_type == ContentTypeAudio) {
            _typeImageView.image = [UIImage imageNamed:@"audio.png"];
        }
        else
        {
            _typeImageView.image = nil;
        }
    }
}

+ (UIImage*)getDefaultCoverImage {
    
    if (defaultCoverImage == nil) {
        defaultCoverImage = [[UIImage imageNamed:@"DefaultCover.png"] retain];
    }
    
    return defaultCoverImage;
}


+ (UIImage*)getDefaultBackgroundImage {
    
    if (defaultBackgroundImage == nil) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"CellBackground" ofType:@"png"];
        defaultBackgroundImage = [[UIImage imageWithContentsOfFile:imagePath]
                                    stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
        [defaultBackgroundImage retain];
    }
    
    return defaultBackgroundImage;
}


+ (UIImage*)getDefaultTagBgImage {
    
    if (defaultTagBgImage == nil) {
        defaultTagBgImage = [[UIImage imageNamed:@"tagBg.png"] retain];
    }
    
    return defaultTagBgImage;
}

- (void)setCoverImageUrl:(NSString*)url
{
    if ([url length] == 0)
        return;

    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        
        _coverImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        _coverImageView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        _coverImageView.layer.shadowRadius = 1.5f;
        _coverImageView.layer.shadowOpacity = 0.5f;
        
        [self.contentView addSubview:_coverImageView];
        
        [_coverImageView release];
    }
    
    coverImageUrl = [url copy];
    
    [_coverImageView setImageWithURL:[NSURL URLWithString:url] 
                    placeholderImage:[RTTableViewCell getDefaultCoverImage]];
}

- (void)setDescription:(NSString *)newDescription
{
    if (!_descriptionLabel) {
		_descriptionLabel = [[UILabel alloc] init];
        if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ) {
            _descriptionLabel.font = English_font_des;
        } else {
            _descriptionLabel.font = English_font_des_iPad;
        }
		_descriptionLabel.textColor = ZBSTYLE_tableSubTextColor;
		_descriptionLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
		_descriptionLabel.textAlignment = UITextAlignmentLeft;
		_descriptionLabel.contentMode = UIViewContentModeTop;
		_descriptionLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_descriptionLabel.numberOfLines = 0;
		
		[self.contentView addSubview:_descriptionLabel];
	}
    
    _descriptionLabel.text = newDescription ? newDescription : @"";
}

- (void)setOpenCount:(NSString *)newCount
{
    if (!_openCountLabel) {
		_openCountLabel = [[UILabel alloc] init];
		_openCountLabel.font = ZBSTYLE_font;
		_openCountLabel.textColor = ZBSTYLE_tableSubTextColor;
		_openCountLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
		_openCountLabel.textAlignment = UITextAlignmentLeft;
		_openCountLabel.contentMode = UIViewContentModeTop;
		_openCountLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_openCountLabel.numberOfLines = 1;
		
		[self.contentView addSubview:_openCountLabel];
	}
    
    NSString *openCount = @"";
    
    if ([newCount length] > 0) {
        openCount = [NSString stringWithFormat:NSLocalizedString(@"阅读：%@", @""), newCount];
    }
    
    _openCountLabel.text = openCount;
}


- (void)setPublishDate:(NSString *)newDate
{
    if (!_publishDateLabel) {
        _publishDateLabel = [[UILabel alloc] init];
        _publishDateLabel.font = ZBSTYLE_font;
        _publishDateLabel.textColor = ZBSTYLE_tableSubTextColor;
        _publishDateLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
        _publishDateLabel.textAlignment = UITextAlignmentRight;
        _publishDateLabel.contentMode = UIViewContentModeTop;
        _publishDateLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _publishDateLabel.numberOfLines = 1;
        
        [self.contentView addSubview:_publishDateLabel];
    }
    
    NSString *createTime = @"";
    
    //去掉日期后面的时间
    if ([newDate length] > 0) {
        NSRange range = [newDate rangeOfString:@" "];
        if (range.location != NSNotFound) {
            range.length = range.location;
            range.location = 0;
            
            createTime = [newDate substringWithRange:range];
            _publishDateLabel.text = createTime;
        }
        else {
            _publishDateLabel.text = newDate;
        }
    }
    else {
        _publishDateLabel.text = @"";
    }

}


- (void)setName:(NSString *)newName
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ) {
            _nameLabel.font = English_font_title;
        } else {
            _nameLabel.font = English_font_title_iPad;
        }
        _nameLabel.textColor = ZBSTYLE_textColor;
        _nameLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
        _nameLabel.textAlignment = UITextAlignmentLeft;
        _nameLabel.contentMode = UIViewContentModeTop;
        _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _nameLabel.numberOfLines = 0;
        
        [self.contentView addSubview:_nameLabel];
    }
    
    _nameLabel.text = newName ? newName : NSLocalizedString(@"未命名", @"");
}

- (void)setFavorite:(BOOL)favorite tagId:(NSInteger)tagId target:(id)target action:(SEL)selector
{ 
    if (!_favoriteButton) {
        _favoriteButton = [[UIButton alloc] init];
        
        if (target != nil && selector != nil)
            [_favoriteButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_favoriteButton];
    }
    
    if (favorite) {
        
        [_favoriteButton setImage:[UIImage imageNamed:@"read_later"] forState:UIControlStateNormal];
        
    }
    else {
       
        [_favoriteButton setImage:[UIImage imageNamed:@"read_later_off"] forState:UIControlStateNormal];
    }
    
    _favoriteButton.tag = tagId;
}


- (void)setArticleTags:(NSArray*)tags target:(id)target action:(SEL)selector
{
    if ([tags count] == 0)
    {
        RELEASE_SAFELY(_systemTagButton);
        return;
    }
    
    if (!_systemTagImageView) {
        
        _systemTagImageView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:_systemTagImageView];
    }
    
    _systemTagImageView.image = [RTTableViewCell getDefaultTagBgImage];
    
    if (!_systemTagButton) {
        _systemTagButton = [[UIButton alloc] init];
        
        _systemTagButton.titleLabel.font = ZBSTYLE_font_smaller;
        [_systemTagButton setTitleColor:ZBSTYLE_tableSubTextColor forState:UIControlStateNormal];
        
        if (target != nil && selector != nil)
            [_systemTagButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_systemTagButton];
    }
    
    [_systemTagButton setTitle:[tags objectAtIndex:0] forState:UIControlStateNormal];
    
    if ([tags count] > 1) {
        
        if (!_seriesTagImageView) {
            
            _seriesTagImageView = [[UIImageView alloc] init];
            
            [self.contentView addSubview:_seriesTagImageView];
        }
        
        _seriesTagImageView.image = [RTTableViewCell getDefaultTagBgImage];
        
        if (!_seriesTagButton) {
            _seriesTagButton = [[UIButton alloc] init];
            
            _seriesTagButton.titleLabel.font = ZBSTYLE_font_smaller;
            [_seriesTagButton setTitleColor:ZBSTYLE_tableSubTextColor forState:UIControlStateNormal];
            
            if (target != nil && selector != nil)
                [_seriesTagButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentView addSubview:_seriesTagButton];
        }
        
        [_seriesTagButton setTitle:[tags objectAtIndex:1] forState:UIControlStateNormal];
    }
    else {
        [_seriesTagButton setTitle:@"" forState:UIControlStateNormal];
    }
}


- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    _nameLabel.backgroundColor = [UIColor clearColor];
    _openCountLabel.backgroundColor = [UIColor clearColor];
    _publishDateLabel.backgroundColor = [UIColor clearColor];
    _descriptionLabel.backgroundColor = [UIColor clearColor];
}


//theImage为nil时使用默认的CellBackground.png作为表格Cell背景
- (void)setBackgroundImage:(UIImage *)theImage
{
    UIImage *backgroundImage;
    
    if (theImage == nil) {

        backgroundImage = [RTTableViewCell getDefaultBackgroundImage];
    }
    else {
        backgroundImage = theImage;
    }
    
    if (self.backgroundView == nil) {
        self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
    }
}


- (void)setRead:(BOOL)read {
    _bRead = read;
}


+ (CGFloat)rowHeightForObject:(id)object {

    if (object == nil)
        return 0.0;
    
    Article *article = object;

    CGFloat coverImageHeight = [article.ImageUrl length] > 0 ? COVER_BACKGROUND_HEIGHT : kTableCellSmallMargin;
    
    UIFont* titleFont = nil;
    UIFont* descriptionFont = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ) 
    {
        descriptionFont = English_font_des;
        titleFont = English_font_title;
    } 
    else 
    {
        descriptionFont = English_font_des_iPad;
        titleFont = English_font_title_iPad;
    }
    
    //主标题
    CGSize titleLabelSize = [article.Name sizeWithFont:titleFont
                                   constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                       lineBreakMode:UILineBreakModeTailTruncation];
    
    //子标题
    CGSize subtitleLabelSize = [@"Hello World" sizeWithFont:descriptionFont
                                          constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeTailTruncation];
    
    CGSize descriptionLabelSize = {0};
    if ([article.Description length] > 0)
    {
        descriptionLabelSize = [article.Description sizeWithFont:descriptionFont
                                               constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                                   lineBreakMode:UILineBreakModeWordWrap];
        
        if (descriptionLabelSize.height > 20*subtitleLabelSize.height) //文章简介不能超过二十行
            descriptionLabelSize.height = 20*subtitleLabelSize.height;
    }
    
    CGFloat textHeight = coverImageHeight + titleLabelSize.height + subtitleLabelSize.height + SUBTITLE_HEIGHT 
        + descriptionLabelSize.height + (descriptionLabelSize.height > 0 ? kTableCellSmallMargin : 0); 
    
    return textHeight + kTableCellSmallMargin * 3;
}

#pragma mark -
#pragma mark UIView

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _nameLabel.text = nil;
    _nameLabel.textColor = [UIColor blackColor];
    _openCountLabel.text = nil;
    _publishDateLabel.text = nil;
    _typeImageView.image = nil;
    _type = ContentTypeText;
    
    [_coverImageView cancelCurrentImageLoad];
    
    _coverImageView.image = nil;
    
    _systemTagImageView.image = nil;
    _seriesTagImageView.image = nil;
    
    RELEASE_SAFELY(coverImageUrl);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIFont* titleFont = nil;
    UIFont* descriptionFont = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ) 
    {
        descriptionFont = English_font_des;
        titleFont = English_font_title;
    } 
    else 
    {
        descriptionFont = English_font_des_iPad;
        titleFont = English_font_title_iPad;
    }
    
    //取得subtitle的高度
    CGSize subtitleLabelSize = [@"2011-09-13 " sizeWithFont:descriptionFont
                                          constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeTailTruncation];
    
    //当前View的x坐标
    CGFloat left = kTableCellSmallMargin;
    //当前View的y坐标
    CGFloat top = kTableCellSmallMargin;
    
    //取得文章标题的高度
    CGSize nameLabelSize = [_nameLabel.text sizeWithFont:titleFont
                                        constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                            lineBreakMode:UILineBreakModeTailTruncation];
    
    _nameLabel.frame = CGRectMake(left, top, CELL_CONTENT_WIDTH - 2*kTableCellSmallMargin, nameLabelSize.height);
    
    //_coverImageView在_nameLabel之下
    top = (_nameLabel.frame.origin.y + _nameLabel.frame.size.height);
    left = (CELL_CONTENT_WIDTH - COVER_BACKGROUND_WIDTH) / 2;
    
    if ([coverImageUrl length] > 0) {
        
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImageView.frame = CGRectMake(kTableCellSmallMargin, 
                                       top + (COVER_BACKGROUND_HEIGHT - COVER_IMAGE_HEIGHT)/2, 
                                       COVER_IMAGE_WIDTH, 
                                       COVER_IMAGE_HEIGHT);
        
        top += COVER_BACKGROUND_HEIGHT;
    } else {
        _coverImageView.frame = CGRectZero;
        
        top += kTableCellSmallMargin;
    }
    
    //取得_descriptionLabe的宽度和高度
    CGSize descriptionLabelSize = [_descriptionLabel.text sizeWithFont:descriptionFont
                                          constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeWordWrap];
    if (descriptionLabelSize.height > 20*subtitleLabelSize.height) {
        descriptionLabelSize.height = 20*subtitleLabelSize.height;
    }
    
    //设置_descriptionLabe的坐标
    _descriptionLabel.frame = CGRectMake(kTableCellSmallMargin, top, CELL_CONTENT_WIDTH - 2*kTableCellSmallMargin, descriptionLabelSize.height);
    
    if (descriptionLabelSize.height > 0) {
        top += descriptionLabelSize.height + kTableCellSmallMargin;
    }
    
    //取得_openCountLabel的高度和宽度
    CGSize openCountLabelSize = [_openCountLabel.text sizeWithFont:ZBSTYLE_font
                                          constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeTailTruncation];
    
    //设置_openCountLabel坐标
    _openCountLabel.frame = CGRectMake(kTableCellSmallMargin, 
                                       top, 
                                       openCountLabelSize.width, 
                                       openCountLabelSize.height);
    
    //设置_typeImageView的坐标
    if (_typeImageView.image != nil)
    {
        _typeImageView.frame = CGRectMake(2 * kTableCellSmallMargin + openCountLabelSize.width, 
                                          top, 
                                          TYPE_IMAGE_WIDTH, 
                                          TYPE_IMAGE_HEIGHT);
    }
    
    left = CELL_CONTENT_WIDTH - subtitleLabelSize.width - kTableCellSmallMargin;
    
    //设置_publishDateLabel的坐标 
    _publishDateLabel.frame = CGRectMake(left, top, subtitleLabelSize.width, subtitleLabelSize.height);
    
    top += subtitleLabelSize.height + kTableCellSmallMargin;
    
    //取得systemTagLabelSize的宽度和高度
    CGSize systemTagButtonSize = [[_systemTagButton titleForState:UIControlStateNormal] 
                                  sizeWithFont:ZBSTYLE_font
                                  constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                  lineBreakMode:UILineBreakModeWordWrap];
    
    left = kTableCellSmallMargin;
    
    //设置_systemTagButton的坐标
    _systemTagButton.frame = CGRectMake(left + 2*kTableCellMargin, 
                                        top, 
                                        systemTagButtonSize.width > TAG_WIDTH - 2*kTableCellMargin ? TAG_WIDTH - 2*kTableCellMargin : systemTagButtonSize.width, 
                                        systemTagButtonSize.height + 2*kTableCellMargin);
    
    _systemTagImageView.frame = CGRectMake(left, 
                                           top, 
                                           TAG_WIDTH, 
                                           systemTagButtonSize.height + 2*kTableCellMargin);
    
    left += TAG_WIDTH + 2;
    
    //取得seriesTagLabelSize的宽度和高度
    CGSize seriesTagButtonSize = [[_seriesTagButton titleForState:UIControlStateNormal] 
                                  sizeWithFont:ZBSTYLE_font
                                  constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                  lineBreakMode:UILineBreakModeWordWrap];
    
    //设置_seriesTagButton的坐标
    _seriesTagButton.frame = CGRectMake(left + 2*kTableCellMargin, 
                                        top, 
                                        seriesTagButtonSize.width + 5 > TAG_WIDTH - 2*kTableCellMargin ? TAG_WIDTH - 2*kTableCellMargin : seriesTagButtonSize.width + 5,
                                        seriesTagButtonSize.height + 2*kTableCellMargin);
    
    _seriesTagImageView.frame = CGRectMake(left,
                                           top, 
                                           TAG_WIDTH, 
                                           seriesTagButtonSize.height + 2*kTableCellMargin);
    
    //设置_favoriteButton的坐标
    _favoriteButton.frame = CGRectMake(CELL_CONTENT_WIDTH - FAVORITE_BUTTON_WIDTH - kTableCellMargin, top, FAVORITE_BUTTON_WIDTH, FAVORITE_BUTTON_WIDTH);
}


- (void)dealloc {
    
    RELEASE_SAFELY(_nameLabel);
    RELEASE_SAFELY(_openCountLabel);
    RELEASE_SAFELY(_publishDateLabel);
    RELEASE_SAFELY(_typeImageView);
    RELEASE_SAFELY(_coverImageView);
    RELEASE_SAFELY(_favoriteButton);
    RELEASE_SAFELY(coverImageUrl);
    RELEASE_SAFELY(_systemTagImageView);
    RELEASE_SAFELY(_seriesTagImageView);
    RELEASE_SAFELY(_systemTagButton);
    RELEASE_SAFELY(_seriesTagButton);
    
    [super dealloc];
}

@end

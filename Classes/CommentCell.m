//
//  CommentCell.m
//  EnglishFun
//
//  Created by curer on 12-1-9.
//  Copyright 2012 iKnow Team. All rights reserved.
//

#import "CommentCell.h"
#import "Comment.h"

#define AVATAR_HEIGHT  30


@implementation CommentCell

@synthesize userNameLabel;
@synthesize commentLabel;
@synthesize dateLabel;
@synthesize userAvatarImageView;

+ (int)heightForCell:(Comment *)comment
{    
    CGSize s = [comment.Content sizeWithFont:ZBSTYLE_font 
                           constrainedToSize:CGSizeMake(SCREEN_WIDTH - AVATAR_HEIGHT - kTableCellSmallMargin * 3, MAXFLOAT)
                               lineBreakMode:UILineBreakModeWordWrap];
    
    return s.height + 2 * AVATAR_HEIGHT;
}

- (void)awakeFromNib
{
    // Initialization code.
    userNameLabel.font = ZBSTYLE_font;
    [userNameLabel setBackgroundColor:[UIColor clearColor]];
    
    dateLabel.font = ZBSTYLE_font;
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    dateLabel.textColor = ZBSTYLE_tableSubTextColor;
    
    commentLabel.font = ZBSTYLE_font;
    commentLabel.numberOfLines = 0;
    [commentLabel setBackgroundColor:[UIColor clearColor]];
    
    CALayer *layer = [userAvatarImageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:5];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
    }
    return self;
}

- (void)setDataSource:(Comment *)comment;
{
    if (comment.MemberName == nil || [comment.MemberName length] == 0) {
        userNameLabel.text = DEFAULT_NAME;
    } else {
        userNameLabel.text = comment.MemberName;
    }
    
    if (comment.IsOfficialComment) {
        userNameLabel.textColor = OFFICIAL_COLOR;
    }
    else {
        userNameLabel.textColor = ZBSTYLE_textColor;
    }
    
    [userAvatarImageView setImageWithURL:comment.avatarImagePath 
                        placeholderImage:[UIImage imageNamed:@"Avatar1.png"]];

    NSRange range = [comment.PublishedDate rangeOfString:@" "];
    range.length = range.location;
    range.location = 0;

    dateLabel.text = [comment.PublishedDate substringWithRange:range];
    
    if ([comment.UserId length] > 0)
    {
        self.backgroundView = [[[UIView alloc] init] autorelease];
        self.backgroundView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    }

    commentLabel.text = comment.Content;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)dealloc {
    [userNameLabel release];
    [commentLabel release];
    [dateLabel release];
    [userAvatarImageView release];
    
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    userNameLabel.text = nil;
    commentLabel.text = nil;
    dateLabel.text = nil;
    userAvatarImageView.image = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int height = AVATAR_HEIGHT;
    
    CGRect avatarRect = CGRectMake(kTableCellSmallMargin, kTableCellSmallMargin, height, height);
    self.userAvatarImageView.frame = avatarRect;
    
    CGRect dateRect = CGRectMake(SCREEN_WIDTH - 100, kTableCellSmallMargin, 100, 16);
    self.dateLabel.frame = dateRect;
    
    CGRect nameRect = CGRectMake(avatarRect.size.width + 2 * kTableCellSmallMargin, kTableCellSmallMargin, 100, 16);
    self.userNameLabel.frame = nameRect;
    
    
    CGSize s = [commentLabel.text sizeWithFont:ZBSTYLE_font 
                             constrainedToSize:CGSizeMake(SCREEN_WIDTH - nameRect.origin.x - kTableCellSmallMargin, MAXFLOAT)
                                 lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect
    commentRect = CGRectMake(nameRect.origin.x, 
                             avatarRect.origin.y + avatarRect.size.height + kTableCellSmallMargin, 
                             s.width, 
                             s.height);
    
    commentLabel.frame = commentRect;
    
    CGRect cellRect = self.frame;
    cellRect.size.height = commentRect.size.height + 60;
    self.frame = cellRect;
}

@end

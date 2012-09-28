//
//  CommentCell.h
//  EnglishFun
//
//  Created by curer on 12-1-9.
//  Copyright 2012 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Comment;

@interface CommentCell : UITableViewCell {
    IBOutlet UILabel *userNameLabel;
    IBOutlet UILabel *commentLabel;
    IBOutlet UILabel *dateLabel;
    
    IBOutlet UIImageView *userAvatarImageView;
}

@property (nonatomic, retain) UILabel *userNameLabel;
@property (nonatomic, retain) UILabel *commentLabel;
@property (nonatomic, retain) UILabel *dateLabel;

@property (nonatomic, retain) UIImageView *userAvatarImageView;

+ (int)heightForCell:(Comment *)comment;
- (void)setDataSource:(Comment *)comment;

@end

//
//  ReleatedArticleCell.m
//  iKnow
//
//  Created by curer on 11-12-28.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "ReleatedArticleCell.h"


@implementation ReleatedArticleCell

@synthesize title;
@synthesize thumbImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [thumbImage release];
    [title release];
    
    [super dealloc];
}


@end

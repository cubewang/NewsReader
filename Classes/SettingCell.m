//
//  SettingCell.m
//  EnglishFun
//
//  Created by curer on 12-1-10.
//  Copyright 2012 iKnow Team. All rights reserved.
//

#import "SettingCell.h"


@implementation SettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
        if ([[UIDevice currentDevice]userInterfaceIdiom ] == UIUserInterfaceIdiomPhone)  {
            UIImage *backgroundImage;
            NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"CellBackground" ofType:@"png"];
            backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] 
                               stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
            
            self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
            self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.backgroundView.frame = self.bounds;
            
            // set selection color 
            UIView *backgroundView = [[UIView alloc] initWithFrame:self.frame]; 
            backgroundView.backgroundColor = SELECTED_BACKGROUND;
            self.selectedBackgroundView = backgroundView; 
            [backgroundView release];
        }
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end

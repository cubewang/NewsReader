//
//  CategoryTableViewCell.m
//  iKnow
//
//  Created by Cube on 11-5-5.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "TagTableViewCell.h"


@implementation TagTableViewCell


- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    iconView.backgroundColor = [UIColor clearColor];
    nameLabel.backgroundColor = [UIColor clearColor];
}

- (void)setIcon:(UIImage *)newIcon
{
    if (newIcon == nil) {
        CGRect rc = nameLabel.frame;
        rc.origin.x -= 24;
        nameLabel.frame = rc;
    }
    
    iconView.image = newIcon;
}


- (void)setName:(NSString *)newName
{
    nameLabel.text = newName;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone ) {
        nameLabel.textColor = [UIColor blackColor];
    }
}

//theImage为nil时使用默认的CellBackground.png作为表格Cell背景
- (void)setBackgroundImage:(UIImage *)theImage
{
    UIImage *backgroundImage;
    
    if (theImage == nil) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ) {
            
            NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"TagCellBackground" ofType:@"png"];
            backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] 
                               stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
        }
        else {
            NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"TagCellBackground_iPad" ofType:@"png"];
            backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] 
                               stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];

        }
    } 
    else {
        backgroundImage = theImage;
    }
    
    self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.frame = self.bounds;
}


- (void)dealloc {
    
    [iconView release];
    [nameLabel release];
    
    [super dealloc];
}


@end

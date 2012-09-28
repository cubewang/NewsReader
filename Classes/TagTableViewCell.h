//
//  CategoryTableViewCell.h
//  iKnow
//
//  Created by Cube on 11-5-5.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface TagTableViewCell : UITableViewCell 
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *nameLabel;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor;
- (void)setIcon:(UIImage *)newIcon;
- (void)setName:(NSString *)newName;
- (void)setBackgroundImage:(UIImage *)theImage;

@end

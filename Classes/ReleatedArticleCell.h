//
//  ReleatedArticleCell.h
//  iKnow
//
//  Created by curer on 11-12-28.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReleatedArticleCell : UITableViewCell {
    IBOutlet UILabel *title;
    IBOutlet UIImageView *thumbImage;
}

@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UIImageView *thumbImage;

@end

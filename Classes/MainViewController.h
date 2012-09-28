//
//  MainViewController.h
//  EnglishFun
//
//  Created by curer on 11-12-22.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"

#import "VisualDownloader.h"

@interface MainViewController : BaseTableViewController {
}

@property (nonatomic, copy) NSString *tagTobeSet;
@property (nonatomic, copy) NSString *tagCurrentUsed;

@property (nonatomic, retain) VisualDownloader *audioDownloader;

- (void)setArticleTag:(NSString *)tag;

@end

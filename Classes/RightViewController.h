//
//  RightViewController.h
//
//
//  Created by Marcel Dierkes on 04.12.11.
//  Copyright (c) 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagTableViewCell.h"

@interface RightViewController : UIViewController

@property (nonatomic, retain) NSArray *tagList;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) TagTableViewCell *tableViewCell;
@property (nonatomic, retain) UINib *tableViewCellNib;

@end

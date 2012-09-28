//
//  FavoritesViewController_iPad.h
//  iKnow
//
//  Abstract: 文章收藏列表试图控制器
//
//  Created by Cube on 11-5-17.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import "iFavorite.h"
#import "WebViewController.h"
#import "DropDownHeaderView.h"
#import "GlobalDef.h"


@interface FavoritesViewController_iPad : UIViewController<UIActionSheetDelegate> {
    
    UITableView *tableView;
    UIViewController *popupViewController;
    DropDownHeaderView *dropDownView;
    
    NSManagedObjectContext *context;
    NSFetchedResultsController *_fetchedResultsController;
    
    NSString *userID;
}

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIViewController *popupViewController;

@property (nonatomic, retain) DropDownHeaderView *dropDownView;

@property (nonatomic, retain) IBOutlet UIButton *backItem;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

- (IBAction)backupButtonClicked:(id)sender;

- (IBAction)restoreButtonClicked:(id)sender;

- (IBAction)close:(id)sender;

@end

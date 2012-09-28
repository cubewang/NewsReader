//
//  WordCardViewController.h
//  iKnow
//
//  Abstract: 生词本试图控制器
//
//  Created by Cube on 11-5-17.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import "iWord.h"
#import "Word.h"
#import "Parser.h"
#import "DropDownHeaderView.h"
#import "GlobalDef.h"
#import "MBProgressHUD.h"

@class LoginOrRegisterAlertView;
@class WordCardViewController;


@interface WordsViewController : UIViewController <NSFetchedResultsControllerDelegate> {
    
    UITableView *tableView;
    UIViewController *popupViewController;
    DropDownHeaderView *dropDownView;
    
    NSString *selectedWord; //查询中的单词
    Word *word;  //查询中的单词对应的Word对象
    Parser *parser;
    
    NSManagedObjectContext *context;
    NSFetchedResultsController *_fetchedResultsController;
    
    MBProgressHUD *HUD;
    
    NSString *userID;
}

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) Word *word;
@property (nonatomic, retain) Parser *parser;
@property (nonatomic, copy) NSString *selectedWord;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) UIViewController *popupViewController;

@property (nonatomic, retain) DropDownHeaderView *dropDownView;

@property (nonatomic, retain) MBProgressHUD *HUD;

@property (nonatomic, retain) IBOutlet UIButton *backButton;

- (IBAction)backupButtonClicked:(id)sender;

- (IBAction)restoreButtonClicked:(id)sender;


- (IBAction)close:(id)sender;

@end

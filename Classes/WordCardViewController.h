//
//  WordCardViewController.h
//  iKnow
//
//  Abstract: 生词试图控制器
//
//  Created by Cube on 11-5-17.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import "Word.h"
#import "Parser.h"
#import "Downloader.h"
#import "iWord.h"


@interface WordCardViewController : UIViewController <NSFetchedResultsControllerDelegate> {
    
    Word *_word;
    NSMutableArray *downloaderList;
    AVAudioPlayer *player;
    UILabel *keyLabel;
    UILabel *pronLabel;
    UITableView *acceptationTableView;
    UITableView *sentenceTableView;
    UIButton *favoriteButton;
    UIButton *pronunciationButton;
    
    UITextField *descriptionTextField;
    CGRect keyboardRect;
    
    NSManagedObjectContext *context;
    NSFetchedResultsController *fetchedResultsController;
    BOOL isWordFavorite;
    
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *translator;
    IBOutlet UILabel *listen;
    IBOutlet UILabel *remarks;
    IBOutlet UILabel *favorites;
    IBOutlet UILabel *close;
}

@property (nonatomic, retain) Word *word;
@property (nonatomic, retain) NSMutableArray *downloaderList;
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) IBOutlet UILabel *keyLabel;
@property (nonatomic, retain) IBOutlet UILabel *pronLabel;
@property (nonatomic, retain) IBOutlet UITableView *acceptationTableView;
@property (nonatomic, retain) IBOutlet UITableView *sentenceTableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIButton *favoriteButton;
@property (nonatomic, retain) IBOutlet UIButton *pronunciationButton;
@property (nonatomic, retain) UILabel *translator;
@property (nonatomic, retain) UILabel *listen;
@property (nonatomic, retain) UILabel *remarks;
@property (nonatomic, retain) UILabel *favorites;
@property (nonatomic, retain) UILabel *close;
 
@property (nonatomic, retain) IBOutlet UITextField *descriptionTextField;
@property (nonatomic, assign) CGRect keyboardRect;

- (IBAction)closeCard:(id)sender;
- (IBAction)pronunce:(id)sender;
- (IBAction)favoriteButtonClicked:(UIButton *)sender;

@end

//
//  CommentViewController.h
//  iKnow
//
//  Abstract: 评论列表试图控制器
//
//  Created by Cube on 11-4-24.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"
#import "Parser.h"
#import "WebViewController.h"
#import "Downloader.h"
#import "ZTextField.h"

@interface CommentViewController : UIViewController {
    NSMutableArray *parserList;
    BOOL isRequestingData;
    
    NSString *articleId;
    NSMutableArray *commentItems; //store contentList XML data
    
    ZTextField           *commentTextField;  
    UITableView          *tableView;
    IBOutlet UINavigationBar *navBar;
    
    BOOL _keyboardIsShown;
}

- (IBAction) closeContent:(id)sender;

- (void)addCommentButtonClicked:(id)sender;

@property (nonatomic, retain) NSString *articleId;
@property (nonatomic, retain) NSMutableArray *commentItems;
@property (nonatomic, retain) ZTextField *commentTextField; 
@property (nonatomic, retain) UITableView  *tableView;  
@property (nonatomic, retain) UINavigationBar *navBar;


@end

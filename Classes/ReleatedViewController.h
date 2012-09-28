//
//  ReleatedViewController.h
//  iKnow
//
//  Created by curer on 11-12-28.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface ReleatedViewController : UIViewController {
    NSMutableArray *relatedArticleList;
    Article *articleReleated;
    id delegate;
    
    IBOutlet UITableView *_tableView;
    IBOutlet UINavigationBar *navBar;
}

@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSArray *relatedArticleList;
@property (nonatomic, retain) Article *articleReleated;
@property (nonatomic, retain) UITableView *tableView;

- (IBAction)backButtonDidClicked;

- (id)initWithArticle:(Article *)article;

@end

@protocol ReleatedViewControllerDelegate <NSObject>
@required

- (void)releatedArticle:(Article *)aArticle;

@end
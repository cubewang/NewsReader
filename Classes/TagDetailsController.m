//
//  TagDetailsController.m
//  iKnow
//
//  Created by Cube on 11-5-6.
//  Copyright 2011 iKnow. All rights reserved.
//

#import "TagDetailsController.h"


@implementation TagDetailsController

@synthesize articleTag;
@synthesize hasSubscribed;

@synthesize popupViewController = _popupViewController;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([EnglishFunAppDelegate setNavImage:@"NavBar.png"]){
        [self.navigationController.navigationBar setNeedsDisplay];
    }
    
    NSArray *tagArray = [iKnowAPI getSubscribedTags];
    
    hasSubscribed = NO;
    for (NSString *item in tagArray) {
        if ([item isEqualToString:articleTag]) {
            hasSubscribed = YES;
        }
    }
    
    self.viewDeckController.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.viewDeckController.enabled = YES;
}

- (void)viewDidLoad {
    
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"BaseTableView" owner:self options:NULL] lastObject];
    
    [super viewDidLoad];
    
    allowShowAuthorPanel = YES;
    
    if (articleTag)
    {
        //设置导航条文字
        UILabel* label = [EnglishFunAppDelegate createNavTitleView:articleTag];
        self.navigationItem.titleView = label;
        [label release];
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回", @"")
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(backAction)];
    
    self.navigationItem.leftBarButtonItem = item;
    [item release];
}

- (void)backAction {
    
    [_popupViewController setHidesBottomBarWhenPushed:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)showTagDetails:(NSString*)tag {
    
    return ![articleTag isEqualToString:tag];
}

- (void)subscribe {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = nil;
    
    NSString *userID = [[iKnowAPI getUserId] copy];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        BOOL bSuccess = NO;
        
        bSuccess = hasSubscribed ? [iKnowAPI unsubscribeTag:articleTag withUserID:userID]
                                : [iKnowAPI subscribeTag:articleTag withUserID:userID];
        
        [userID release];
        
        if (bSuccess) {
            hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = hasSubscribed ? NSLocalizedString(@"退订成功",@"" ) : NSLocalizedString(@"订阅成功",@"" );
        }
        else {
            hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete.png"]] autorelease];
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = hasSubscribed ? NSLocalizedString(@"退订失败", @"") : NSLocalizedString(@"订阅失败", @"");
        }

        sleep(1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (bSuccess) {
                if (hasSubscribed) {
                    hasSubscribed = NO;
                    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"订阅", @"");
                }
                else {
                    hasSubscribed = YES;
                    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"退订", @"");
                }                
            }
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (BOOL)getArticleList:(NSInteger)startPosition length:(NSInteger)length useCacheFirst:(BOOL)useCacheFirst
{
    if (articleTag == nil) {
        [self parser:nil didFailWithError:nil];
    }
    
    NSArray *tagArray = [NSArray arrayWithObject:articleTag];
    
    self.parser = [iKnowAPI getArticleList:nil 
                                  tagArray:tagArray
                             startPosition:startPosition 
                                    length:length 
                                  delegate:self 
                             useCacheFirst:useCacheFirst];
    
    return self.parser != nil;
}

- (void)close
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    
    self.articleTag = nil;
    
    [super dealloc];
}


@end


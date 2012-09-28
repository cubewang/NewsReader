//
//  ReleatedViewController.m
//  iKnow
//
//  Created by curer on 11-12-28.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "ReleatedViewController.h"
#import "ReleatedArticleCell.h"
#import "RTTableViewCell.h"

@implementation ReleatedViewController

@synthesize navBar;
@synthesize relatedArticleList;
@synthesize delegate;
@synthesize articleReleated;
@synthesize tableView = _tableView;

- (id)initWithArticle:(Article *)article
{
    self.articleReleated = article;
    return [self init];
}

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

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.rowHeight = 60;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = CELL_BACKGROUND;
    
    self.navBar.tintColor = NAV_BAR_ITEM_COLOR;
    if ([self.navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navBar setBackgroundImage:[UIImage imageNamed:@"NavBar_ios5.png"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        Parser *paser = [iKnowAPI getRelatedArticle:articleReleated delegate:self];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
            
            [self.tableView reloadData];
        });
    });
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [relatedArticleList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ReleatedArticleCell";
    
    ReleatedArticleCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:cellIdentifier
                                                      owner:nil options:nil];
        
        for (id item in nibs) {
            if ([item isKindOfClass:[UITableViewCell class]]) {
                cell = item;
                break;
            }
        }
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame]; 
        backgroundView.backgroundColor = SELECTED_BACKGROUND;
        cell.selectedBackgroundView = backgroundView; 
        [backgroundView release];
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"CellBackground" ofType:@"png"];
        UIImage *bgImage = [[UIImage imageWithContentsOfFile:imagePath]
                            stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
        
        cell.backgroundView = [[[UIImageView alloc] initWithImage:bgImage] autorelease];
        
        cell.title.lineBreakMode = UILineBreakModeWordWrap;
        cell.title.numberOfLines = 2;
    }
    
    Article *aArticle = [relatedArticleList objectAtIndex:indexPath.row];
    
    cell.title.text = aArticle.Name;
    [cell.thumbImage setImageWithURL:aArticle.ImageUrl 
                    placeholderImage:[RTTableViewCell getDefaultCoverImage]];
    
    if ([aArticle.Id isEqualToString:articleReleated.Id]) {
        cell.title.textColor = ZBSTYLE_tableSubTextColor;
    }
    else {
        cell.title.textColor = ZBSTYLE_textColor;
    }
    
    return cell;
}


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
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([delegate respondsToSelector:@selector(releatedArticle:)]) {
        [delegate releatedArticle:[relatedArticleList objectAtIndex:indexPath.row]];
    }
    
    [self backButtonDidClicked];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [relatedArticleList release];
    [articleReleated release];
    [self.tableView release];
    [navBar release];
    
    [super dealloc];
}

#pragma mark Parser

- (void)parser:(Parser *)parser didParseArticle:(Article *)aArticle {
    
    if (!aArticle)
        return;
    
    int width = [[UIScreen mainScreen] scale] * 200;
    
    aArticle.ImageUrl = [iKnowAPI getThumbImageServerPath:aArticle.ImageUrl thumbWidh:width];
    aArticle.AvatarImageUrl = [iKnowAPI getThumbImageServerPath:aArticle.AvatarImageUrl 
                                                      thumbWidh:[[UIScreen mainScreen] scale] * 40];
    if ([aArticle.UserName length] == 0) 
    {
        aArticle.UserName = DEFAULT_NAME;
    }
    
    if (relatedArticleList == nil)
    {
        relatedArticleList = [[NSMutableArray alloc] init];
    }
    
    [relatedArticleList addObject:aArticle];
}

#pragma mark UIAction

- (IBAction)backButtonDidClicked
{
    [self dismissModalViewControllerAnimated:YES];
}

@end


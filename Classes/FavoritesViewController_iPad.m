//
//  FavoritesViewController_iPad.m
//  iKnow
//
//  Created by Cube on 11-6-27.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "FavoritesViewController_iPad.h"
#import "UserLoginViewController.h"
#import "RTTableViewCell.h"
#import "Article.h"
#import "UserLoginViewController_iPad.h"
#import "WebViewController_iPad.h"

#define SYSBARBUTTON(ITEM, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] autorelease]

static const int ddLogLevel = LOG_FLAG_ERROR;


@implementation FavoritesViewController_iPad

@synthesize tableView, popupViewController;
@synthesize context;
@synthesize fetchedResultsController = _fetchedResultsController;

@synthesize dropDownView;
@synthesize userID;

@synthesize backItem;
@synthesize navBar;
@synthesize titleLabel;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
    if ([EnglishFunAppDelegate setNavImage:@"NavBar.png"]){
        [self.navigationController.navigationBar setNeedsDisplay];
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.backItem setTitle:NSLocalizedString(@"返回", @"") forState:UIControlStateNormal];
    self.titleLabel.text = NSLocalizedString(@"我的收藏", @"");
    
    // Init the fetched results controller
    NSError *error;
    
    if (![[self fetchedResultsController] performFetch:&error])
        DDLogError(@"Error: %@", [error localizedDescription]);
    
    [self setBarButtonItems];
    
    //设置导航条文字
    UILabel* label = [EnglishFunAppDelegate createNavTitleView:NSLocalizedString (@"我的收藏",@"")];
    self.navigationItem.titleView = label;
    [label release];
    
    if (dropDownView == nil) {
        dropDownView = [[DropDownHeaderView alloc] initWithFrame:CGRectMake(0.0f, -30, SCREEN_WIDTH, 30)];
        
        UIButton *backupButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [backupButton addTarget:self action:@selector(backupButtonClicked:) 
               forControlEvents:UIControlEventTouchUpInside];
        
        [backupButton setImage:[UIImage imageNamed:@"backup.png"] forState:UIControlStateNormal];
        backupButton.frame = CGRectMake(170, 10, 120, 30);
        
        [dropDownView addSubview:backupButton];
        
        UILabel *backup = [[UILabel alloc] initWithFrame:CGRectMake(172, 10, 120, 30)];
        backup.textAlignment = UITextAlignmentCenter;
        backup.font = [UIFont systemFontOfSize:13.0];
        backup.backgroundColor = [UIColor clearColor];
        backup.textColor = [UIColor blackColor];
        backup.text = NSLocalizedString(@"备份", @"");
        
        [dropDownView addView:backup];
        [backup release];
        
        UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [restoreButton addTarget:self action:@selector(restoreButtonClicked:) 
                forControlEvents:UIControlEventTouchUpInside];
        
        [restoreButton setImage:[UIImage imageNamed:@"restore.png"] forState:UIControlStateNormal];
        restoreButton.frame = CGRectMake(470, 10, 120, 30);
        
        [dropDownView addSubview:restoreButton];
        dropDownView.backgroundColor = [UIColor clearColor];
        
        //[self.tableView insertSubview:dropDownView atIndex:0];
        self.tableView.tableHeaderView = dropDownView;
        
        UILabel *restore = [[UILabel alloc] initWithFrame:CGRectMake(472, 10, 120, 30)];
        restore.textAlignment = UITextAlignmentCenter;
        restore.font = [UIFont systemFontOfSize:13.0];
        restore.backgroundColor = [UIColor clearColor];
        restore.textColor = [UIColor blackColor];
        restore.text = NSLocalizedString(@"还原", @"");
        
        [dropDownView addView:restore];
        [restore release];
    }
}


- (void)backAction {
    [self.popupViewController setHidesBottomBarWhenPushed:NO];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) deleteAllObjects:(NSString *)entityName {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
                                              inManagedObjectContext:self.context];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest 
                                            error:&error];
    
    [fetchRequest release];
    
    for (NSManagedObject *object in items) {
        [context deleteObject:object];
    }
    
    if (![context save:&error]) {
        DDLogError(@"Error delete %@", entityName);
    }
}

#pragma mark -
#pragma mark DropDownHeaderView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	
	//[dropDownView DDRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //[dropDownView DDRefreshScrollViewDidEndDragging:scrollView];
}

- (void)myTask:(int)aTag {
    if (aTag) {
        [iKnowAPI getFavoriteList:self.userID 
                         delegate:self 
                    useCacheFirst:NO
                   connectionType:ConnectionTypeSynchronously];
    }
    else {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"iFavorite" 
                                                  inManagedObjectContext:self.context];
        
        [fetchRequest setEntity:entity];
        
        NSError *error;
        NSArray *items = [context executeFetchRequest:fetchRequest 
                                                error:&error];
        
        [fetchRequest release];
        
        [self uploadFavouritesToServer:items];
    }
}

- (void) uploadFavouritesToServer:(NSArray *)favourites
{
    NSMutableArray *dataList = [[NSMutableArray alloc] init];
    
    NSDictionary *item;   
    for (iFavorite *favourite in favourites) {
        
        if ([favourite.articleId length] == 0)
            continue;
        
        item = [NSDictionary dictionaryWithObjectsAndKeys:favourite.articleId, @"content", nil];

        [dataList addObject:item];
    }
    
    BOOL result = [iKnowAPI deleteFavorites:dataList];
    
    if (!result)
    {
        DDLogError(@"deleteFavorites failed.");
    }
    
    result = [iKnowAPI addFavorites:dataList];
    
    if (!result)
    {
        DDLogError(@"addFavorites failed.");
    }
    
    [dataList release];
}

- (void) actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = NSLocalizedString (@"请求云端收藏中，请稍候...",@"");
            
            self.userID = [iKnowAPI getUserId];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

                [self myTask:actionSheet.tag];
                
                hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
                hud.mode = MBProgressHUDModeCustomView;
                hud.labelText = @"";
                
                sleep(1);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            });
        }
            break;
        default:
            break;
    }
}

- (IBAction)backupButtonClicked:(id)sender {
    
    BOOL bRes = [Client userHasRegistered];
    
    if (bRes) {
        UIActionSheet *action = [[UIActionSheet alloc] 
                                 initWithTitle:NSLocalizedString (@"确认用手机端收藏夹覆盖云端的吗？",@"") 
                                 delegate:self 
                                 cancelButtonTitle:NSLocalizedString (@"取消",@"") 
                                 destructiveButtonTitle:NSLocalizedString (@"确定",@"") 
                                 otherButtonTitles:nil];
        action.tag = 0;
        
        [action showInView:self.view];
        [action release];

    }
    else {
        [self loginOrRegisterUser];
    }
}

- (IBAction)restoreButtonClicked:(id)sender{
    
    BOOL bRes = [Client userHasRegistered];    
    if (bRes) {
        UIActionSheet *action = [[UIActionSheet alloc] 
                                 initWithTitle:NSLocalizedString (@"确认用云端收藏夹覆盖手机端的吗？",@"") 
                                 delegate:self 
                                 cancelButtonTitle:NSLocalizedString (@"取消",@"") 
                                 destructiveButtonTitle:NSLocalizedString (@"确定",@"") 
                                 otherButtonTitles:nil];
        
        action.tag = 1;
        
        [action showInView:self.view];
        [action release];
    }
    else {
        [self loginOrRegisterUser];
    }
}

- (void)parserDidStart:(Parser *)parser
{
    [self deleteAllObjects:@"iFavorite"];
}


- (void)parser:(Parser *)parser didParseArticle:(Article *)article {
    
    if (!article)
        return;

    iFavorite *newFavorite = [NSEntityDescription insertNewObjectForEntityForName:@"iFavorite" inManagedObjectContext:self.context];
    
    newFavorite.articleId = article.Id;
    newFavorite.name = article.Name;

    NSRange range = [article.CreateTime rangeOfString:@" "];
    if (range.location != NSNotFound){
        range.length = range.location;
        range.location = 0;
        
        newFavorite.createDate = [article.CreateTime substringWithRange:range];
    }
    else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString* dateString = [dateFormat stringFromDate:[NSDate date]];
        newFavorite.createDate = dateString;
        [dateFormat release];
    }
}

- (void)parserDidFinish:(Parser *)parser {
}

- (void)parser:(Parser *)parser didFailWithError:(NSString *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:NSLocalizedString (@"提示",@"") 
                                  message:NSLocalizedString (@"同步收藏失败",@"") 
                                  delegate:self 
                                  cancelButtonTitle:NSLocalizedString (@"确定",@"") 
                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
}

//文章标签按钮事件处理
- (IBAction)tagButtonClicked:(id)sender {
    
    /*
     if (![Client userHasRegistered]) {
     return [self loginOrRegisterUser];
     }*/
    
    UIButton *button = (UIButton*)sender;
    NSString *tag = [button titleForState:UIControlStateNormal];
}

//收藏按钮点击事件处理，根据tag取得被点击的文章id
- (IBAction)favoriteButtonClicked:(id)sender {
    
    UIButton *clickedButton = (UIButton*)sender;
}


#pragma mark -
#pragma mark Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RTTableViewCell";
    
    RTTableViewCell *articleTableViewCell = (RTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (articleTableViewCell == nil)
    {
        articleTableViewCell = [[RTTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        // set selection color 
        UIView *backgroundView = [[UIView alloc] initWithFrame:articleTableViewCell.frame]; 
        backgroundView.backgroundColor = SELECTED_BACKGROUND;
        articleTableViewCell.selectedBackgroundView = backgroundView; 
        [backgroundView release];
    }
    
    // Recover object from fetched results
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Article *article = [[[Article alloc] initWithFavorite:managedObject] autorelease];
    
    // Configure the cell.
    if (article) {
        [articleTableViewCell setDataSource:article];
        [articleTableViewCell setFavorite:article.isFavorite 
                                    tagId:indexPath.row 
                                   target:self 
                                   action:@selector(favoriteButtonClicked:)];
        [articleTableViewCell setArticleTags:article.Tags 
                                      target:self 
                                      action:@selector(tagButtonClicked:)];
    }
    
    //is cache hit
    NSString *requestedUrl = [iKnowAPI getContentPath:article.Id];
    if ([EnglishFunAppDelegate UrlCacheHit:requestedUrl]) {
        articleTableViewCell.nameLabel.textColor 
        = [UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1.0];
    }
    
    return articleTableViewCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Article *article = [[[Article alloc] initWithFavorite:managedObject] autorelease];
    
    if (article) {
        return [RTTableViewCell rowHeightForObject:article];
    }
    
    return 0.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Use the fetched results section count
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the count for each section
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32 + 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [self tableView:self.tableView titleForHeaderInSection:section];
    
    UIImageView *headBgView = [[[UIImageView alloc] init] autorelease];
    headBgView.frame = CGRectMake(0, 5, 120, 32);
    headBgView.image = [[UIImage imageNamed:@"tableViewSection_bg.png"] 
                        stretchableImageWithLeftCapWidth:2 
                        topCapHeight:2];
    
    UIView *sectionView = [[UIView alloc] initWithFrame:headBgView.frame];
    [sectionView addSubview:headBgView];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:headBgView.frame] autorelease];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    
    [sectionView addSubview:label];
    
    return [sectionView autorelease];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    // Return the title for a given section
    id <NSFetchedResultsSectionInfo> theSection = [[_fetchedResultsController sections] objectAtIndex:section];
    
    NSString *titleString = [theSection name];
    
    return titleString;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    // Query the titles for the section associated with an index title
    return [self.fetchedResultsController.sectionIndexTitles indexOfObject:title];
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // When a row is selected
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *articleId = [managedObject valueForKey:@"articleId"];
    
    if ([articleId length] == 0) {
        return;
    }
    
    Article *newArticle = [[Article alloc] init];
    newArticle.UserName = [managedObject valueForKey:@"provider"];
    newArticle.Name = [managedObject valueForKey:@"name"];
    newArticle.Id = articleId;
    
    // Show detail
    WebViewController_iPad *webViewController_iPad = [[WebViewController_iPad alloc] initWithNibName:@"WebView_iPad" bundle:nil];
    webViewController_iPad.article = newArticle;
    webViewController_iPad.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.view.superview layer] addAnimation:animation forKey:@"WebView_iPad"];
    
    [self presentModalViewController:webViewController_iPad animated:NO];
    
    [webViewController_iPad release];
    [newArticle release];
}

- (void)setBarButtonItems
{
    // right (edit/done) item depends on both edit mode and item count
    int count = [[self.fetchedResultsController fetchedObjects] count];
    if (tableView.isEditing)
        self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(leaveEditMode));
    else
        self.navigationItem.rightBarButtonItem =  count ? SYSBARBUTTON(UIBarButtonSystemItemEdit, @selector(enterEditMode)) : nil;
}

-(void)enterEditMode
{
    // Start editing
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    [tableView setEditing:YES animated:YES];
    [self setBarButtonItems];
}

-(void)leaveEditMode
{
    // finish editing
    [tableView setEditing:NO animated:YES];
    [self setBarButtonItems];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // delete request
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        iFavorite *favorite = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (![iKnowAPI deleteFavorite:favorite.articleId]) {
            DDLogError(@"delete favourite from server error");
        }
        
        NSError *error = nil;
        [self.context deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
        if (![self.context save:&error]) 
            DDLogError(@"Error: %@", [error localizedDescription]);
    }
    
    // update buttons after delete action
    [self setBarButtonItems];
}

- (IBAction)close:(id)sender
{
    BOOL bAnimation = sender != nil;
    
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        
        if (self.presentedViewController) {
            [[self presentedViewController] dismissModalViewControllerAnimated:bAnimation];
        }
        else {
            [self dismissModalViewControllerAnimated:bAnimation];
        }
    }
    else {
        [[self parentViewController] dismissModalViewControllerAnimated:bAnimation];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.dropDownView = nil;
}

#pragma mark CoreData

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    if ([[self.fetchedResultsController fetchedObjects] count] == 1) {
        [self setBarButtonItems];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //TODO::
            //[self configureCell:(RecipeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

//按照createDate排序，按照createDate分组，取得所有收藏
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    if (self.context == nil) {
        self.context = [[[EnglishFunAppDelegate sharedAppDelegate] getClient] getContext];
    }
    
    // Init a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"iFavorite" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0]; 
    
    // 排序
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO selector:nil];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] 
                                     initWithFetchRequest:fetchRequest 
                                     managedObjectContext:self.context 
                                     sectionNameKeyPath:@"createDate" //@"dataTime" 
                                     cacheName:nil];
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController release]; 
    
    [fetchRequest release];
    [sortDescriptor release];
    
    return _fetchedResultsController;
}


//从我的收藏中删除
- (BOOL)deleteFavorite:(NSIndexPath *)indexPath
{
    iFavorite *favorite = (iFavorite *)[_fetchedResultsController objectAtIndexPath:indexPath];
    
    //从服务器删除收藏
    if (![iKnowAPI deleteFavorite:favorite.articleId]) {
        return NO;
    }
    
    NSError *error = nil;
    [self.context deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
    if (![self.context save:&error])
    {
        DDLogError(@"Error: %@", [error localizedDescription]);
        return FALSE;
    }
    else {
        return TRUE;
    }
}

- (void)loginOrRegisterUser
{
    UserLoginViewController_iPad *viewController = [[UserLoginViewController_iPad alloc] initWithNibName:@"UserLoginView_iPad"bundle:nil];
    
    [self presentModalViewController:viewController animated:YES];
    
    [viewController release];
}

- (void)dealloc {
    [self.context save:nil];
    
    self.context = nil;
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    
    self.tableView = nil;
    [popupViewController release];
    
    [userID release];
    
    [dropDownView release];
    
    self.titleLabel = nil;
    self.backItem = nil;
    self.navBar = nil;
    
    [super dealloc];
}


@end

//
//  WordCardViewController.m
//  iKnow
//
//  Created by Cube on 11-6-27.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "WordsViewController.h"
#import "WordCardViewController.h"
#import "UserLoginViewController.h"

#define SYSBARBUTTON(ITEM, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] autorelease]

static const int ddLogLevel = LOG_FLAG_ERROR;


@implementation WordsViewController

@synthesize tableView, popupViewController;
@synthesize context;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize word, parser, selectedWord;

@synthesize dropDownView, HUD;
@synthesize userID;
@synthesize navBar;
@synthesize backButton;

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([EnglishFunAppDelegate setNavImage:@"NavBar.png"]){
        [self.navigationController.navigationBar setNeedsDisplay];
    }
}

- (void)showLeft
{
    [self.viewDeckController toggleLeftView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Init the fetched results controller
    NSError *error;
    
    if (![[self fetchedResultsController] performFetch:&error])
        DDLogError(@"Error: %@", [error localizedDescription]);
    
    [self setBarButtonItems];
    
    self.navBar.tintColor = NAV_BAR_ITEM_COLOR;
    if ([self.navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [ self.navBar setBackgroundImage:[UIImage imageNamed:@"NavBar_ios5.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.navBar.layer.shadowRadius = 3.0f;
    self.navBar.layer.shadowOpacity = 0.8f;
    
    self.navBar.topItem.title = NSLocalizedString(@"生词本", @"");
    
    if (dropDownView == nil) {
        dropDownView = [[DropDownHeaderView alloc] initWithFrame:CGRectMake(0.0f, -30, SCREEN_WIDTH, 30)];
    
        UIButton *backupButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [backupButton addTarget:self action:@selector(backupButtonClicked:) 
                forControlEvents:UIControlEventTouchUpInside];
        
        [backupButton setImage:[UIImage imageNamed:@"backup.png"] forState:UIControlStateNormal];
        backupButton.frame = CGRectMake(20, 10, 120, 30);
        
        [dropDownView addSubview:backupButton];
        
        UILabel *backup = [[UILabel alloc] initWithFrame:CGRectMake(22, 10, 120, 30)];
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
        restoreButton.frame = CGRectMake(170, 10, 120, 30);
        
        [dropDownView addSubview:restoreButton];
        
        UILabel *restore = [[UILabel alloc] initWithFrame:CGRectMake(172, 10, 120, 30)];
        restore.textAlignment = UITextAlignmentCenter;
        restore.font = [UIFont systemFontOfSize:13.0];
        restore.backgroundColor = [UIColor clearColor];
        restore.textColor = [UIColor blackColor];
        restore.text = NSLocalizedString(@"还原", @"");
        
        [dropDownView addView:restore];
        [restore release];
	
        dropDownView.backgroundColor = [UIColor clearColor];
        
        //[self.tableView insertSubview:dropDownView atIndex:0];
        self.tableView.tableHeaderView = dropDownView;
    }
}

- (void)backAction {
    //[self.popupViewController setHidesBottomBarWhenPushed:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

//TODO:根据查询数设置颜色
- (UIColor *) getColor:(NSString *)hexColor
{
    return [UIColor colorWithRed:(float)(0/255.0f) green:(float)(0/255.0f) blue:(float)(0/255.0f) alpha:1.0f];
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
        [iKnowAPI getWordList:self.userID  
                     delegate:self 
                useCacheFirst:NO 
               connectionType:ConnectionTypeSynchronously];
    }
    else {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"iWord" 
                                                  inManagedObjectContext:self.context];
        
        [fetchRequest setEntity:entity];
        
        NSError *error;
        NSArray *items = [context executeFetchRequest:fetchRequest 
                                                error:&error];
        
        [fetchRequest release];
        
        [self uploadWordsToServer:items];
    }
}

- (void) uploadWordsToServer:(NSArray *)words 
{
    NSMutableArray *addWordList = [[NSMutableArray alloc] init];
    NSMutableArray *deleteWordList = [[NSMutableArray alloc] init];
    
    NSDictionary *item;  
    for (iWord *wordItem in words) {
        
        if ([wordItem.key length] == 0)
            continue;
        
        item = [NSDictionary dictionaryWithObjectsAndKeys:
                wordItem.key, @"word", nil];
        
        [deleteWordList addObject:item];
        
        item = [NSDictionary dictionaryWithObjectsAndKeys:
                wordItem.key, @"word",
                SAFE_STRING(wordItem.acceptation), @"def", 
                wordItem.remark, @"description", nil];
        
        [addWordList addObject:item];
    }
    
    BOOL result = [iKnowAPI deleteWords:deleteWordList];
    
    if (!result)
    {
        DDLogError(@"deleteWords failed.");
    }
    
    result = [iKnowAPI addWords:addWordList];
    
    if (!result)
    {
        DDLogError(@"addWords failed.");
    }
    
    [addWordList release];
    [deleteWordList release];
}

- (void) actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = NSLocalizedString (@"请求云端生词本中，请稍候...",@"");
            self.userID = [iKnowAPI getUserId];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                // Do a taks in the background
                [self myTask:actionSheet.tag];
                
                hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
                hud.mode = MBProgressHUDModeCustomView;
                hud.labelText = @"";
                
                sleep(1);
                
                // Hide the HUD in the main tread 
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
                                 initWithTitle:NSLocalizedString (@"确认用手机端生词本覆盖云端的吗？",@"")
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

- (IBAction)restoreButtonClicked:(id)sender {
    
    BOOL bRes = [Client userHasRegistered];
    
    if (bRes) {
        UIActionSheet *action = [[UIActionSheet alloc] 
                                 initWithTitle:NSLocalizedString (@"确认用云端生词本覆盖手机端的吗？",@"")
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
    //如果是同步操作的话
    if (parser != self.parser) {
        
        [self deleteAllObjects:@"iWord"];
        
        return;
    }
}


- (void)parser:(Parser *)aParser didParseWord:(Word *)aWord {
    
    //如果是同步操作的话
    if (aParser != self.parser) {
        [self didSynchronizeWord:aWord];
        
        return;
    }
    
    DDLogInfo(@"Parsed Word: “%@”", aWord.Key);
    if (aWord) self.word = aWord;
}

- (void)parserDidFinish:(Parser *)aParser {
    
    //如果是同步操作的话
    if (aParser != self.parser) {

        return;
    }
    
    if (word == nil)
        return;
    
    if (word.Key == nil)
        word.Key = (selectedWord ? selectedWord : @"");
    
    if (word)
    {
        WordCardViewController *wordCardViewController = [[WordCardViewController alloc] init];
        wordCardViewController.word = word;
        
        //UIModalTransitionStyleCoverVertical
        //UIModalTransitionStyleCrossDissolve
        //UIModalTransitionStyleFlipHorizontal
        wordCardViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:wordCardViewController animated:YES];
        
        //[wordCardViewController release]; //TODO!!! why crash?
    }
}

- (void)parser:(Parser *)parser didFailWithError:(NSString *)error {
    
    //如果是同步操作的话
    if (parser != self.parser) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] 
                                      initWithTitle:NSLocalizedString (@"提示",@"")
                                      message:NSLocalizedString (@"同步生词本失败",@"")
                                      delegate:self 
                                      cancelButtonTitle:NSLocalizedString (@"确定",@"")
                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        });
        
        return;
    }
}

- (void)didSynchronizeWord:(Word *)aWord {
    
    if (!aWord)
        return;
    
    iWord *newWord = [NSEntityDescription insertNewObjectForEntityForName:@"iWord" 
                                                   inManagedObjectContext:self.context];
    
    newWord.queryTimes = 0;
    newWord.key = aWord.Key;
    newWord.remark = aWord.Description;
    
    if (aWord.AcceptationList != nil && [aWord.AcceptationList count] > 0)
    {
        NSString *key = [[aWord.AcceptationList allKeys] objectAtIndex:0];
        newWord.acceptation = [aWord.AcceptationList valueForKey:key];
    }
    else
    {
        newWord.acceptation = @"";
    }
    
    NSRange range = [aWord.CreateTime rangeOfString:@" "];
    if (range.location != NSNotFound){
        range.length = range.location;
        range.location = 0;
        
        newWord.createDate = [aWord.CreateTime substringWithRange:range];
    }
    else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString* dateString = [dateFormat stringFromDate:[NSDate date]];
        newWord.createDate = dateString;
        [dateFormat release];
    }

    newWord.section = [[aWord.Key substringToIndex:1] uppercaseString];

    //NSError *error;
    /*
    if (![self.context save:&error]) {
        DDLogError([error localizedDescription]);
    }*/
}


#pragma mark -
#pragma mark Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve or create a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"iWordCell"];
    if (!cell) 
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"iWordCell"] autorelease];
    
    // Recover object from fetched results
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = [managedObject valueForKey:@"key"] ? [managedObject valueForKey:@"key"] : NSLocalizedString (@"未命名",@"");
    //cell.textLabel.textColor = [self getColor:[managedObject valueForKey:@"queryTimes"]]; //TODO:根据查询数设置颜色
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.text = [managedObject valueForKey:@"acceptation"] ? [managedObject valueForKey:@"acceptation"] : NSLocalizedString (@"无释义",@"");
    
    // set selection color 
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame]; 
    backgroundView.backgroundColor = SELECTED_BACKGROUND;
    cell.selectedBackgroundView = backgroundView; 
    [backgroundView release];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45.0f;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0 + 10.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [self tableView:self.tableView titleForHeaderInSection:section];
    
    UIImageView *headBgView = [[[UIImageView alloc] init] autorelease];
    headBgView.frame = CGRectMake(0, 15, 120, 32);
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

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // When a row is selected
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *selection = [managedObject valueForKey:@"key"];
    
    if (selection == nil && [selection length] == 0) {
        return;
    }
    
    if (self.parser)
        [self.parser cancel];
    
    self.selectedWord = selection;

    self.parser = [iKnowAPI queryWordOnline:selection delegate:self useCacheFirst:YES];
}


- (void) setBarButtonItems
{
    // right (edit/done) item depends on both edit mode and item count
    int count = [[self.fetchedResultsController fetchedObjects] count];
    if (tableView.isEditing)
        self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(leaveEditMode));
    else
        self.navigationItem.rightBarButtonItem = count ? SYSBARBUTTON(UIBarButtonSystemItemEdit, @selector(enterEditMode)) : nil;
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
        iWord *deleteWord = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (![iKnowAPI deleteWord:deleteWord.key]) {
            DDLogError(@"deleteword from server error\n");
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
    [self.viewDeckController toggleLeftView];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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


- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    if (self.context == nil) {
        self.context = [[[EnglishFunAppDelegate sharedAppDelegate] getClient] getContext];
    }
    
    // Init a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"iWord" 
                                              inManagedObjectContext:self.context];
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

//从生词本中删除
- (BOOL) deleteWord:(NSIndexPath *)indexPath
{
    iWord *deleteWord = (iWord *)[_fetchedResultsController objectAtIndexPath:indexPath];    
    
    //从服务器删除单词
    BOOL result = [iKnowAPI deleteWord:deleteWord.key];
    
    if (!result) {
        DDLogError(@"deleteWord failed.");
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
    UserLoginViewController *viewController = [[UserLoginViewController alloc] init];
    
    [self presentModalViewController:viewController animated:YES];
    
    [viewController release];
}


- (void)dealloc {
    [self.context save:nil];
    
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    
    self.context = nil;
    
    self.word = nil;
    [self.parser cancel];
    self.parser = nil;
    self.selectedWord = nil;
    self.NavBar = nil;
    self.backButton = nil;
    [HUD release];
    
    self.tableView = nil;
    [popupViewController release];
    [userID release];
    
    [dropDownView release];
    [super dealloc];	
}


@end

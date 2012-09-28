//
//  WordCardViewController.m
//  iKnow
//
//  Created by Cube on 11-5-17.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "WordCardViewController.h"

static const int ddLogLevel = LOG_FLAG_ERROR;


@implementation WordCardViewController

@synthesize word = _word;
@synthesize downloaderList;
@synthesize keyLabel, pronLabel, acceptationTableView, sentenceTableView, activityIndicator;
@synthesize favoriteButton, pronunciationButton;
@synthesize descriptionTextField;
@synthesize keyboardRect;
@synthesize context;
@synthesize fetchedResultsController;
@synthesize translator, listen, remarks, favorites, close;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.translator.text = NSLocalizedString(@"翻译",@""); 
    self.listen.text = NSLocalizedString(@"例句",@"");
    self.remarks.text = NSLocalizedString(@"备注",@"");
    self.close.text = NSLocalizedString(@"关闭",@"");
    self.favorites.text = NSLocalizedString(@"收藏",@""); 
    
    NSMutableString *phoneticSymbolString;
    
    if (_word.PhoneticSymbol)
    {
        phoneticSymbolString = [[[NSMutableString alloc] initWithString:@"/"] autorelease];
        [phoneticSymbolString appendFormat:@"%@/", _word.PhoneticSymbol];
    }
    else {
        phoneticSymbolString = @"";
    }
    
    if ([_word.Pronunciation length] < 5) {
        pronunciationButton.enabled = NO;
    }
    
    self.keyLabel.text = _word.Key;
    self.pronLabel.text = phoneticSymbolString;
    
    self.downloaderList = [[NSMutableArray alloc] init];
    [self.downloaderList release];
    
    self.context = [[[EnglishFunAppDelegate sharedAppDelegate] getClient] getContext];
    [self getWords:_word.Key];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    
    isWordFavorite = FALSE;
    
    if ([sectionInfo numberOfObjects] >= 1)
    {
        NSString *key = [[[sectionInfo objects] objectAtIndex:0] valueForKey:@"key"];
        if ([key isEqualToString:_word.Key]) {
            
            self.descriptionTextField.text = [[[sectionInfo objects] objectAtIndex:0] valueForKey:@"remark"];
            
            [favoriteButton setImage:[UIImage imageNamed:@"favourite_on.png"] forState:UIControlStateNormal];
             self.favorites.text = NSLocalizedString(@"已收藏",@""); 
            isWordFavorite = TRUE;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];  
}


-(void) keyboardWillShow:(NSNotification *)notification {
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    keyboardRect = keyboardBounds;
    
    CGRect containerFrame = self.view.frame;
    containerFrame.origin.y = self.view.bounds.size.height + 20 - (keyboardBounds.size.height + containerFrame.size.height);

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    self.view.frame = containerFrame;
    
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)notification{
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    CGRect containerFrame = self.view.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    self.view.frame = containerFrame;

    // commit animations
    [UIView commitAnimations];
}


#pragma mark  touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches 
              withEvent:event];
    
    [descriptionTextField resignFirstResponder];
}

#pragma mark -
#pragma mark DownloaderDelegate

- (void)downloader:(Downloader *)downloader didDownloadData:(NSData *)data {

    if (data == nil)
        return;
    
    if (player != nil)
    {
        [player stop];
        RELEASE_SAFELY(player);
    }
    
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    
    if (!player)
    {
        DDLogError(@"Error: %@", [error localizedDescription]);
        return;
    }
    else {
        [player prepareToPlay];
        [player play];
    }
}

- (void)downloader:(Downloader *)downloader didFailWithError:(NSString *)error{
    DDLogError(@"download audio error");
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == acceptationTableView)
    {
        NSArray *keys = [_word.AcceptationList allKeys];
        if (keys.count == 0)
            return 1;
        
        return keys.count;
    }
    else if (tableView == sentenceTableView)
    {
        return _word.SentenceList.count;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (tableView == acceptationTableView)
    {
        static NSString *CellIdentifier = @"CellAcceptation";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        NSArray *keys = [_word.AcceptationList allKeys];
        NSString *str;
        
        if ([keys count] == 0)
        {
            str = NSLocalizedString(@"暂无翻译", @"");
        } 
        else 
        {
            NSString *key = [keys objectAtIndex:indexPath.row];
            NSString *value = [_word.AcceptationList objectForKey:key];
            str = [[NSString alloc] initWithFormat:@"%@  %@", key, value];
        }

        // Set
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = str;
        [str release];
    }
    else if (tableView == sentenceTableView)
    {
        // Get cell
        static NSString *CellIdentifier = @"CellSentence";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        Sentence *sentence = [_word.SentenceList count] == 0 ? nil : [_word.SentenceList objectAtIndex:indexPath.row];
        // Configure the cell.
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = sentence.Orig ? sentence.Orig : @"";
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.text = sentence.Trans;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == acceptationTableView)
    {
        NSArray *keys = [_word.AcceptationList allKeys];
        NSString *str;
        
        if ([keys count] == 0)
        {
            str = NSLocalizedString(@"暂无翻译", @"");
        } 
        else 
        {
            NSString *key = [keys objectAtIndex:indexPath.row];
            NSString *value = [_word.AcceptationList objectForKey:key];
            str = [[NSString alloc] initWithFormat:@"%@  %@", key, value];
        }
        
        UIFont *cellFont = [UIFont systemFontOfSize:15];
        CGSize constraintSize = CGSizeMake(300.0f, MAXFLOAT);
        CGSize labelSize = [str sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        return labelSize.height + 10;
    }
    else if (tableView == sentenceTableView)
    {
        Sentence *sentence = [_word.SentenceList count] == 0 ? nil : [_word.SentenceList objectAtIndex:indexPath.row];
        UIFont *cellFont = [UIFont systemFontOfSize:15];
        CGSize constraintSize = CGSizeMake(300.0f, MAXFLOAT);
        CGSize origLabelSize = [sentence.Orig sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        CGSize transLabelSize = [sentence.Trans sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        return origLabelSize.height + transLabelSize.height + 10;
    }
    
    return 40.0f;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Downloader *downloader = nil;
    
    if (tableView == sentenceTableView && _word != nil && _word.SentenceList != nil)
    {
        Sentence *sentence = [_word.SentenceList count] == 0 ? nil : [_word.SentenceList objectAtIndex:indexPath.row];
        
        if (sentence.Pron)
        {
            // Download sound data
            Downloader *downloader = [[Downloader alloc] initWithString:sentence.Pron
                                                            delegate:self
                                                      connectionType:ConnectionTypeSynchronously
                                                      downloaderType:DownloaderTypeData];
            
            [downloader download];
            [downloaderList addObject:downloader];
            [downloader release];
        }
    }
}


- (IBAction)favoriteButtonClicked:(UIButton *)sender
{
    if (!isWordFavorite)
    {
        [favoriteButton setImage:[UIImage imageNamed:@"favourite_on.png"] forState:UIControlStateNormal];
        
        self.favorites.text = NSLocalizedString(@"已收藏",@""); 
        if (_word)
        {
            //添加备注
            _word.Description = descriptionTextField.text;
            
            [self addWord:_word];
        }
    }
    else 
    {
        [favoriteButton setImage:[UIImage imageNamed:@"favourite_off.png"] forState:UIControlStateNormal];
        self.favorites.text = NSLocalizedString(@"收藏",@""); 
        [self deleteWord];
    }
}

- (IBAction)closeCard:(id)sender
{
    if (player)
        [player stop];
   
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

- (IBAction)pronunce:(id)sender
{
    if (_word == nil || _word.Pronunciation == nil)
        return;
    
    // Download sound data
    Downloader *downloader = [[Downloader alloc] initWithString:_word.Pronunciation
                                                    delegate:self
                                              connectionType:ConnectionTypeSynchronously
                                              downloaderType:DownloaderTypeData];
    downloader.useCacheFirst = YES;
    [downloader download];
    [downloaderList addObject:downloader];
    
    [downloader release];
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
}


#pragma mark -
#pragma mark CoreData
- (void) getWords:(NSString *)query
{
    // Init a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"iWord" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Apply an ascending sort for items
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES selector:nil];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    // Recover query
    if (query && query.length) 
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"key ==[cd] %@", query];
    
    // Init the fetched results controller
    NSError *error;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] 
                                     initWithFetchRequest:fetchRequest 
                                     managedObjectContext:self.context 
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController release];
    if (![[self fetchedResultsController] performFetch:&error])    
        DDLogError(@"Error: %@", [error localizedDescription]);
    
    [fetchRequest release];
    [sortDescriptor release];
}

- (BOOL) addWord:(Word *)newWord
{
    if (newWord == nil) 
        return FALSE;
    
    // build a new iWord and set its field
    iWord *word = (iWord *)[NSEntityDescription 
                            insertNewObjectForEntityForName:@"iWord" 
                            inManagedObjectContext:self.context];
    word.key = newWord.Key;
    word.remark = newWord.Description;
    
    if ( newWord.AcceptationList != nil && [newWord.AcceptationList count] > 0)
    {
        NSString *key = [[newWord.AcceptationList allKeys] objectAtIndex:0];
        word.acceptation = [newWord.AcceptationList valueForKey:key];
    }
    else {
        word.acceptation = @"";
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString* dateString = [dateFormat stringFromDate:date];
    word.createDate = dateString;
    
    word.section = [[newWord.Key substringToIndex:1] uppercaseString];
    
    [dateFormat release];
    
    //同步单词
    BOOL result = [iKnowAPI addWord:newWord];
    
    if (!result) {
        DDLogError(@"addWord failed.");
    }
    
    // save the new item
    NSError *error; 
    if (![self.context save:&error])
    {
        DDLogError(@"Error: %@", [error localizedDescription]);
        
        [self getWords:_word.Key];
        return NO;
    }
    else {
        [self getWords:_word.Key];
        isWordFavorite = TRUE;
        
        return YES;
    }
}

- (BOOL) deleteWord
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    if ([sectionInfo numberOfObjects] == 0) {
        
        [self getWords:_word.Key];
        return TRUE;
    }
    
    //从服务器删除单词
    BOOL result = [iKnowAPI deleteWord:_word.Key];
    
    if (!result) {
        DDLogError(@"addWord failed.");
    }
    
    NSError *error = nil;
    [self.context deleteObject:[[sectionInfo objects] objectAtIndex:0]];
    if (![self.context save:&error])
    {
        DDLogError(@"Error: %@", [error localizedDescription]);
        [self getWords:_word.Key];
        return FALSE;
    }
    else {
        [self getWords:_word.Key];
        isWordFavorite = FALSE;
        
        return TRUE;
    }
}


- (void)dealloc {
    
    [_word release];
    self.keyLabel = nil;
    self.pronLabel = nil;
    self.acceptationTableView = nil;
    self.sentenceTableView = nil;
    self.activityIndicator = nil;
    self.favoriteButton = nil;
    self.pronunciationButton = nil;
    self.descriptionTextField = nil;
    
    self.context = nil;
    self.fetchedResultsController = nil;
    
    self.translator = nil;
    self.listen = nil;
    self.remarks = nil;
    self.favorites =nil;
    self.close = nil;
    
    for (Downloader *downloader in downloaderList) {
        [downloader cancel];
    }
    self.downloaderList = nil;
    
    [super dealloc];
}


@end

//
//  RightViewController.m
//
//
//  Created by Marcel Dierkes on 04.12.11.
//  Copyright (c) 2011 iKnow Team. All rights reserved.
//

#import "RightViewController.h"
#import "MainViewController.h"

@implementation RightViewController

@synthesize tagList, tableViewCell, tableViewCellNib, tableView;



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tagList = [NSArray arrayWithObjects:@"VOA Special", TAG_ARRAY, nil];
    self.tableViewCellNib = [UINib nibWithNibName:@"TagTableViewCell" bundle:nil];
    self.tableView.scrollsToTop = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    self.tagList = nil;
    
    RELEASE_SAFELY(tableViewCell);
    RELEASE_SAFELY(tableViewCellNib);
    
    self.tableView = nil;
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return [tagList count];
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == section)
        return NSLocalizedString (@"全部栏目",@"");
    else {
        return @"";
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0 + 10.0;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagTableViewCell";
    
    TagTableViewCell *cell = (TagTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:CellIdentifier
                                                      owner:nil options:nil];
        
        for (id item in nibs) {
            if ([item isKindOfClass:[UITableViewCell class]]) {
                cell = item;
                break;
            }
        }
    }
    
    [cell setBackgroundImage:nil];
    
    // Configure the data for the cell.
    NSString *tag = @"";
    
    if (indexPath.section == 0) {
        tag = [tagList count] == 0 ? @"" : [tagList objectAtIndex:indexPath.row];
    }
    
    NSString *imageFileName = @"tag.png";
    
    [cell setIcon:[UIImage imageNamed:imageFileName]];
    [cell setName:tag];
    
    // set selection color 
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame]; 
    backgroundView.backgroundColor = TAG_SELECTED_BACKGROUND;
    cell.selectedBackgroundView = backgroundView; 
    [backgroundView release];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MainViewController* mainController = [[EnglishFunAppDelegate sharedAppDelegate] mainViewController];
    [mainController setArticleTag:[self.tagList objectAtIndex:indexPath.row]];
    
    self.viewDeckController.centerController = [[EnglishFunAppDelegate sharedAppDelegate] centerViewController];
    [self.viewDeckController toggleRightView];
    
    // Deselect
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

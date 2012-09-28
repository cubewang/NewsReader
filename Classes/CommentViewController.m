//
//  CommentViewController.m
//  iKnow
//
//  Created by Cube on 11-4-24.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "CommentViewController.h"
#import "BubbleTableView.h"
#import "UserLoginViewController.h"

#import "CommentCell.h"
#import "XMPPiKnowUserModule.h"


@implementation CommentViewController

@synthesize articleId, commentItems;

@synthesize commentTextField, tableView, navBar; 

- (XMPPiKnowUserModule *)getUserModule
{
    return [[[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient] xmppiKnowUserModule];
}


//开始登录或者注册
- (void)loginOrRegisterUser
{
    UserLoginViewController *viewController = [[UserLoginViewController alloc] init];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    // Super
    [super viewDidLoad];
    
    self.navBar.tintColor = NAV_BAR_ITEM_COLOR;
    if ([self.navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.navBar setBackgroundImage:[UIImage imageNamed:@"NavBar_ios5.png"] forBarMetrics:UIBarMetricsDefault];
        }
        else {
            [self.navBar setBackgroundImage:[UIImage imageNamed:@"mainViewNavBar_iPad.png"] forBarMetrics:UIBarMetricsDefault];
        }
    }
    
    self.navBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.navBar.layer.shadowRadius = 3.0f;
    self.navBar.layer.shadowOpacity = 0.8f;
    
    CGRect rect = CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT - 104);
    tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain]; 
    tableView.delegate = self; 
    tableView.dataSource = self;
    tableView.backgroundColor = CELL_BACKGROUND;
    [tableView reloadData];
    
    self.tableView.allowsSelection = NO;

    [self.view insertSubview:tableView atIndex:0];
    
    commentTextField = [[ZTextField alloc] init];
    commentTextField.delegate = self;
    [commentTextField setView:self.view];
    commentTextField.brotherView = tableView;
    
    [self.view addSubview:commentTextField];
    
    //如果已经请求过了立即返回
    if (parserList != nil)
        return;


    self.commentItems = [[NSMutableArray alloc] init];
    [commentItems release];

    if (!parserList)
        parserList = [[NSMutableArray alloc] init];
    
    isRequestingData = YES;
    Parser *parser = [iKnowAPI getCommentList:articleId delegate:self useCacheFirst:NO];
    [parserList addObject:parser];
    
    [[iKnowAPI getUserModule] addDelegate:self 
                            delegateQueue:dispatch_get_main_queue()];
}

- (void)viewDidUnload {
    self.tableView = nil;
    
    [super viewDidUnload];
}

#pragma mark -
#pragma mark ParserDelegate

- (void)parser:(Parser *)parser didParseComment:(Comment *)comment {
    
    if (comment)
    {
        [commentItems addObject:comment];
    }
}


- (void)parserDidFinish:(Parser *)parser {
    
    isRequestingData = NO;

    [tableView reloadData];
}

- (void)parser:(Parser *)parser didFailWithError:(NSString *)error {
    
    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showNetworkFailed:self.view];
}

#pragma mark -
#pragma mark Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return commentItems.count == 0 ? 1 : commentItems.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //如果发现没有评论
    if ([commentItems count] == 0) {

        UITableViewCell *cell = nil;
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        //获取数据中
        if (!isRequestingData) 
        {
            UIButton *addCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 1, SCREEN_WIDTH - 20, 40)];
            [addCommentButton setTitle:NSLocalizedString(@"暂无评论，抢先发表",@"" ) forState:UIControlStateNormal];
            [addCommentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

            [cell addSubview:addCommentButton];
            
            [addCommentButton release];
        }
        else {
            cell.text = NSLocalizedString(@"加载评论中...",@"" );
        }

        return cell;
    }

    CommentCell *commentCell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    
    if (commentCell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CommentCell"
                                                      owner:nil options:nil];
        
        for (id item in nibs) {
            if ([item isKindOfClass:[UITableViewCell class]]) {
                commentCell = item;
                break;
            }
        }
    }
    
    //UITableViewCell *commentCell = nil;
    
    //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell.
    Comment *comment = [commentItems count] == 0 ? nil : [commentItems objectAtIndex:indexPath.row];
    if (comment) 
    {
        if ([comment.UserId length]) {
            NSDictionary *userInfo =  
            [[self getUserModule] queryLocalUserInfoWithUserID:comment.UserId];
            
            if (userInfo == nil) {
                [[self getUserModule] queryUserInfoWithUserID:comment.UserId];
            }
            else {
                comment.avatarImagePath = [userInfo objectForKey:@"photoUrl"];
                comment.avatarImagePath = [iKnowAPI getThumbImageServerPath:comment.avatarImagePath 
                                                                  thumbWidh:[[UIScreen mainScreen] scale] * 40];
            }
            
        }
        
        [commentCell setDataSource:comment];
    }
    
    return commentCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (commentItems == nil || [commentItems count] == 0) {
        return 45;
    }
    
    Comment *comment = [commentItems objectAtIndex:indexPath.row];
    
    return [CommentCell heightForCell:comment];
}


#pragma mark -
#pragma mark Table view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [commentTextField resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [commentTextField resignFirstResponder];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


-(void) BubbleTableViewBeginTouches {
    [commentTextField resignFirstResponder];
}

#pragma mark ZTextFieldDelegate

- (void)ZTextFieldButtonDidClicked:(ZTextField *)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"请稍候...", @"");
    
    NSString *str = [[commentTextField.textView.text copy] autorelease];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        BOOL bRes = [self sendCommentForArticleID:articleId andText:str];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (bRes)
            {
                commentTextField.textView.text = @"";
                [self refreshComments];
                [commentTextField.textView resignFirstResponder];
            }
        });
    });
}

#pragma mark  UI Actions

- (IBAction) closeContent:(id)sender
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

- (void)addCommentFinished:(BOOL)result
{
    if (result) {
        [self refreshComments];
    }
}

- (BOOL)sendCommentForArticleID:(NSString *)theId andText:(NSString *)text 
{
    //每次发表评论，我们都重新绑定session
    iKnowXMPPClient *xmppClient = [[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient];
    [xmppClient bindSessionSync:YES];
    
    return [iKnowAPI submitComment:theId comment:text];
}

- (void)refreshComments
{
    [commentItems removeAllObjects];

    Parser *parser = [iKnowAPI getCommentList:articleId delegate:self useCacheFirst:NO];
    
    [parserList addObject:parser];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [[iKnowAPI getUserModule] removeDelegate:self];
    
    self.articleId = nil;
    
    self.navBar = nil;
    
    for (Parser *parser in parserList) {
        [parser cancel];
    }
    RELEASE_SAFELY(parserList);
    
    self.commentItems = nil;
    
    commentTextField.delegate = nil;
    RELEASE_SAFELY(commentTextField);
    
    RELEASE_SAFELY(tableView);
    
    [super dealloc];
}

#pragma mark XMPPiKnowUserModule

- (void)xmppiKnowUserModule:(XMPPiKnowUserModule *)sender 
                queryFinish:(NSDictionary *)userDic
{
    [self.tableView reloadData];
}

@end

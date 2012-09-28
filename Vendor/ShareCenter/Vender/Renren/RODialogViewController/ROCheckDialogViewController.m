//
//  ROCheckDialogViewController.m
//  RenrenSDKDemo
//
//  Created by xiawh on 11-10-17.
//  Copyright 2011年 renren-inc. All rights reserved.
//

#import "ROCheckDialogViewController.h"
 
 

@implementation ROCheckDialogViewController
@synthesize orderView = _orderView;
@synthesize result = _result;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.orderView = [[[UITableView alloc] initWithFrame:[self fitOrientationFrame]] autorelease];
        self.orderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.orderView];
        self.orderView.delegate = self;
        self.orderView.dataSource = self;
        self.orderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.orderView.frame.size.width, 32)];
        headerView.backgroundColor = [UIColor colorWithRed:0.0 green:94.0/255.0 blue:172.0/255.0 alpha:1.0];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PayLogo.png"]];
        imageView.frame = CGRectMake(0, 0, 98, 32);
        [headerView addSubview:imageView];
        [imageView release];
        
        self.orderView.tableHeaderView = headerView;
        [headerView release];
    }
    return self;
}

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

 

#pragma mark - UITableViewDatasource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.result.count;
}

 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)dealloc
{
    self.orderView = nil;
    self.result = nil;
    [super dealloc];
}

@end

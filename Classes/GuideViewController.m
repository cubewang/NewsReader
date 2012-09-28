    //
//  GuideViewController.m
//  PageScrollSample
//

#import "GuideViewController.h"
 

#define SPACE_WIDTH 20
#define CONTENT_SIZEHEIGHT 480
#define CONTENT_NUM 2
#define CONTENT_SIZEWEIGHT 320

@implementation GuideViewController

@synthesize scrollView ;
@synthesize isChangeAction;
@synthesize pageControl;
 
- (void)dealloc
{
    [scrollView release];
    [pageControl release];
    
    [super dealloc];
}
 
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.view.backgroundColor = GUIDE_VIEW_COLOR;
    
    CGRect frame = CGRectMake(0, 0, CONTENT_SIZEWEIGHT, 480);
    self.scrollView = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
    self.scrollView.clipsToBounds = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    [self.view addSubview:self.scrollView];
    
    NSInteger contentWidth = self.scrollView.frame.size.width - SPACE_WIDTH;
    for (int i = 0; i < CONTENT_NUM; ++i) {
        CGRect frame = {(contentWidth + SPACE_WIDTH) * i, 0, CONTENT_SIZEWEIGHT, CONTENT_SIZEHEIGHT};

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];

        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"guide%d", i] ofType:@"png"];
        
        imageView.image = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
        
        [self.scrollView addSubview:imageView];
         
        [imageView release];
    }
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(140, 400, 60, 30)];  //创建UIPageControl，位置在屏幕最下方
    self.pageControl.numberOfPages = CONTENT_NUM;
    self.pageControl.currentPage = 0;
    
    [self.pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];  //将UIPageControl添加到主界面上。
    [self.pageControl release];
    
    self.scrollView.contentSize = CGSizeMake((contentWidth + SPACE_WIDTH) * CONTENT_NUM, CONTENT_SIZEHEIGHT);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.scrollView = nil;
    self.pageControl = nil;
}
 
- (void)loginAction {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
 
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:1.0];
    
    [UIView commitAnimations];
    
    [self.view removeFromSuperview];
}

- (void)back {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)ascrollView
{
    //更新UIPageControl的当前页
    CGPoint offset = ascrollView.contentOffset;
    CGRect bounds = ascrollView.frame;
    [pageControl setCurrentPage:offset.x / bounds.size.width];
    if (pageControl.currentPage == 1) {
        if (isChangeAction) {
            [self back];
        }
        else 
            [self loginAction]; 
    }
}

- (void)pageTurn:(UIPageControl*)sender
{
    //令UIScrollView做出相应的滑动显示
    CGSize viewSize = scrollView.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [scrollView scrollRectToVisible:rect animated:YES];
}

@end

//
//  ShareViewController.m
//  iKnow
//
//  Created by cg on 12-3-16.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import "ShareViewController.h"
#import "CUShareClient.h"
#import "UIImageView+WebCache.h"
#import "StringUtils.h"
#import "Article.h"

#define SINA_POST_COUNT 140
#define TTWEIBO_POST_COUNT 140
#define RENREN_POST_COUNT  100


@implementation ShareViewController

@synthesize countLabel;
@synthesize navBar;
@synthesize postTextView;
@synthesize postImageView;
@synthesize shareText;
@synthesize postImage;
@synthesize postImageURL;
@synthesize shareArticleName;
@synthesize bindingLabel;
@synthesize article;
 
- (id)initWithShareText:(NSString *)text andImage:(UIImage *)image andType:(CUShareClientType)type
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        self.shareText = text;
        self.postImage = image;
        
        shareType = type;
        
        if (type == SINACLIENT) {
            maxUnitCount = SINA_POST_COUNT;
        }
        else if (type == RENRENCLIENT) {
            maxUnitCount = RENREN_POST_COUNT;
        }
        else if (type == TTWEIBOCLIENT) {
            maxUnitCount = TTWEIBO_POST_COUNT;
        }
        
        unitCharCount = 2;
    }
    
    return self;
}

-(void)dealloc {
    
    [postTextView release];
    [shareText release];
    [countLabel release];
    [navBar release];
    [bindingLabel release];
    
    
    self.postImage = nil;
    self.shareArticleName = nil;
    self.postImageURL = nil;
    self.postImageView = nil;
    self.article = nil;
   
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)calInputNumber
{
    int unitCount = ceil((float)[StringUtils charCountOfString: self.postTextView.text]/(float)unitCharCount);
    
    if (unitCount <= maxUnitCount) {
         
        self.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"还可输入%d个字", @""), (maxUnitCount - unitCount)];
        self.countLabel.textColor = [UIColor blackColor];
    }else {
        
        self.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"已超过%d个字", @""), (unitCount - maxUnitCount)];
        self.countLabel.textColor = [UIColor redColor];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self calInputNumber];
    [self showTitle];
        
    postTextView.layer.cornerRadius = 5;
    postTextView.clipsToBounds = YES;
    [postTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]]; 
    [postTextView.layer setBorderWidth:2.0];
    
    [self.postImageView setImageWithURL:[NSURL URLWithString:self.postImageURL]
                       placeholderImage:self.postImage];
    self.postTextView.text = self.shareText;
    
    self.navBar.tintColor = NAV_BAR_ITEM_COLOR;
    if ([self.navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navBar setBackgroundImage:[UIImage imageNamed:@"NavBar_ios5.png"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[[CUShareCenter sharedInstanceWithType:SINACLIENT] shareClient] addDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:RENRENCLIENT] shareClient] addDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:TTWEIBOCLIENT] shareClient] addDelegate:self];
    
    [self calInputNumber];
    [self changeBindingLabel];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[[CUShareCenter sharedInstanceWithType:SINACLIENT] shareClient] removeDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:RENRENCLIENT] shareClient] removeDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:TTWEIBOCLIENT] shareClient] removeDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.navBar = nil;
    self.postTextView = nil;
    self.postImage = nil;
    self.countLabel = nil;
    self.bindingLabel = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showTitle {
    
    if (shareType == SINACLIENT) {
        
        self.navBar.topItem.title = NSLocalizedString(@"分享到新浪微博", @"");
    }
    else if (shareType == RENRENCLIENT){
        
        self.navBar.topItem.title = NSLocalizedString(@"分享到人人网", @"");
    }
    else if (shareType == TTWEIBOCLIENT){
        
        self.navBar.topItem.title = NSLocalizedString(@"分享到腾讯微博", @"");
    }
}

- (void)changeBindingLabel {
    
    if ([[CUShareCenter sharedInstanceWithType:shareType] isBind]) {
        
        self.bindingLabel.text = NSLocalizedString(@"帐号已绑定", @"");
        self.bindingLabel.textColor = [UIColor blackColor];
    } 
    else {
        self.bindingLabel.text = NSLocalizedString(@"帐号未绑定", @"");
        self.bindingLabel.textColor = [UIColor redColor];  
    }
}

#pragma mark  touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches 
              withEvent:event];
    
    [postTextView resignFirstResponder];
}

#pragma buttonAction 

- (IBAction)bindingButtonAction {
    if (![[CUShareCenter sharedInstanceWithType:shareType] isBind]) {
        
        [[CUShareCenter sharedInstanceWithType:shareType] Bind:self];
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                           message:NSLocalizedString(@"解除帐号绑定吗？", @"")
                                                          delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"取消", @"")
                                                  otherButtonTitles:NSLocalizedString(@"确定", @""), nil];
        [alertView show];
        [alertView release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
         [[CUShareCenter sharedInstanceWithType:shareType] unBind];
        
        BOOL bBind = [[CUShareCenter sharedInstanceWithType:shareType] isBind];
        NSString *text = !bBind ? NSLocalizedString(@"取消成功", @""):NSLocalizedString(@"取消失败", @"");
        
        if ([text length]) {
            [[[EnglishFunAppDelegate sharedAppDelegate] getClient] showInformation:nil 
                                                                         info:text];
        }
        
        if (!bBind) {
            [self changeBindingLabel];
        }
    }
 
}

- (IBAction)back {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)share {
    
    if ([[CUShareCenter sharedInstanceWithType:shareType] isBind])
    {
        [[[EnglishFunAppDelegate sharedAppDelegate] getClient] 
         showPopProgress:self.view.window andText:nil];
    }
    else
    {
        [[CUShareCenter sharedInstanceWithType:shareType] Bind:self];
        return;
    }
    
    if (shareType == RENRENCLIENT) {
        
        CURenrenShareClient *renren = (CURenrenShareClient *)[[CUShareCenter sharedInstanceWithType:RENRENCLIENT] shareClient];
        
        if (![renren isKindOfClass:[CURenrenShareClient class]]) {
            
            [[[EnglishFunAppDelegate sharedAppDelegate] getClient] hidePopProgress:NO andText:@""];
            
            return;
        }
        
        NSString *shareUrl    = [iKnowAPI getShareArticlePath:article.Id];
        NSString *articleName = [article.Name length] ? article.Name : @" ";
        NSString *description = nil;
        NSString *caption     = [article.UserName length] ? article.UserName : @" ";   
        
        if ([article.Description length] == 0) {
            description = @" ";
        }
        else {
            description = [StringUtils trimString:article.Description toCharCount:RENREN_POST_COUNT];
        }
        
        NSString *imagePath = SAFE_STRING(article.SourceImageUrl); 
        NSString *articleShort = [StringUtils trimString:articleName toCharCount:25];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       shareUrl, @"url",
                                       articleShort, @"name",
                                       @"iKnow英语", @"action_name",
                                       @"http://192.168.1.108/", @"action_link",
                                       description, @"description",
                                       caption, @"caption",
                                       imagePath, @"image",
                                       nil];
        
        [renren sendWithDictionary:params];
    }
    else if (shareType != SINACLIENT) {
        [[CUShareCenter sharedInstanceWithType:shareType] sendWithText:self.postTextView.text 
                                                     andImageURLString:self.postImageURL];
    }
    else {
        [[CUShareCenter sharedInstanceWithType:shareType] sendWithText:self.postTextView.text 
                                                              andImage:self.postImageView.image];
    }
}

- (void)CUAuthFailed:(CUShareClient *)client withError:(NSError *)error
{
    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] hidePopProgress:NO andText:NSLocalizedString(@"认证失败", @"")];
}

- (void)CUShareFailed:(CUShareClient *)client withError:(NSError *)error
{
    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] hidePopProgress:NO andText:NSLocalizedString(@"分享失败", @"")];
    
    if ([client isKindOfClass:[CUSinaShareClient class]]) {
        
        NSDictionary *dic = [error userInfo];
        if ([[dic objectForKey:@"error_code"] intValue] == 21327) {
            //expired_token
            [[CUShareCenter sharedInstanceWithType:SINACLIENT] Bind:self];
        }
    }
}

- (void)CUShareSucceed:(CUShareClient *)client
{
    [[[EnglishFunAppDelegate sharedAppDelegate] getClient] hidePopProgress:YES andText:NSLocalizedString(@"分享成功", @"")];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    [self calInputNumber];
}

@end

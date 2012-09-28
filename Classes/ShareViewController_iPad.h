//
//  ShareViewController_iPad.h
//  Popovers
//
//  Created by curer yg on 12-3-19.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUShareCenter.h"

#import "CUSinaShareClient.h"
#import "CURenrenShareClient.h"
#import "CUShareCenter.h"
#import "CUTencentShareClient.h"


@class Article;

@interface ShareViewController_iPad : UIViewController <CUShareClientDelegate,UITextViewDelegate>
{
    IBOutlet UINavigationBar  *navBar;
    
    UILabel      *bindingLabel;
    UITextView   *postTextView;
    UILabel      *countLabel;
    UIImageView  *postImageView;
    
    NSString *shareText;
    NSString *shareArticleName;
    
    CUShareClientType shareType;
    
    CGRect keyboardRect;
    BOOL bKeyBoardShow;
    
    int maxUnitCount;
    int unitCharCount;
    
    Article *article;
}

@property (nonatomic, retain) IBOutlet UITextView *postTextView;
@property (nonatomic, retain) IBOutlet UILabel *countLabel;
@property (nonatomic, retain) IBOutlet UIImageView *postImageView;
@property (nonatomic, retain) IBOutlet UILabel  *bindingLabel;
@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, retain) NSString *postImageURL;
@property (nonatomic, retain) NSString *shareArticleName;
@property (nonatomic, copy)   NSString *shareText;
@property (nonatomic, retain) UIImage  *postImage;

@property (nonatomic, retain) Article *article;

- (id)initWithShareText:(NSString *)text andImage:(UIImage *)image andType:(CUShareClientType)type;

- (IBAction) back;
- (IBAction) share;
- (IBAction) bindingButtonAction;
- (void) showTitle;
- (void) changeBindingLabel;
- (void) calInputNumber;
@end

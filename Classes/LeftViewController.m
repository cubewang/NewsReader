 //
//  LeftViewController.m
//  EnglishFun
//
//  Created by curer on 11-12-25.
//  Copyright 2011 iKnow Team. All rights reserved.
//
#import "LeftViewController.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "iKnowXMPPClient.h"
#import "XMPPiKnowUserModule.h"
#import "PictureManager.h"
#import "FileTransferEx.h"
#import "MemberCoreDataObject.h"

#import "IIViewDeckController.h"

#import "MainViewController.h"
#import "ProfileViewController.h"
#import "SettingViewController.h"
#import "FavoritesViewController.h"
#import "WordsViewController.h"


@implementation LeftViewController

@synthesize tableView;
@synthesize nickNameLabel;
@synthesize avatarImageView;

- (XMPPiKnowUserModule *)getUserModule
{
    return [[[EnglishFunAppDelegate sharedAppDelegate] getXMPPClient] xmppiKnowUserModule];
}

- (void)showMainViewController
{
    self.viewDeckController.centerController = [[EnglishFunAppDelegate sharedAppDelegate] centerViewController];
    [self.viewDeckController toggleLeftView];
}

- (void)showSetting
{
    SettingViewController *viewController = [[SettingViewController alloc] init];
    
    self.viewDeckController.centerController = viewController;
    
    [viewController release];
    
    [self.viewDeckController toggleLeftView];
}

- (void)showWord
{
    WordsViewController *viewController = [[WordsViewController alloc] init];
    
    self.viewDeckController.centerController = viewController;
    
    [viewController release];
    
    [self.viewDeckController toggleLeftView];
}

- (void)showFavorite
{
    FavoritesViewController *viewController = [[FavoritesViewController alloc] init];
    
    self.viewDeckController.centerController = viewController;
    
    [viewController release];
    
    [self.viewDeckController toggleLeftView];
}

- (void)refresh
{
    NSDictionary *userInfo = [[self getUserModule] queryLocalUserInfo];
    
    NSString *nickName = [userInfo objectForKey:@"nickName"];
    nickName = [nickName length] ? nickName :NSLocalizedString(@"点击设置昵称", @"");
    self.nickNameLabel.text = nickName;
    [self.avatarImageView setImageWithURL:[userInfo objectForKey:@"photoUrl"] 
                         placeholderImage:[UIImage imageNamed:@"Avatar1.png"]];
}

#pragma mark -
#pragma mark Initialization


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect rc = self.view.frame;
    rc.origin.y = 0;
    self.view.frame = rc;

    [[self getUserModule] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSDictionary *userInfo = [[self getUserModule] queryLocalUserInfo];
    
    NSString *nickName = [userInfo objectForKey:@"nickName"];
    
    nickName = [nickName length] ? nickName : NSLocalizedString(@"点击设置昵称", @"");
    self.nickNameLabel.text = nickName;
    [self.avatarImageView setImageWithURL:[userInfo objectForKey:@"photoUrl"] 
                         placeholderImage:[UIImage imageNamed:@"Avatar1.png"]];
    
    homeLabel.text = NSLocalizedString(@"首页", @"");
    myFavorites.text = NSLocalizedString(@"我的收藏", @"");
    myWord.text = NSLocalizedString(@"我的生词", @"");
    setting.text = NSLocalizedString(@"设置", @"");
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
    
    [[self getUserModule] removeDelegate:self];
    [tableView release];
    [nickNameLabel release];
    [avatarImageView release];
    
    [super dealloc];
}

#pragma mark userAvator

- (void)nameButtonDidClicked:(id)sender
{
    
}

- (void)userAvatorButtonDidClicked:(id)sender
{
    if (![Client userHasRegistered]) {
        [[EnglishFunAppDelegate sharedAppDelegate] loginOrRegisterUser:nil];
        
        return;
    }
    
    UIActionSheet *actionSheet = nil;
    
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera]) 
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString (@"选择你的头像",@"")
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString (@"取消",@"")
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString (@"图库",@""),nil
                       ];
        actionSheet.tag = 1;//表示没有摄像头
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString (@"选择你的头像",@"")
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString (@"取消",@"")
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString (@"图库",@""),NSLocalizedString (@"拍照",@""), nil
                       ];
    }
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        
        [[[EnglishFunAppDelegate sharedAppDelegate] mainViewController] presentModalViewController:picker animated:YES];
        
        [picker release];
    }
    else if (buttonIndex == 1 && actionSheet.tag == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [[[EnglishFunAppDelegate sharedAppDelegate] mainViewController] presentModalViewController:picker animated:YES];
        
        [picker release];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    UIImage* thumbImage = [PictureManager scaleAndRotateImage:image andMaxLen:200];
    
    //this for avatar
    NSData *imageData = UIImageJPEGRepresentation(thumbImage, 0.4); 
    
    NSString *fileName = [NSString stringWithFormat:@"%@", [XMPPStream generateUUID]];
    
    NSString *filePath = [[EnglishFunAppDelegate getImagePathInDocument] stringByAppendingPathComponent:fileName];
    
    BOOL bRes = [imageData writeToFile:filePath atomically:YES];
    
    if (bRes) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            NSString *serverPath = 
            [FileTransferEx uploadFileSyncAndGetResourcePath:filePath 
                                                     andType:FileTransferTypeImage];
            
            BOOL bSuccess = NO;
            if ([serverPath length]) {
                NSString *urlPath = [iKnowAPI getDownloadFilePath:serverPath];
                bSuccess = [[self getUserModule] setUserInfoWithObjectSync:urlPath 
                                                                    andKey:@"photoUrl"];
            }
            
            hud.labelText = bSuccess ? NSLocalizedString (@"修改头像成功",@"") : NSLocalizedString (@"修改头像成功",@"");
            
            if (bSuccess) {
                hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
                hud.mode = MBProgressHUDModeCustomView;
            }
            else {
                hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete.png"]] autorelease];
                hud.mode = MBProgressHUDModeCustomView;
            }
            
            sleep(1);
            
            // Hide the HUD in the main tread 
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (bSuccess) {
                    NSString *urlPath = [iKnowAPI getDownloadFilePath:serverPath];
                    [self.avatarImageView setImageWithURL:[NSURL URLWithString:urlPath] 
                                         placeholderImage:[UIImage imageNamed:@"Avatar1.png"]];
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }
    
    // close the modal view
    [picker dismissModalViewControllerAnimated:YES];
    
}

#pragma mark XMPPiKnowUserModule

- (void)xmppiKnowUserModule:(XMPPiKnowUserModule *)sender 
            userInfoChanged:(MemberCoreDataObject *)memberCoreDataObject
{
    XMPPJID *jid = [iKnowXMPPClient getJID];
    if ([[jid user] isEqualToString:memberCoreDataObject.userId]) {
        [self refresh];
    }
}

@end



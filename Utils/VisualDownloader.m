//
//  VisualDownloader.m
//  iKnow
//
//  Created by Sdhjt on 11-5-12.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisualDownloader.h"

#define DELEGATE_CALLBACK(X, Y) if (self.delegate && [self.delegate respondsToSelector:@selector(X)]) [self.delegate performSelector:@selector(X) withObject:Y];

#define CANCEL_BUTTON_NAME @"close.png"

@implementation VisualDownloader

- (void)start
{
    if (_fileURL == nil) {
        
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_fileURL];
    self.urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (_urlConnection) {
        [self createProgressAlertWithMessage:_title];
    }
}

- (void)createProgressAlertWithMessage:(NSString *)message 
{    
    self.progressAlertView = [[UIAlertView alloc] initWithTitle:message
                                                        message:NSLocalizedString(@"请稍候...",@"")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
    
    // Create the progress bar and add it to the alert
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)];
    [_progressView setProgressViewStyle:UIProgressViewStyleBar];
    [_progressAlertView addSubview:_progressView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 90.0f, 225.0f, 40.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.text = @"";
    label.tag = 120;
    label.textAlignment = UITextAlignmentCenter;
    
    [_progressAlertView addSubview:label];
    [label release];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(235, 4, 38, 37)];
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setImage:[UIImage imageNamed:CANCEL_BUTTON_NAME] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelLoadAction:) forControlEvents:UIControlEventTouchUpInside];
    [_progressAlertView addSubview:cancelButton];
    [cancelButton release];
    
    [_progressAlertView show];
}

-(void)cancelLoadAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(visualDownloaderCancel)]) {
        [_delegate visualDownloaderCancel];
    }
    
    if (_urlConnection == nil) {
        return;
    }
    
    [_urlConnection cancel];
    
    NSError *error;
    NSString *filePath = [NSString stringWithFormat:@"%@", _fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }
    
    [_progressAlertView dismissWithClickedButtonIndex:0 animated:YES];

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    self.currentSize = 0;
    self.totalFileSize = [NSNumber numberWithLongLong:[response expectedContentLength]];
    
    // Check for bad connection
    if ([response expectedContentLength] < 0)
    {
        NSString *reason = [NSString stringWithFormat:@"Invalid URL [%@]", [_fileURL absoluteString]];
        DELEGATE_CALLBACK(visualDownloaderDidFail:, reason);
        [connection cancel];
        
        return;
    }
    
    if ([response suggestedFilename])
        DELEGATE_CALLBACK(downloadManagerDidReceiveData:, [response suggestedFilename]);
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    self.currentSize = self.currentSize + [data length];
    NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:self.currentSize];
    
    NSNumber *progress = [NSNumber numberWithFloat:([resourceLength floatValue] / [_totalFileSize floatValue])];
    self.progressView.progress = [progress floatValue];
    
    const unsigned int bytes = 1024 ;
    UILabel *label = (UILabel *)[_progressAlertView viewWithTag:120];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setPositiveFormat:@"##0.00"];
    
    NSNumber *partial = [NSNumber numberWithFloat:([resourceLength floatValue] / bytes)];
    NSNumber *total = [NSNumber numberWithFloat:([_totalFileSize floatValue] / bytes)];
    label.text = [NSString stringWithFormat:@"%@ KB / %@ KB", [formatter stringFromNumber:partial], [formatter stringFromNumber:total]];
    [formatter release];
    
    [self writeToFile:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    [_progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)writeToFile:(NSData *)data
{
    NSString *filePath = [NSString stringWithFormat:@"%@", _fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO)
    {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    FILE *file = fopen([_fileName UTF8String], [@"ab+" UTF8String]);
    if(file != NULL)
    {
        fseek(file, 0, SEEK_END);
        
        int readSize = [data length];
        fwrite((const void *)[data bytes], readSize, 1, file);
    }
    
    fclose(file);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self close];
}

- (UILabel *)label
{
    return (UILabel *)[_progressAlertView viewWithTag:120]; 
}

- (void)close
{
    if ([_delegate respondsToSelector:@selector(visualDownloaderDidFinish:download:)]) {
        [_delegate visualDownloaderDidFinish:_fileName 
                                    download:self];
    }
    
    _delegate = nil;
    
    [_progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
}


@synthesize delegate = _delegate;
@synthesize title = _title;
@synthesize fileURL = _fileURL;
@synthesize fileName = _fileName;
@synthesize currentSize = _currentSize;
@synthesize totalFileSize = _totalFileSize;
@synthesize progressView = _progressView;
@synthesize progressAlertView = _progressAlertView;
@synthesize urlConnection = _urlConnection;
@synthesize tag;

- (void)dealloc
{
    _delegate = nil;
    [_title release];
    [_fileURL release];
    [_fileName release];
    [_totalFileSize release];
    [_progressView release];
    [_progressAlertView release];
    [_urlConnection release];
    
    [super dealloc];
}


@end

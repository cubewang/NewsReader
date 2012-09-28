//
//  AVPlayerView.m
//  iKnow_iPad
//
//  Created by curer yg on 12-3-9.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import "AVAudioPlayerView.h"

@implementation AVAudioPlayerView

@synthesize player;
@synthesize playBarButton;
@synthesize pauseBarButton;
@synthesize audioSlider;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        playBarButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        //playBarButton = 
        
        [playBarButton setImage:[UIImage imageNamed:@"play_blue.png"]
                       forState:UIControlStateNormal];
        
        pauseBarButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [pauseBarButton setImage:[UIImage imageNamed:@"pause_blue.png"]
                        forState:UIControlStateNormal];
        
        //audioSlider = [[UISlider alloc] initWithFrame:frame];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    
    [player release];
    [playBarButton release];
    [pauseBarButton release];
    [audioSlider release];
}

- (void)playAudio:(NSString *)audioPath
{
    if ([audioPath length] == 0) {
        return;
    }
    
    NSError *error = nil;
    AVAudioPlayer *newPlayer = 
    [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:&error];
    
    if (!newPlayer) {
        return;
    }
    
    self.player = newPlayer;
}

- (void)setBarButton: (BOOL) isPlaying
{
    if (isPlaying) {
        self.playBarButton.hidden = YES;
        self.pauseBarButton.hidden = NO;
    }
    else {
        self.playBarButton.hidden = NO;
        self.pauseBarButton.hidden = YES;
    }
}

- (void)play
{
    if (self.player) [self.player play];
    
    [self setBarButton:YES];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    audioSlider.enabled = YES;

}

- (void)stop
{
    [timer invalidate];
    [timer release];
    timer = nil;
    
    [player stop];
}

#pragma mark audio controller

- (void)updateMeters
{
    if (self.player == nil)
        return;
    
    audioSlider.value = (self.player.currentTime / self.player.duration);
}

- (IBAction)pause:(id)sender
{
    if (self.player) [self.player pause];
    
    [self setBarButton:NO];
    audioSlider.enabled = NO;
}

- (IBAction)play:(id)sender
{
    if (self.player) [self.player play];
    
    [self setBarButton:YES];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    audioSlider.enabled = YES;
}

- (IBAction)scrubbbingDone:(id)sender
{
    [self play:nil];
}

- (IBAction)scrub:(id)sender
{
    // Pause the player
    [self.player pause];
    
    // Calculate the new current time
    self.player.currentTime = self.audioSlider.value * self.player.duration;
}

#pragma mark gesture


@end

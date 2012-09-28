//
//  AVPlayerView.h
//  iKnow_iPad
//
//  Created by curer yg on 12-3-9.
//  Copyright (c) 2012年 zhubu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AVAudioPlayerView : UIView
{
    AVAudioPlayer *player;
    NSTimer *timer;
    
    UISlider *audioSlider;
    
    UIButton *playBarButton;
    UIButton *pauseBarButton;
}

@property (nonatomic, retain) AVAudioPlayer *player;

@property (nonatomic, retain) UIButton *playBarButton;
@property (nonatomic, retain) UIButton *pauseBarButton;
@property (nonatomic, retain) UISlider *audioSlider;

@end

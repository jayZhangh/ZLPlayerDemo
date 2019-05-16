//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by 瓜豆2018 on 2019/5/16.
//  Copyright © 2019年 hongyegroup. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () {
    NSString *_totalTime;
}
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIView *videoVIew;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UISlider *slider;
- (IBAction)playBtnOnClick;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) NSURL *videoUrl;
@end

@implementation ViewController

- (NSURL *)videoUrl {
    if (_videoUrl == nil) {
        _videoUrl = [NSURL URLWithString:@"http://v4ttyey-10001453.video.myqcloud.com/Microblog/288-4-1452304375video1466172731.mp4"];
    }
    return _videoUrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        //当status等于AVPlayerStatusReadyToPlay时代表视频已经可以播放了，我们就可以调用play方法播放了。
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [self.player play];
            // 获取视频总长度
            CMTime duration = self.playerItem.duration;
            // 转换成秒
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;
            _totalTime = [self convertTime:totalSecond];
            // 自定义UISlider外观
            [self customVideoSlider:duration];
            NSLog(@"movie total duration:%f", CMTimeGetSeconds(duration));
            // 监听播放状态
            [self monitoringPlayback:self.playerItem];
            
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
//        NSTimeInterval timeInterval = [self availableDuration];
//        NSLog(@"Time Interval:%f", timeInterval);
//        CMTime duration = self.playerItem.duration;
//        CGFloat totalDuration = CMTimeGetSeconds(duration);
//        [self.slider setValue:timeInterval/totalDuration animated:YES];
    }
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    __weak typeof(self) wekself = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        // 计算当前在第几秒
        CGFloat currentSecond = playerItem.currentTime.value / (playerItem.currentTime.timescale * 1.0);
        [wekself updateVideoSlider:currentSecond];
        NSString *timeString = [wekself convertTime:currentSecond];
        wekself.timeLab.text = timeString;
    }];
}

- (void)updateVideoSlider:(CGFloat)second {
    NSLog(@"%f - %f", second, CMTimeGetSeconds(self.playerItem.duration));
    [self.slider setValue:second/CMTimeGetSeconds(self.playerItem.duration) animated:YES];
}

- (void)customVideoSlider:(CMTime)duration {
//    self.slider.maximumValue = CMTimeGetSeconds(duration);
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0);
//    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [self.slider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
//    [self.slider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

- (NSString *)convertTime:(CGFloat)second {
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

- (NSTimeInterval)availableDuration {
    CMTimeRange timeRange = [[[self.playerItem loadedTimeRanges] firstObject] CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    // 计算缓冲总进度
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

- (void)moviePlayDidEnd:(AVPlayerItem *)playerItem {
    NSLog(@"moviePlayDidEnd");
    [self.playBtn setTitle:@"Replay" forState:UIControlStateNormal];
}

- (AVPlayer *)player {
    if (_player == nil) {
        _playerItem = [AVPlayerItem playerItemWithURL:self.videoUrl];
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [_videoVIew.layer addSublayer:_playerLayer];
        _playerLayer.frame = _videoVIew.bounds;
        _playerLayer.backgroundColor = [UIColor redColor].CGColor;
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    }
    
    return _player;
}

- (IBAction)playBtnOnClick {
    if ([self.playBtn.titleLabel.text isEqualToString:@"Replay"]) {
        _player = nil;
        self.playBtn.selected = NO;
    }
    
    self.playBtn.selected = !self.playBtn.selected;
    if (self.playBtn.selected) {
        [self.playBtn setTitle:@"Stop" forState:UIControlStateNormal];
        [self.player play];
    } else {
        [self.playBtn setTitle:@"Play" forState:UIControlStateNormal];
        [self.player pause];
    }
}

@end

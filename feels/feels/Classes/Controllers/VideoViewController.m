//
//  VideoViewController.m
//  feels
//
//  Created by Simon Andersson on 4/13/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "VideoViewController.h"
#import "VideoPlayerView.h"
#import "VideoPlayerItem.h"
#import "AppManager.h"
#import "KVOR.h"
#import "VideoModel.h"
#import "NSTimer+Block.h"

@interface VideoViewController ()

@property(nonatomic,strong) VideoPlayerView *currentVideo;
@property(nonatomic,strong) VideoPlayerView *nextVideo;
@property(nonatomic,assign) int lastVideo;
@property (nonatomic, assign) int currentIndex;

@end

@implementation VideoViewController
{
    BOOL current;
}

- (int)nextIndex {
    return self.currentIndex < [AppManager sharedManager].videos.count-1 ? self.currentIndex+1 : 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AppManager sharedManager] start];
    
    [KVOR target:[AppManager sharedManager] keyPath:@"play" task:^(NSString *keyPath, NSDictionary *change) {
        current = YES;
        NSLog(@"Next clip in: %f", 6-[AppManager sharedManager].startSecondTimeInterval);
        
        VideoModel *video = [AppManager sharedManager].videos[[AppManager sharedManager].startIndex];
        self.currentIndex = [AppManager sharedManager].startIndex;
        
        VideoPlayerItem *playerItem = [[VideoPlayerItem alloc] init];
        playerItem.mainURL = video.videoURL;
        
        
        _currentVideo = [[VideoPlayerView alloc] init];
        _currentVideo.item = playerItem;
        _currentVideo.frame = self.view.bounds;
        
        id firstBlock = ^(VideoPlayerItem *item){
            [self startNextVideo];
        };
        
        _currentVideo.backgroundColor = [UIColor redColor];
        [_currentVideo setDidFinnisPlaying:firstBlock];
        
        VideoModel *nextVideo = [AppManager sharedManager].videos[[self nextIndex]];
        self.currentIndex = [self nextIndex];
        VideoPlayerItem *playerItem2 = [[VideoPlayerItem alloc] init];
        playerItem2.mainURL = nextVideo.videoURL;
        
        _nextVideo = [[VideoPlayerView alloc] init];
        _nextVideo.item = playerItem2;
        
        _nextVideo.frame = self.view.bounds;
        
        id secondBlock = ^(VideoPlayerItem *item){
            [self startNextVideo];
        };
        [self.view addSubview:_nextVideo];
        [self.view addSubview:_currentVideo];
        
        [_nextVideo setDidFinnisPlaying:secondBlock];
        
        [_nextVideo play];
        [_nextVideo pause];
        [_currentVideo play];
        
        current = YES;
    }];
}

- (void)startNextVideo {
    
    [self playVideo:_nextVideo];
}

static BOOL isDoingIt = NO;
-(void)playVideo:(VideoPlayerView *)playerView{
    if (!isDoingIt) {
        isDoingIt = YES;
    }
    else {
        return;
    }
    
    NSLog(@"current: %u", current);
    
    if (current) {
        
        [_nextVideo play];
        _nextVideo.alpha = 0;
    }
    else {
        [_currentVideo play];
        _currentVideo.alpha = 0;
        
    }
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _currentVideo.alpha = current ? 0 : 1;
        _nextVideo.alpha = current ? 1 : 0;
    } completion:^(BOOL finished) {
        
        if (current) {
            [_currentVideo removeFromSuperview];
            _currentVideo = nil;
            current = NO;
            _currentVideo = [[VideoPlayerView alloc] init];
            _currentVideo.frame = self.view.bounds;
            self.currentIndex = [self nextIndex];
            
            VideoModel *video = [AppManager sharedManager].videos[self.currentIndex];
            VideoPlayerItem *item = [[VideoPlayerItem alloc] init];
            item.mainURL = video.videoURL;
            
            _currentVideo.item = item;
            
            [self.view insertSubview:_currentVideo belowSubview:_nextVideo];
            
            id secondBlock = ^(VideoPlayerItem *item){
                [self startNextVideo];
            };
            
            [_currentVideo setDidFinnisPlaying:secondBlock];
            [_currentVideo play];
            [_currentVideo pause];
            
        }
        else {
            [_nextVideo removeFromSuperview];
            _nextVideo = nil;
            current = YES;
            _nextVideo = [[VideoPlayerView alloc] init];
            _nextVideo.frame = self.view.bounds;
            self.currentIndex = [self nextIndex];
            
            VideoModel *video = [AppManager sharedManager].videos[self.currentIndex];
            VideoPlayerItem *item = [[VideoPlayerItem alloc] init];
            item.mainURL = video.videoURL;
            
            _nextVideo.item = item;
            
            [self.view insertSubview:_nextVideo belowSubview:_currentVideo];
            
            id secondBlock = ^(VideoPlayerItem *item){
                [self startNextVideo];
            };
            
            [_nextVideo setDidFinnisPlaying:secondBlock];
            
            [_nextVideo play];
            [_nextVideo pause];
            
            
            //_currentVideo = playerView;
            /*[self.view addSubview:_currentVideo];
             _currentVideo.frame = self.view.bounds;
             [_currentVideo bringToFront];
             */
            
            /*
             [_nextVideo removeFromSuperview];
             _nextVideo = nil;
             _nextVideo = [[VideoPlayerView alloc] init];
             _nextVideo.item = item;
             _nextVideo.backgroundColor = [UIColor blackColor];
             
             id secondBlock = ^(VideoPlayerItem *item){
             [self startNextVideo];
             };
             
             _nextVideo.frame = self.view.bounds;
             [_nextVideo setDidFinnisPlaying:secondBlock];
             [_nextVideo play];
             [_nextVideo pause];
             [_currentVideo play];
             [self.view insertSubview:_nextVideo belowSubview:_currentVideo];
             NSLog(@"%i", self.view.subviews.count);
             */
        }
        isDoingIt = NO;
    }];
    
}

@end

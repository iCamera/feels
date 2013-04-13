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
#import "Intense.h"
#import "NSTimer+Block.h"
#import "ObjectAL.h"

@interface VideoViewController ()

@property(nonatomic,strong) VideoPlayerView *currentVideo;
@property(nonatomic,strong) VideoPlayerView *nextVideo;
@property(nonatomic,assign) int lastVideo;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, strong) OALAudioTrack *backgroundTrack;

@property(nonatomic,assign) double disappearTime;

@end

@implementation VideoViewController
{
    BOOL current;
}

- (int)nextIndex {
    return self.currentIndex < [AppManager sharedManager].videos.count-1 ? self.currentIndex+1 : 0;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self appear];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self disappear];
}

-(void)appear{
    [[OALSimpleAudio sharedInstance] playBg:@"home.mp3" loop:YES];
    if ([AppManager sharedManager].disappearTime > 0) {
        
        double now = [[NSDate date] timeIntervalSince1970];
        
        double secs = now - [AppManager sharedManager].disappearTime;
        int clips = secs/6;
        [AppManager sharedManager].disappearTime = 0;
        
        _currentIndex += clips;
        _currentIndex = [self nextIndex];
        
        current = YES;
//        [_currentVideo removeFromSuperview];
//        _currentVideo = nil;
        [_nextVideo removeFromSuperview];
        _nextVideo = nil;
        VideoModel *nextVideo = [AppManager sharedManager].videos[_currentIndex];
        _currentIndex = [self nextIndex];
        VideoPlayerItem *playerItem2 = [[VideoPlayerItem alloc] init];
        playerItem2.mainURL = nextVideo.videoURL;
        
        _nextVideo = [[VideoPlayerView alloc] init];
        _nextVideo.item = playerItem2;
        
        _nextVideo.frame = self.view.bounds;
        
        id secondBlock = ^(VideoPlayerItem *item){
            [self startNextVideo];
        };
        [_nextVideo setDidFinnisPlaying:secondBlock];
//        [_currentVideo play];
        [self playVideo:nil];
    }
}

-(void)disappear{
    [[OALSimpleAudio sharedInstance] stopBg];
    [_currentVideo pause];
    [_nextVideo pause];
    
    [AppManager sharedManager].disappearTime = [[NSDate date] timeIntervalSince1970];
}

- (void)applicationDidEnterBackground:(NSNotification*)n {

    [self disappear];
}
- (void)applicationWillEnterForeground:(NSNotification*)n {
    [self appear];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[OALSimpleAudio sharedInstance] preloadBg:@"home.mp3"];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [nc addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    [KVOR target:self keyPath:@"currentIndex" task:^(NSString *keyPath, NSDictionary *change) {
        [AppManager sharedManager].currentIndex = self.currentIndex;
        
        NSLog(@"%i", [AppManager sharedManager].currentIndex);
    }];
    
    [[AppManager sharedManager] start];
    
    [KVOR target:[AppManager sharedManager] keyPath:@"play" task:^(NSString *keyPath, NSDictionary *change) {
        current = YES;
        NSLog(@"Next clip in: %f", 6-[AppManager sharedManager].startSecondTimeInterval);
        
        VideoModel *video = [AppManager sharedManager].videos[[AppManager sharedManager].startIndex];
        self.currentIndex = [AppManager sharedManager].startIndex;
        
        if (self.videoDidChange) {
            self.videoDidChange(video);
        }
        
        VideoPlayerItem *playerItem = [[VideoPlayerItem alloc] init];
        playerItem.mainURL = video.videoURL;
        
        
        _currentVideo = [[VideoPlayerView alloc] init];
        _currentVideo.item = playerItem;
        _currentVideo.frame = self.view.bounds;
        [_currentVideo seekToTime:[AppManager sharedManager].startSecondTimeInterval completion:^{
            
        }];
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
        //[[Intense shared] play];
        
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
    
    if (current) {
        [_nextVideo play];
        _nextVideo.alpha = 0;
    }
    else {
        [_currentVideo play];
        _currentVideo.alpha = 0;
    }
    
    if (self.videoDidChange) {
        VideoModel *video = [AppManager sharedManager].videos[self.currentIndex];
        self.videoDidChange(video);
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

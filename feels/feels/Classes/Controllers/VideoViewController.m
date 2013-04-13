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

@interface VideoViewController ()

@property(nonatomic,strong) VideoPlayerView *currentVideo;
@property(nonatomic,strong) VideoPlayerView *nextVideo;
@property(nonatomic,assign) int lastVideo;
@property (nonatomic, assign) int currentIndex;

@end

@implementation VideoViewController

- (int)nextIndex {
    return self.currentIndex < [AppManager sharedManager].videos.count-1 ? self.currentIndex+1 : 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AppManager sharedManager] start];
    
    [KVOR target:[AppManager sharedManager] keyPath:@"play" task:^(NSString *keyPath, NSDictionary *change) {
        
        VideoModel *video = [AppManager sharedManager].videos[[AppManager sharedManager].startIndex];
        self.currentIndex = [AppManager sharedManager].startIndex;
        
        VideoPlayerItem *playerItem = [[VideoPlayerItem alloc] init];
        playerItem.mainURL = video.videoURL;
        
        
        _currentVideo = [[VideoPlayerView alloc] init];
        _currentVideo.item = playerItem;
        _currentVideo.frame = CGRectMake(0, 0, 568, 320);
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
        
        _nextVideo.frame = CGRectMake(0, 0, 568, 320);
        
        id secondBlock = ^(VideoPlayerItem *item){
            [self startNextVideo];
        };
        
        [_nextVideo setDidFinnisPlaying:secondBlock];
        
        [self.view addSubview:_currentVideo];
        
        [_currentVideo play];
    }];
}

- (void)startNextVideo {
    
    [self playVideo:_nextVideo];
    
    self.currentIndex = [self nextIndex];
    VideoModel *video = [AppManager sharedManager].videos[self.currentIndex];
    VideoPlayerItem *item = [[VideoPlayerItem alloc] init];
    item.mainURL = video.videoURL;
    
    _nextVideo = [[VideoPlayerView alloc] init];
    _nextVideo.item = item;
    _nextVideo.backgroundColor = [UIColor redColor];
    
    id secondBlock = ^(VideoPlayerItem *item){
        [self startNextVideo];
    };
    
    _nextVideo.frame = CGRectMake(0, 0, 568, 320);
    [_nextVideo setDidFinnisPlaying:secondBlock];
}


-(void)playVideo:(VideoPlayerView *)playerView{
    
    [_currentVideo removeFromSuperview];
    _currentVideo = nil;
    _currentVideo = playerView;
    [self.view addSubview:_currentVideo];
    _currentVideo.frame = CGRectMake(0, 0, 568, 320);
    [_currentVideo bringToFront];
    [_currentVideo play];
    
    
    
}

@end

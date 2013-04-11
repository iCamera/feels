//
//  ViewController.m
//  feels
//
//  Created by Andreas Areschoug on 2013-04-11.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayerView.h"
#import "VideoPlayerItem.h"

#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property(nonatomic,strong) VideoPlayerView *currentVideo;
@property(nonatomic,strong) VideoPlayerView *nextVideo;
@property(nonatomic,strong) NSMutableArray *videos;
@property(nonatomic,assign) int lastVideo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _videos = [NSMutableArray arrayWithArray:@[@"http://andreas.animalweekend.com/test_clip.mov",@"http://andreas.animalweekend.com/test_clip3.mov",@"http://andreas.animalweekend.com/test_clip2.mov"]];

    VideoPlayerItem *playerItem = [[VideoPlayerItem alloc] init];
    playerItem.mainURL = [NSURL URLWithString:@"http://andreas.animalweekend.com/test_clip.mov"];
    
    _currentVideo = [[VideoPlayerView alloc] init];
    _currentVideo.item = playerItem;
    _currentVideo.frame = CGRectMake(0, 0, 568, 320);
    
    id firstBlock = ^(VideoPlayerItem *item){
        [self startNextVideo];
        
    };
    _currentVideo.backgroundColor = [UIColor redColor];
    [_currentVideo setDidFinnisPlaying:firstBlock];
    
    
    
    VideoPlayerItem *playerItem2 = [[VideoPlayerItem alloc] init];
    playerItem2.mainURL = [NSURL URLWithString:@"http://andreas.animalweekend.com/test_clip2.mov"];
    
    _nextVideo = [[VideoPlayerView alloc] init];
    _nextVideo.item = playerItem2;

    _nextVideo.frame = CGRectMake(0, 0, 568, 320);
    
    id secondBlock = ^(VideoPlayerItem *item){
        [self startNextVideo];
        
    };
    
    [_nextVideo setDidFinnisPlaying:secondBlock];
    
    [self.view addSubview:_currentVideo];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_currentVideo play];
}

-(void)startNextVideo{
    
    [self playVideo:_nextVideo];
    NSLog(@"play next");
    
    VideoPlayerItem *item = [[VideoPlayerItem alloc] init];
    item.mainURL = [NSURL URLWithString:_videos[_lastVideo]];
    NSLog(@"next %@",item.mainURL);
    _nextVideo = [[VideoPlayerView alloc] init];
    _nextVideo.item = item;
    _nextVideo.backgroundColor = [UIColor redColor];
    
    id secondBlock = ^(VideoPlayerItem *item){
        [self startNextVideo];
    };
    
    _nextVideo.frame = CGRectMake(0, 0, 568, 320);
    [_nextVideo setDidFinnisPlaying:secondBlock];

    _lastVideo++;
    if (_lastVideo > _videos.count - 1) {
        _lastVideo = 0;
    }
    
}

-(void)playVideo:(VideoPlayerView *)playerView{
    NSLog(@"play %@",playerView);
    [_currentVideo removeFromSuperview];
    _currentVideo = nil;
    _currentVideo = playerView;
    [self.view addSubview:_currentVideo];
    _currentVideo.frame = CGRectMake(0, 0, 568, 320);
    [_currentVideo bringToFront];
    [_currentVideo play];

    

}

@end

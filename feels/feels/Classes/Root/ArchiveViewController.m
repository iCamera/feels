//
//  ArchiveViewController.m
//  feels
//
//  Created by Hannes Wikström on 4/13/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "ArchiveViewController.h"
#import "AVPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "RootViewController.h"

@interface ArchiveViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) AVPlayerView *videoView;

@end

@implementation ArchiveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self.view addGestureRecognizer:tgr];
    
    NSMutableArray *videoImages = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"alaska", @"surfer", @"sweet_lips", @"leafs", @"paris", @"sweet_lips", nil]];
    NSMutableArray *videoTitles = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects: @"Alaska",  @"Surf trip Norway", @"The Beach", @"Fall 2013", @"Party in Paris!",@"STHLM Startup Hack", nil]];

    _imageViewsContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    _imageViewsContainer.width += 1000;
    
    for (int i=0; i<[videoImages count]; i++) {
        UIImageView *videoImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[videoImages objectAtIndex:i]]];
        if (i == [videoImages count] - 1) {
            [videoImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFirst)]];
            videoImgView.userInteractionEnabled = YES;
        } else if(i == 0) {
            videoImgView.userInteractionEnabled = YES;            
            [videoImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAlaska)]];
        }
        videoImgView.size = CGSizeMake(284, 160);
        [videoImgView setContentMode:UIViewContentModeScaleAspectFill];
        videoImgView.top = (i%2==0) ? 0 : 160;
        videoImgView.left = ceil(i/2)*284;
        
        UIImageView *infoBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_box"]];
        infoBox.top = 104;
        infoBox.left = 139;
        [videoImgView addSubview:infoBox];
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 10, 126, 24)];
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        [infoLabel setFont:[UIFont GeoSansLight:12]];
        [infoLabel setTextColor:[UIColor colorWithWhite:0 alpha:0.8]];
        if (i < videoTitles.count) {
            infoLabel.text = [[videoTitles objectAtIndex:i] uppercaseString];
        }
        [infoBox addSubview:infoLabel];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(infoBox.origin.x, 0, infoBox.width, 18)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        [timeLabel setFont:[UIFont GeoSansLight:9]];
        [timeLabel setTextColor:[UIColor colorWithWhite:1 alpha:1]];
        if (i < videoTitles.count) {
            timeLabel.text = [@"Updated today at 18:50" uppercaseString];
        }
        timeLabel.top = infoBox.bottom+2;
        [videoImgView addSubview:timeLabel];
        [_imageViewsContainer addSubview:videoImgView];
    }
    [self.scrollView addSubview:_imageViewsContainer];

    self.scrollView.width -= 48; //Menu width
    CGFloat contentWidth = ceil([videoImages count]/2) * 284;
    self.scrollView.contentSize = CGSizeMake(contentWidth, 320);

    /* VIDEO */
    self.videoView = [[AVPlayerView alloc] initWithFrame:CGRectMake(284, -2, 284, 166)];
    [self.videoView setContentMode:UIViewContentModeScaleAspectFill];
    [self.videoView setPlayerForM4vFile:@"demo"];
//    [self.videoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAlaska)]];
    [_imageViewsContainer addSubview:self.videoView];
    
    UIImageView *infoBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_box"]];
    infoBox.top = 104;
    infoBox.left = 139;
    [self.videoView addSubview:infoBox];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 10, 126, 24)];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    [infoLabel setFont:[UIFont GeoSansLight:12]];
    [infoLabel setTextColor:[UIColor colorWithWhite:0 alpha:0.8]];
    infoLabel.text = [@"The Beach" uppercaseString];
    [infoBox addSubview:infoLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(infoBox.origin.x, 0, infoBox.width, 18)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textAlignment = NSTextAlignmentRight;
    [timeLabel setFont:[UIFont GeoSansLight:9]];
    [timeLabel setTextColor:[UIColor colorWithWhite:1 alpha:1]];
    timeLabel.text = [@"Updated today at 18:50" uppercaseString];
    timeLabel.top = infoBox.bottom+2;
    [self.videoView addSubview:timeLabel];
    
    
    /*[self.videoView setDidReachEnd:^(AVPlayer *player){
        [player play];
    }];*/
}

-(void)tapFirst{
    
    RootViewController *vc = (RootViewController *)self.parentViewController;
    [vc setAlaska:NO];
    [vc showArchive:NO animated:YES];
    
}

-(void)tapAlaska{
    RootViewController *vc = (RootViewController *)self.parentViewController;
    [vc setAlaska:YES];
    [vc showArchive:NO animated:YES];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    /*BOOL b = YES;
    int i = 1;
    while (b) {
        NSString *localVid = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Movie_out%i.mp4",i]];
        NSURL *fileURL = [NSURL fileURLWithPath:localVid];
        NSLog(@"%@",fileURL);
        BOOL trams = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"Documents/Movie_out%i.mp4",i]];
        
        if (!trams) {
            b = NO;
        }
        
        i++;
    }*/

    [self.videoView setDidReachEnd:^(AVPlayerView *player){
        [player.player seekToTime:kCMTimeZero];
    }];
    [self.videoView.player play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapped {
    //[self.view removeFromSuperview];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_didScroll) {
        _didScroll(scrollView);
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

}

@end

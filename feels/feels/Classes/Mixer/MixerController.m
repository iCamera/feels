//
//  MixerController.m
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "MixerController.h"
#import "Intense.h"
#import "AppManager.h"
#import "NSTimer+Block.h"
#import "UIView_DrawRect.h"
#import "MathHelper.h"

@implementation MixerController {
    __block float val;
    UIView *v;
}

static inline float radians(double degrees) { return degrees * M_PI / 180; }

- (void)viewDidLoad {
    [super viewDidLoad];
    val = 1;
    
    
    [self.view addSubview:v];
    
    [NSTimer scheduledTimerWithTimeInterval:1/30.0 completion:^{
        val += 0.0005;
        [v setNeedsDisplay];
    } repeat:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /*
    [NSTimer scheduledTimerWithTimeInterval:1.0 completion:^{
        NSLog(@"%i", (int)([[NSDate date] timeIntervalSince1970] / 6) % (int)val);
    } repeat:YES];
    //[NSTimer scheduledTimerWithTimeInterval:2. target:self selector:@selector(start) userInfo:nil repeats:NO];
    
    double numberOfClipsPlayed = floor([[NSDate date] timeIntervalSince1970] / 6);
    double secondsIntoClip = [[NSDate date] timeIntervalSince1970] - (numberOfClipsPlayed*6);
    
    int numberOfClips = 10;
    double playlistLenght = numberOfClips*6;
    */
    
    
}

- (void)start {
    
    [[Intense shared] play];
    
}

- (IBAction)sliderDidChange:(UISlider *)slider {
   
}

@end

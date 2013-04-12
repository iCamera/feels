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
@implementation MixerController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:2. target:self selector:@selector(start) userInfo:nil repeats:NO];
}

- (void)start {
    
    [[Intense shared] play];
    
}

- (void)update {
    NSLog(@"%@ %@", [NSDate dateWithTimeIntervalSince1970:[[AppManager sharedManager] serverTimeIntervalSince1970]], [NSDate date]);
}

- (IBAction)sliderDidChange:(UISlider *)slider {
    
}

@end

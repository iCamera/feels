//
//  MixerController.m
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "MixerController.h"
#import "Intense.h"

@implementation MixerController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [NSTimer scheduledTimerWithTimeInterval:2. target:self selector:@selector(start) userInfo:nil repeats:NO];
}

- (void)start {
    
    [[Intense shared] play];
    
}

- (IBAction)sliderDidChange:(UISlider *)slider {
    
}

@end

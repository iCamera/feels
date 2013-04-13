//
//  Mixer.m
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "Mixer.h"

@interface Mixer () {
    CADisplayLink *_displayLink;
    int _bpm;
    float _timing;
    float _beat;
    float _duration;
    NSTimer *_timer;
}

@end

@implementation Mixer

#pragma mark - Singleton

+ (Mixer *)table {
    static Mixer *INSTANCE = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        INSTANCE = [[Mixer alloc] init];
    });
    return INSTANCE;
}

- (void)startWithBPM:(int)bpm {
    _bpm = bpm;
    
    _beat = (float)_bpm/60.0;
    _timing = _beat / 4.0;
    
    /*
    [NSThread setThreadPriority:0.1];
    int step = 0;
    NSDate *nextBeat = [NSDate date];
    float dur = 0.0;
    while(1)
    {
        
        if (dur >= _timing) {
            if (self.tickBlock) {
                self.tickBlock();
            }
            dur = 0;
        }
        
        NSDate *newNextBeat=[[NSDate alloc] initWithTimeInterval:0.1 sinceDate:nextBeat];
        nextBeat=newNextBeat;
        [NSThread sleepUntilDate:nextBeat];
        dur += 0.1;
    }
    */
    
    return;
    _timer = [NSTimer scheduledTimerWithTimeInterval:_timing target:self selector:@selector(update:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [self update:nil];
}

- (void)stop {
    [_timer invalidate], _timer = nil;
}

#pragma mark - Displaylink

- (void)update:(NSTimer *)timer {
    
    static int count = 1;
    
    if (self.tickBlock) {
        self.tickBlock();
    }
    
    if (count == 4) {
        if (self.beatBlock) {
            self.beatBlock();
        }
        count = 0;
    }
    
    count++;
}

@end

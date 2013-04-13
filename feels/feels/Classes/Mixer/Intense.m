//
//  Intense.m
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "Intense.h"
#import "ObjectAL.h"
#import "Mixer.h"

@implementation Intense {
    ALChannelSource *_channels;
    ALContext *_context;
    ALDevice *_device;
    
    OALAudioTrack *_backgroundTrack;
    
    BOOL _playing;
    
    ALBuffer *_snare;
}

+ (Intense *)shared {
    
    static Intense *INSTANCE = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        INSTANCE = [[Intense alloc] init];
    });
    
    return INSTANCE;
}

- (id)init
{
    self = [super init];
    if (self) {
        /*
        _device = [ALDevice deviceWithDeviceSpecifier:nil];
        _context = [ALContext contextOnDevice:_device attributes:nil];
        [OpenALManager sharedInstance].currentContext = _context;
        */
        [[Mixer table] setTickBlock:[self tickBlock]];
        [[Mixer table] setBeatBlock:[self beatBlock]];
        
        _backgroundTrack = [OALAudioTrack track];
        
        _snare = [[OALSimpleAudio sharedInstance] preloadEffect:@"snare.mp3"];
    }
    return self;
}

- (MixerTickBlock)tickBlock {
    return [^{
        [[OALSimpleAudio sharedInstance] playEffect:@"snare.mp3"];
    } copy];
}

- (MixerTickBlock)beatBlock {
    return [^{
    } copy];
}

- (void)play {
    
    [[Mixer table] startWithBPM:120];
    //[[OALSimpleAudio sharedInstance] playEffect:@"base.mp3" loop:YES];
    //[_backgroundTrack playFile:@"base.mp3" loops:-1];
}

- (void)pause {
    
}

- (void)stop {
    
}

@end

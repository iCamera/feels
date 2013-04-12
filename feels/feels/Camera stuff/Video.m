//
//  Video.m
//  opengl-inputs-template
//
//  Created by Andreas Areschoug on 4/6/13.
//  Copyright (c) 2013 Andreas Areschoug. All rights reserved.
//

#import "Video.h"

@interface Video(){
    CMTime _currentStartTime;
    CMTime _currentEndTime;
    BOOL _readingFrame;
}

@property(nonatomic,strong)	AVCaptureDeviceInput *videoInput;
@property(nonatomic,strong) AVCaptureVideoDataOutput *videoOutput;
@property(nonatomic,strong) AVAssetReaderTrackOutput *assetReaderOutput;
@property(nonatomic,strong) AVAssetReader *reader;
@property(nonatomic,strong) AVAssetTrack *videoTrack;
@property(nonatomic,strong) NSString *videoFile;

@property(nonatomic,assign) CMSampleBufferRef buffer;

@property(nonatomic,strong) NSTimer *timer;

@end


@implementation Video

-(void)loadVideoFile:(NSString *) videoFile {
    _videoFile = videoFile;
    [self loadVideo];
}

-(void)loadVideo{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_videoFile];
    
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
    NSError *error = nil;
    
    _reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    _durationInFrame = 1 * 30;
    
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    _videoTrack = [videoTracks objectAtIndex:0];
    
    _numberOfFrames = (int)(_videoTrack.timeRange.duration.value/_videoTrack.timeRange.duration.timescale) * 30;
    _possibleStartFrames = _numberOfFrames - _durationInFrame;
    
    
    if (_currentEndTime.value != 0) {
        [_reader setTimeRange:CMTimeRangeFromTimeToTime(_currentStartTime, _currentEndTime)];
    }
    
    NSDictionary *options = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                              (id)kCVPixelBufferWidthKey : @(480),
                              (id)kCVPixelBufferHeightKey : @(320)};
    
    
    _assetReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:_videoTrack outputSettings:options];
    [_reader addOutput:_assetReaderOutput];
    
    [_reader startReading];
    [_timer invalidate], _timer = nil;
    if (_readingFrame) {
        [self read];
        [_reader cancelReading];
    } else {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(read) userInfo:nil repeats:YES];
        
        [_timer fire];
    }
    

    
}


-(void)setStartTime:(float) startTime{
    _readingFrame = NO;
    startTime = (_possibleStartFrames * startTime/30);
    _currentStartTime = CMTimeMake((startTime) * 600, _videoTrack.timeRange.duration.timescale);
    _currentEndTime = CMTimeMake(((startTime + 1.0)) * 600, _videoTrack.timeRange.duration.timescale);
}

-(void)readFrame:(float)frame{
    _readingFrame = YES;
    frame = (_possibleStartFrames * frame/30);
    _currentStartTime = CMTimeMake((frame) * 600, _videoTrack.timeRange.duration.timescale);
    _currentEndTime = CMTimeMake(((frame + (1.0/30))) * 600, _videoTrack.timeRange.duration.timescale);
}

-(void)read {
    
    if ([_reader status] == AVAssetReaderStatusReading) {
        
        _buffer = [_assetReaderOutput copyNextSampleBuffer];
        CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(_buffer);
        
        if (pixelBuffer) {
            [self.delegate processVideoFrame:pixelBuffer];
            CFRelease(pixelBuffer);
        }

    } else {
        [_timer invalidate], _timer = nil;
        if (!_readingFrame) {
            [self.delegate didStopReading:[_reader status]];
        }

    }
}


@end

//
//  ViewController.m
//  opengl-inputs-template
//
//  Created by Andreas Areschoug on 4/6/13.
//  Copyright (c) 2013 Andreas Areschoug. All rights reserved.
//

#import "CameraViewController.h"
#import "FeelsFilter.h"
#import "MathHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "APIClient.h"
#import "AppManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSTimer+Block.h"
#import "UILabel+Feels.h"
#import "LocationManager.h"
#import <CommonCrypto/CommonDigest.h>
#include <sys/xattr.h>
#import "AVPlayerView.h"
#define videoWidth 960
#define videoHeight 540

@interface NSData(MD5)

- (NSString *)MD5;

@end
@implementation NSString(MD5)

- (NSString*)MD5
{
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end


@implementation NSData(MD5)

- (NSString*)MD5
{
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(self.bytes, self.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end

typedef enum {
    StateUnknown,
    StatePre,
    StateRecording,
    StatePost,
    StateUploading,
    StateDone,
} State;

@interface CameraViewController()<GPUImageMovieDelegate,UIAlertViewDelegate>
@property (strong, nonatomic)  GPUImageView *gpuImageView;
@property (strong, nonatomic) UIImageView *imageView;
@property(nonatomic,strong) FeelsFilter *filter;
@property(nonatomic,assign) int changeCounter;

@property(nonatomic,assign) State currentState;

@property(nonatomic,assign) BOOL recording;
@property(nonatomic,assign) BOOL canStopRecording;
@property(nonatomic,assign) int startTime;

@property (weak, nonatomic) IBOutlet UILabel *startRecordingLabel;
@property (weak, nonatomic) IBOutlet UILabel *tapLabel;
@property (weak, nonatomic) IBOutlet UIView *preRecordingView;

@property (strong, nonatomic) NSTimer *stopRecTimer;
@property (strong, nonatomic) NSTimer *timeLabelTimer;
@property (strong, nonatomic) NSTimer *forceStopTimer;

@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UIView *lineViewProgress;
@property (strong, nonatomic) UIView *lineCurrentPostion;


@property (weak, nonatomic) IBOutlet UIView *recordingView;
@property (weak, nonatomic) IBOutlet UILabel *recordingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingTapLabel;

@property (weak, nonatomic) IBOutlet UIView *postView;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTapLabel;

@property(nonatomic, strong) AVPlayerView *avPlayer;

@property (weak, nonatomic) IBOutlet UIView *postVideoContainer;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *uploadView;
@property (weak, nonatomic) IBOutlet UILabel *procentLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadDescLabel;
@property (weak, nonatomic) IBOutlet UIView *doneView;
@property (weak, nonatomic) IBOutlet UILabel *uploadSuccessLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadDateLabel;

@property (strong,nonatomic)  CLGeocoder *geoCoder;
@property (strong,nonatomic)  NSString *placeString;
- (IBAction)backButton:(id)sender;
- (IBAction)closeButton:(id)sender;

@end

@implementation CameraViewController


#pragma mark - Initialization and teardown

-(void)viewDidLoad{
    [super viewDidLoad];

    _geoCoder = [[CLGeocoder alloc] init];
    [[LocationManager sharedManager] startTracking];
    
    _uploadSuccessLabel.font = [UIFont GeoSansLight:20.0];
    _uploadDescriptionLabel.font = [UIFont GeogrotesqueGardeExtraLight:_uploadDescriptionLabel.font.pointSize];
    [_uploadTimeLabel setFont:[UIFont AvantGardeExtraLight:32]];
    [_uploadDateLabel setFont:[UIFont AvantGardeExtraLight:25]];
    
    [_uploadTimeLabel setKerning:1.1];
    [_uploadDateLabel setKerning:1.1];
    [_uploadTimeLabel setAdjustsLetterSpacingToFitWidth:YES];
    [_uploadTimeLabel setAdjustsFontSizeToFitWidth:YES];
    [_uploadDateLabel setAdjustsLetterSpacingToFitWidth:YES];
    [_uploadDateLabel setAdjustsFontSizeToFitWidth:YES];
    
    _procentLabel.font = [UIFont  AvantGardeExtraLight:_procentLabel.font.pointSize];
    _uploadDescLabel.font = [UIFont GeogrotesqueGardeExtraLight:8];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake((self.view.width-144)/2, 296, 144, 0.5)];
    _lineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    
    _lineViewProgress = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.5)];
    _lineViewProgress.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    [_lineView addSubview:_lineViewProgress];
    
    _lineCurrentPostion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.5)];
    _lineCurrentPostion.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    [_lineView addSubview:_lineCurrentPostion];
    
    [self.view addSubview:_lineView];
    
    {
        _startRecordingLabel.font = [UIFont GeoSansLight:_startRecordingLabel.font.pointSize];
        _tapLabel.font = [UIFont GeogrotesqueGardeExtraLight:_tapLabel.font.pointSize];
        
    }
    
    {
        _recordingTimeLabel.font = [UIFont AvantGardeExtraLight:_startRecordingLabel.font.pointSize];
        _recordingTapLabel.font = [UIFont GeogrotesqueGardeExtraLight:_tapLabel.font.pointSize];
    }
    
    {
        _postTitleLabel.font = [UIFont AvantGardeExtraLight:_postTitleLabel.font.pointSize];
        _postTapLabel.font = [UIFont GeogrotesqueGardeExtraLight:_postTapLabel.font.pointSize];
    }
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame960x540 cameraPosition:AVCaptureDevicePositionBack];
    
    
    _videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
    _videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    //_filter = [[GPUImageSepiaFilter alloc] init];
    
    
    _filter = [[FeelsFilter alloc] init];
    UIImage *i = [self blendImage:@"test" andImage2:@"lookup_xpro" first:0.0 second:0.0];
    [_filter setSourceImage:i];
    
    
    [_videoCamera addTarget:_filter];
    
    _gpuImageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [_filter addTarget:_gpuImageView];
    
    [self.view insertSubview:_gpuImageView atIndex:0];
    //    filterView.fillMode = kGPUImageFillModeStretch;
    _gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    BOOL v = [self addSkipBackupAttributeToKey:pathToMovie];
    NSLog(@"palla : %d",v);

    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(960.0, 540.0)];
    
    [_filter addTarget:_movieWriter];
    
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    
}

- (BOOL)addSkipBackupAttributeToKey:(NSString*)key {
    
	NSString* cachePath = key;
    NSURL *url = [NSURL fileURLWithPath:cachePath];
    
    const char* filePath = [[url path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_videoCamera startCameraCapture];
    [self setCurrentState:StatePre];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[LocationManager sharedManager] stopTracking];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _gpuImageView.frame = self.view.bounds;
}


-(void)tap{
    
    if (_currentState == StateRecording) {
        if (_canStopRecording) {
            [self setCurrentState:StatePost];
            if(_recording) [self stopRecording];//[self performSelectorInBackground:@selector(stopRecording) withObject:nil];
            
        }
        
    } else if (_currentState == StatePre){
        [self setCurrentState:StateRecording];
        
    } else if (_currentState == StatePost){
        [self setCurrentState:StateUploading];
        [self export];
    } else if(_currentState == StateDone){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (_currentState == StatePre) {
        if (_changeCounter < 5) {
            _changeCounter ++;
            return;
        }
        _changeCounter = 0;
        
        float dragValue = [[touches anyObject] locationInView:self.view].x/self.view.bounds.size.width;
        float dragValueY = [[touches anyObject] locationInView:self.view].y/self.view.bounds.size.height;
        NSLog(@"dragValueY %f",dragValueY);
        dragValueY = map(dragValueY, 0, 1, 2.0, 0.5);
        
        if (dragValue < 0.25) {
            [_videoCamera removeTarget:_filter];
            [_filter removeTarget:_movieWriter];            
            _filter = [[FeelsFilter alloc] init];
            _filter.saturation = dragValueY;
            UIImage *i = [self blendImage:@"lookup" andImage2:@"lookup_xpro" first:map(dragValue, 0.0, 0.25, 1.0, 0.0) second:0.0];
            [_filter setSourceImage:i];
            
            [_filter addTarget:_gpuImageView];
            [_filter addTarget:_movieWriter];            
            [_videoCamera addTarget:_filter];
            
        } else if (dragValue < 0.50){
            [_videoCamera removeTarget:_filter];
            [_filter removeTarget:_movieWriter];
            _filter = [[FeelsFilter alloc] init];
                        _filter.saturation = dragValueY;
            UIImage *i = [self blendImage:@"lookup_xpro" andImage2:@"lookup_toaster" first:map(dragValue, 0.25, 0.50, 1.0, 0.0) second:0.0];
            [_filter setSourceImage:i];
            
            [_filter addTarget:_gpuImageView];
            [_filter addTarget:_movieWriter];            
            [_videoCamera addTarget:_filter];
        } else if (dragValue < 0.75){
            [_filter removeTarget:_movieWriter];
            [_videoCamera removeTarget:_filter];
            _filter = [[FeelsFilter alloc] init];
            _filter.saturation = dragValueY;            
            UIImage *i = [self blendImage:@"lookup_toaster" andImage2:@"lookup_nashville" first:map(dragValue, 0.50, 0.75, 1.0, 0.0) second:0.0];
            [_filter setSourceImage:i];
            
            [_filter addTarget:_gpuImageView];
            [_filter addTarget:_movieWriter];            
            [_videoCamera addTarget:_filter];
        } else {
            [_videoCamera removeTarget:_filter];
            [_filter removeTarget:_movieWriter];
            _filter = [[FeelsFilter alloc] init];
            _filter.saturation = dragValueY;            
            UIImage *i = [self blendImage:@"lookup_nashville" andImage2:@"lookup" first:map(dragValue, 0.75, 1.0, 1.0, 0.0) second:0.0];
            [_filter setSourceImage:i];
            
            [_filter addTarget:_gpuImageView];
            [_filter addTarget:_movieWriter];
            [_videoCamera addTarget:_filter];
        }
    } else if (_currentState == StatePost){
        
        float dragValue = [[touches anyObject] locationInView:self.view].x/self.view.width;
        
        NSLog(@"%lld %d",_avPlayer.playerItem.duration.value,_avPlayer.playerItem.duration.timescale);
        float lenght = _avPlayer.playerItem.duration.value/_avPlayer.playerItem.duration.timescale;
        int frames = roundf(lenght * 30);
        
        int maxStart = frames - (6 * 30);
        int start = map(dragValue, 0, 1, 0, maxStart);
        _startTime = start;
        NSLog(@"lenght %f %i %i",lenght,frames,start);
        [_avPlayer.player seekToTime:CMTimeMake((_startTime/30.0) * _avPlayer.playerItem.duration.timescale, _avPlayer.playerItem.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [_avPlayer.player pause];
        
        _lineCurrentPostion.width = (6.0/lenght) * _lineView.width;
        _lineCurrentPostion.left = clamp(0, _lineView.width - _lineCurrentPostion.width, map(dragValue, 0, 1, 0, _lineView.width - _lineCurrentPostion.width));
        NSLog(@"%f %f",_lineCurrentPostion.width,_lineView.width - _lineCurrentPostion.width);
    } else if (_currentState == StatePost){

    }
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [_avPlayer.player seekToTime:CMTimeMake((_startTime/30.0) * _avPlayer.playerItem.duration.timescale, _avPlayer.playerItem.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [_avPlayer.player play];
}

-(UIImage *)blendImage:(NSString *)imageName andImage2:(NSString *)image2Name first:(float)first second:(float)second{
    UIImage *bottomImage = [UIImage imageNamed:image2Name];
    UIImage *image = [UIImage imageNamed:imageName];
    
    CGSize newSize = CGSizeMake(512, 512);
    UIGraphicsBeginImageContext( newSize );
    
    // Use existing opacity as is
    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Apply supplied opacity
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:first];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    _imageView.image = newImage;
    return newImage;
}

-(void)startRecording{
    _videoCamera.audioEncodingTarget = nil;
    _canStopRecording = NO;
    _recordingTapLabel.alpha = 0.0;

    
    _recording = YES;
    
    _videoCamera.audioEncodingTarget = nil;
    [_movieWriter startRecording];
    
    int startTime = [[NSDate date] timeIntervalSince1970];
    _timeLabelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 completion:^{
        int nowTime = [[NSDate date] timeIntervalSince1970];
        int diff = nowTime - startTime;
        _recordingTimeLabel.text = [NSString stringWithFormat:@"00:%02d",diff];
    } repeat:YES];
    
    
    _stopRecTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 completion:^{
        _canStopRecording = YES;
        
        [UIView animateWithDuration:0.6 animations:^{
            _recordingTapLabel.alpha = 1.0;
        }];
    } repeat:YES];
    
    _forceStopTimer = [NSTimer scheduledTimerWithTimeInterval:15 completion:^{
        if (_recording) {
            [self stopRecording];
        }
    }];
    
    
}

-(void)stopRecording{
    if (!_canStopRecording) return;
    NSLog(@"stopRecording");
    [_timeLabelTimer invalidate],_timeLabelTimer = nil;
    [_stopRecTimer invalidate],_stopRecTimer = nil;
    [_forceStopTimer invalidate], _forceStopTimer = nil;
    
    UIView *newView = [[UIView alloc] initWithFrame:self.view.bounds];
    newView.backgroundColor = [UIColor blackColor];
    
//    UILabel *l = [[UILabel alloc] initWithFrame:self.view.bounds];
//    l.font = [UIFont AvantGardeExtraLight:24];
//    l.backgroundColor = [UIColor clearColor];
//    l.textAlignment = NSTextAlignmentCenter;
//    l.text = @"Loading";
//    l.textColor = [UIColor whiteColor];
//    [newView addSubview:l]
    
    [_postVideoContainer addSubview:newView];
    
    _recording = NO;
    [_filter removeTarget:_movieWriter];
    
   
    _videoCamera.audioEncodingTarget = nil;
    [_videoCamera stopCameraCapture];
    [_video startProcessing];
    
    [_movieWriter finishRecordingWithCompletionHandler:^{

        NSString *localVid = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
     
        [_filter removeTarget:_movieWriter];

//        _playerItem = [AVPlayerItem playerItemWithURL:fileURL];
        //AVPlayer *avPlayer = [[AVPlayer playerWithURL:[NSURL URLWithString:url]] retain];

        _avPlayer = [[AVPlayerView alloc] initWithFrame:self.view.bounds];
        [_avPlayer setPlayerForLocalFile:localVid];

        
//        AVPlayerLayer *avPlayerLayer = [[AVPlayerLayer alloc] init];
//        [avPlayerLayer setPlayer:_avPlayer];
//        avPlayerLayer.frame = newView.bounds;
//        newView.backgroundColor = [UIColor redColor];
//        
//        [newView.layer addSublayer:avPlayerLayer];
        
        [_postVideoContainer addSubview:_avPlayer];

        [_avPlayer.player play];

        
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_avPlayer.player currentItem]];
        
        
        float dragValue = 0;
        
        NSLog(@"%lld %d",_avPlayer.playerItem.duration.value,_avPlayer.playerItem.duration.timescale);
        float lenght = _avPlayer.playerItem.duration.value/_avPlayer.playerItem.duration.timescale;
        int frames = roundf(lenght * 30);
        
        int maxStart = frames - (6 * 30);
        int start = map(dragValue, 0, 1, 0, maxStart);
        _startTime = start;
        NSLog(@"lenght %f %i %i",lenght,frames,start);
        [_avPlayer.player seekToTime:CMTimeMake((_startTime/30.0) * _avPlayer.playerItem.duration.timescale, _avPlayer.playerItem.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        //[_avPlayer pause];
        
        _lineCurrentPostion.width = (6.0/lenght) * _lineView.width;
        _lineCurrentPostion.left = clamp(0, 1.0, map(0, 0, 1, 0, _lineView.width - _lineCurrentPostion.width));
        
        //        _video = [[GPUImageMovie alloc] initWithAsset:asset];
        //        _video.delegate = self;
        //
        //        [_video startProcessing];
        
        
    }];
    
}

- (IBAction)cancelRecording:(id)sender {
    
    [_timeLabelTimer invalidate],_timeLabelTimer = nil;
    [_stopRecTimer invalidate],_stopRecTimer = nil;
    [_forceStopTimer invalidate], _forceStopTimer = nil;
    
    _recording = NO;
    [_filter removeTarget:_movieWriter];
    
    _videoCamera.audioEncodingTarget = nil;
    
    [_movieWriter finishRecording];
    
    [self setCurrentState:StatePre];
}

- (void)export {
    NSString *localVid = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    NSURL* fileURL = [NSURL fileURLWithPath:localVid];
    int i = [[NSUserDefaults standardUserDefaults] integerForKey:kUploadedVideos];
    i++;
    NSString *outLocalVid = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Movie_out.mp4"]];
    NSURL* outFileURL = [NSURL fileURLWithPath:outLocalVid];
    
    
    unlink([outLocalVid UTF8String]);
    
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    
    NSURL *url = outFileURL;
    session.outputURL = url;
    session.outputFileType = AVFileTypeAppleM4V;
    
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack = [videoTracks objectAtIndex:0];
    
    
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(_startTime/30.0, videoTrack.timeRange.duration.timescale),
                                            CMTimeMakeWithSeconds(6.0, videoTrack.timeRange.duration.timescale));
    
    
    //CMTimeRange timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds((_startTime/30.0) * _playerItem.duration.timescale, _playerItem.duration.timescale),
    //CMTimeMakeWithSeconds(((_startTime + 6)/30.0) * _playerItem.duration.timescale, _playerItem.duration.timescale));
    session.timeRange = timeRange;

    [session exportAsynchronouslyWithCompletionHandler:^{
        switch (session.status) {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"COMPLETE");
                [self upload];
                
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed: %@", session.error);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled: %@", session.error);
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"%f", session.progress);
                break;
            default:
                break;
        }
    }];
    
}

-(void)playerItemDidReachEnd:(NSNotification *)not{
    [_avPlayer.player seekToTime:CMTimeMake((_startTime/30.0) * _avPlayer.playerItem.duration.timescale, _avPlayer.playerItem.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)upload {
    NSString *localVid = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie_out.mp4"];
    NSURL* fileURL = [NSURL fileURLWithPath:localVid];
    
    __block NSError *error = nil;
    NSString *location = (_placeString) ? _placeString : [@"[Unknown location]" uppercaseString];
    NSLog(@"%@",location);
    NSString *author = [[AppManager sharedManager] author];
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    
    NSMutableURLRequest *urlRequest = [[APIClient shareClient] multipartFormRequestWithMethod:@"POST" path:@"/ahd/upload" parameters:@{ @"location":location, @"author":author, @"timestamp":@(timestamp) } constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:fileURL name:@"file" error:&error];
    }];
    
    NSString *secretKey = @"lkjerwlkj&hw-ertlbflu4345983x0!";
    NSString *path = @"/ahd/upload";
    NSString *fileHash = [[NSData dataWithContentsOfURL:fileURL] MD5];
    NSLog(@"%@", fileHash);
    NSString *hash = [[NSString stringWithFormat:@"%@%@%@",path,fileHash,secretKey] MD5];
    
    //[urlRequest setAllHTTPHeaderFields:@{ @"X-Hash" : hash}];
    [urlRequest setValue:hash forHTTPHeaderField:@"X-Hash"];
    
    if (!error) {
        AFHTTPRequestOperation *operation = [[APIClient shareClient] HTTPRequestOperationWithRequest:urlRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
            int i = [[NSUserDefaults standardUserDefaults] integerForKey:kUploadedVideos];
            i++;
            [[NSUserDefaults standardUserDefaults] setInteger:i forKey:kUploadedVideos];
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            double secs = now - [AppManager sharedManager].disappearTime;
            
            int numberOfClips = secs/6;
            int newIndex = (numberOfClips + [AppManager sharedManager].currentIndex) % [AppManager sharedManager].videos.count;
            
            double yourTime = ([AppManager sharedManager].videos.count - newIndex) * 6;
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:yourTime];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setAMSymbol:@"AM"];
            [dateFormatter setPMSymbol:@"PM"];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            [dateFormatter setDateFormat:@"hh:mm a"];
            _uploadTimeLabel.text = [[dateFormatter stringFromDate:date] uppercaseString];
            [dateFormatter setDateFormat:@"dd LLL yyyy"];
            _uploadDateLabel.text = [[dateFormatter stringFromDate:date] uppercaseString];
            
            [self setCurrentState:StateDone];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Fel fel fel!" message:@"Det blev fel!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [a show];
            NSLog(@"Error: %@ %@", operation.responseString, [error localizedDescription]);
        }];
        
        
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            NSLog(@"Uploading: %.0f%%", ((float)totalBytesWritten/(float)totalBytesExpectedToWrite)*100.0);
            _procentLabel.text = [NSString stringWithFormat:@"%.0f%%",((float)totalBytesWritten/(float)totalBytesExpectedToWrite)*100.0];
        }];
        [operation start];
    }
}

-(void)setCurrentState:(State)currentState{
    if (currentState != _currentState) {
        _currentState = currentState;
        [self updateForCurrentState];
    } else {
        _currentState = currentState;
    }
    
}

-(void)updateForCurrentState{
    
    
    [UIView animateWithDuration:0.6 animations:^{
        
        if (_currentState == StatePre) {
            _uploadView.alpha = 0.0;
            _preRecordingView.alpha = 1.0;
            _postView.alpha = 0.0;
            _recordingView.alpha = 0.0;
            
            _lineCurrentPostion.alpha = 0.0;
            _lineViewProgress.alpha = 0.0;
            
            _lineView.frame = CGRectMake((self.view.bounds.size.width - 144)/2, _lineView.top, 144, 0.5);
            
            _closeButton.alpha = 1.0;
            _backButton.alpha = 0.0;
            _doneView.alpha = 0.0;
            _lineViewProgress.alpha = 0.0;
        } else if (_currentState == StateRecording){
            _uploadView.alpha = 0.0;
            _preRecordingView.alpha = 0.0;
            _postView.alpha = 0.0;
            _recordingView.alpha = 1.0;
            
            _lineCurrentPostion.alpha = 0.0;
            _lineViewProgress.alpha = 1.0;
            
            _lineView.frame = CGRectMake((self.view.bounds.size.width - 164)/2, _lineView.top, 164, 0.5);
            _closeButton.alpha = 0.0;
            _backButton.alpha = 0.0;
            _doneView.alpha = 0.0;
            _lineViewProgress.alpha = 0.0;            
        } else if (_currentState == StatePost){
            [_geoCoder reverseGeocodeLocation:[LocationManager sharedManager].locationManager.location  completionHandler: ^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                _placeString = [[NSString stringWithFormat:@"%@, %@",[placemark.addressDictionary valueForKey:@"City"],[placemark.addressDictionary valueForKey:@"SubLocality"]] uppercaseString];
            }];
            _uploadView.alpha = 0.0;
            _preRecordingView.alpha = 0.0;
            _postView.alpha = 1.0;
            _recordingView.alpha = 0.0;
            
            _lineCurrentPostion.alpha = 1.0;
            _lineViewProgress.alpha = 1.0;
            _lineView.frame = CGRectMake(20, _lineView.top, self.view.bounds.size.width - 40, 0.5);
            _closeButton.alpha = 0.0;
            _backButton.alpha = 1.0;
            _doneView.alpha = 0.0;
            _lineViewProgress.alpha = 1.0;
        } else if(_currentState == StateUploading){
            _uploadView.alpha = 1.0;
            _doneView.alpha = 0.0;
            _postView.alpha = 0.0;
            _backButton.alpha = 0.0;
            _lineViewProgress.alpha = 0.0;
        } else if(_currentState == StateDone){
            _uploadView.alpha = 0.0;
            _doneView.alpha = 1.0;
            _postTitleLabel.alpha = 0;
            _postView.alpha = 0;
            _lineViewProgress.alpha = 0.0;
        }
        
    } completion:^(BOOL finished) {
        if (_currentState == StateRecording) {
            [self startRecording];
        }
    }];
}

- (IBAction)backButton:(id)sender {
    
    if (_currentState == StatePost) {
        NSString *localVid = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
        NSURL* fileURL = [NSURL fileURLWithPath:localVid];
        unlink([localVid UTF8String]);
        [self setCurrentState:StatePre];
        [_videoCamera startCameraCapture];
        [_postVideoContainer removeFromSuperview];
        [_filter removeTarget:_movieWriter];
        [_movieWriter cancelRecording];
        _movieWriter = nil;
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:fileURL size:CGSizeMake(960.0, 540.0)];
        [_filter addTarget:_movieWriter];
    }
    
}

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

}
@end

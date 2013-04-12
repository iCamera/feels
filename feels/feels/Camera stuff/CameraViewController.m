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

#define videoWidth 1280
#define videoHeight 720

@interface CameraViewController()
@property (weak, nonatomic) IBOutlet GPUImageView *gpuImageView;

@end

@implementation CameraViewController


#pragma mark - Initialization and teardown

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    //    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    //    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    //    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
    
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    //_filter = [[GPUImageSepiaFilter alloc] init];
    
    

    _filter = [[FeelsFilter alloc] init];
    
    [_filter setSourceImage:[UIImage imageNamed:@"lookup_miss_etikate"]];
    
    //    filter = [[GPUImageTiltShiftFilter alloc] init];
    //    [(GPUImageTiltShiftFilter *)filter setTopFocusLevel:0.65];
    //    [(GPUImageTiltShiftFilter *)filter setBottomFocusLevel:0.85];
    //    [(GPUImageTiltShiftFilter *)filter setBlurSize:1.5];
    //    [(GPUImageTiltShiftFilter *)filter setFocusFallOffRate:0.2];
    
    //    filter = [[GPUImageSketchFilter alloc] init];
    //    filter = [[GPUImageSmoothToonFilter alloc] init];
    //    GPUImageRotationFilter *rotationFilter = [[GPUImageRotationFilter alloc] initWithRotation:kGPUImageRotateRightFlipVertical];
    
    [_videoCamera addTarget:_filter];

    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [_filter addTarget:filterView];
    [self.view addSubview:filterView];
    //    filterView.fillMode = kGPUImageFillModeStretch;
    //    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    // Record a movie for 10 s and store it in /Documents, visible via iTunes file sharing
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1080.0, 1920.0)];
    [_filter addTarget:_movieWriter];
    
    [_videoCamera startCameraCapture];
    
    double delayToStartRecording = 0.5;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Start recording");
        
        _videoCamera.audioEncodingTarget = _movieWriter;
        [_movieWriter startRecording];
        
        //        NSError *error = nil;
        //        if (![videoCamera.inputCamera lockForConfiguration:&error])
        //        {
        //            NSLog(@"Error locking for configuration: %@", error);
        //        }
        //        [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        //        [videoCamera.inputCamera unlockForConfiguration];
        
        double delayInSeconds = 10.0;
        dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
            
            [_filter removeTarget:_movieWriter];
            _videoCamera.audioEncodingTarget = nil;
            [_movieWriter finishRecordingWithCompletionHandler:^{
                NSLog(@"Movie completed");    
            }];
            
            
        });
    });
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
  [_filter setSourceImage:[UIImage imageNamed:@"lookup_miss_etikate"]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    return;
    float dragValue = [[touches anyObject] locationInView:self.view].y/self.view.height;
    float first = clamp(0.0,1.0,map(dragValue, 0, 0.5, 1.0, 0.0));
    
    float second = 0.0;
    
    if (dragValue < 0.5) {
        second = clamp(0.0,1.0,map(dragValue, 0.0, 0.5, 0.0, 1.0));
    } else {
        second = clamp(0.0,1.0,map(dragValue, 0.5, 1.0, 1.0, 0.0));
    }
    
    float third = clamp(0.0,1.0,map(dragValue, 0.5, 1.0, 0.0, 1.0));
    
    if (!_filter.loading) {
        [_filter setSourceImage:[UIImage imageNamed:@"lookup_miss_etikate"]];
    }
    


    
}

@end

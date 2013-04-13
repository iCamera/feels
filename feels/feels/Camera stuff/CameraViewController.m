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
@property (strong, nonatomic)  GPUImageView *gpuImageView;
@property (strong, nonatomic) UIImageView *imageView;
@property(nonatomic,strong) FeelsFilter *filter;
@property(nonatomic,assign) int changeCounter;

@end

@implementation CameraViewController


#pragma mark - Initialization and teardown

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    //    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    //    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    //    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
    
    _videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
    _videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    //_filter = [[GPUImageSepiaFilter alloc] init];
    
    

    _filter = [[FeelsFilter alloc] init];
    UIImage *i = [self blendImage:@"test" andImage2:@"lookup_xpro" first:0.0 second:0.0];
    [_filter setSourceImage:i];
    
    //    filter = [[GPUImageTiltShiftFilter alloc] init];
    //    [(GPUImageTiltShiftFilter *)filter setTopFocusLevel:0.65];
    //    [(GPUImageTiltShiftFilter *)filter setBottomFocusLevel:0.85];
    //    [(GPUImageTiltShiftFilter *)filter setBlurSize:1.5];
    //    [(GPUImageTiltShiftFilter *)filter setFocusFallOffRate:0.2];
    
    //    filter = [[GPUImageSketchFilter alloc] init];
    //    filter = [[GPUImageSmoothToonFilter alloc] init];
    //    GPUImageRotationFilter *rotationFilter = [[GPUImageRotationFilter alloc] initWithRotation:kGPUImageRotateRightFlipVertical];
    
    [_videoCamera addTarget:_filter];

    _gpuImageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [_filter addTarget:_gpuImageView];

    [self.view addSubview:_gpuImageView];
    //    filterView.fillMode = kGPUImageFillModeStretch;
    _gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
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
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:_imageView];

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _gpuImageView.frame = self.view.bounds;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

    if (_changeCounter < 5) {
        _changeCounter ++;
        return;
    }
    _changeCounter = 0;
    
    float dragValue = [[touches anyObject] locationInView:self.view].x/self.view.width;

    
    if (dragValue < 0.25) {
        [_videoCamera removeTarget:_filter];
        _filter = [[FeelsFilter alloc] init];
        UIImage *i = [self blendImage:@"lookup" andImage2:@"lookup_xpro" first:map(dragValue, 0.0, 0.25, 1.0, 0.0) second:0.0];
        [_filter setSourceImage:i];

        [_filter addTarget:_gpuImageView];
        [_videoCamera addTarget:_filter];
        
    } else if (dragValue < 0.50){
        [_videoCamera removeTarget:_filter];
        _filter = [[FeelsFilter alloc] init];
        UIImage *i = [self blendImage:@"lookup_xpro" andImage2:@"lookup_toaster" first:map(dragValue, 0.25, 0.50, 1.0, 0.0) second:0.0];
        [_filter setSourceImage:i];
        
        [_filter addTarget:_gpuImageView];
        [_videoCamera addTarget:_filter];
    } else if (dragValue < 0.75){
        [_videoCamera removeTarget:_filter];
        _filter = [[FeelsFilter alloc] init];
        UIImage *i = [self blendImage:@"lookup_toaster" andImage2:@"lookup_nashville" first:map(dragValue, 0.50, 0.75, 1.0, 0.0) second:0.0];
        [_filter setSourceImage:i];
        
        [_filter addTarget:_gpuImageView];
        [_videoCamera addTarget:_filter];
    } else {
        [_videoCamera removeTarget:_filter];
        _filter = [[FeelsFilter alloc] init];
        UIImage *i = [self blendImage:@"lookup_nashville" andImage2:@"lookup" first:map(dragValue, 0.75, 1.0, 1.0, 0.0) second:0.0];
        [_filter setSourceImage:i];
        
        [_filter addTarget:_gpuImageView];
        [_videoCamera addTarget:_filter];
    }
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

@end

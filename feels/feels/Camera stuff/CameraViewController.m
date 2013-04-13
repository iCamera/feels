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
#define videoWidth 1280
#define videoHeight 720

@interface CameraViewController()
@property (strong, nonatomic)  GPUImageView *gpuImageView;
@property (strong, nonatomic) UIImageView *imageView;
@property(nonatomic,strong) FeelsFilter *filter;
@property(nonatomic,assign) int changeCounter;
@property(nonatomic,assign) BOOL recording;
@property (weak, nonatomic) IBOutlet UILabel *startRecordingLabel;
@property (weak, nonatomic) IBOutlet UILabel *tapLabel;
@property (weak, nonatomic) IBOutlet UIView *preRecordingView;

@property (weak, nonatomic) IBOutlet UIView *recordingView;
@property (weak, nonatomic) IBOutlet UILabel *recordingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingTapLabel;


@end

@implementation CameraViewController


#pragma mark - Initialization and teardown

-(void)viewDidLoad{
    [super viewDidLoad];
    
    {
        _startRecordingLabel.font = [UIFont GeoSansLight:_startRecordingLabel.font.pointSize];
        _tapLabel.font = [UIFont GeogrotesqueGardeExtraLight:_tapLabel.font.pointSize];
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake((_tapLabel.superview.width-144)/2, _startRecordingLabel.bottom - 2, 144, 0.5)];
        v.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        v.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [_tapLabel.superview addSubview:v];
    }

    {
        _startRecordingLabel.font = [UIFont AvantGardeExtraLight:_startRecordingLabel.font.pointSize];
    }
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];

    
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
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1280.0, 720.0)];

    [_filter addTarget:_movieWriter];
    
    [_videoCamera startCameraCapture];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _gpuImageView.frame = self.view.bounds;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    
}

-(void)tap{

    if (_recording) {
        [self stopRecording];
    } else {
        [self startRecording];
    }
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

-(void)startRecording{
    _recording = YES;
    double delayToStartRecording = 0.0;
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
        
        double delayInSeconds = 6.0;
        dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
            
            [self stopRecording];
            
        });
    });
    
}

-(void)stopRecording{
    _recording = NO;
    [_filter removeTarget:_movieWriter];
    _videoCamera.audioEncodingTarget = nil;
    [_movieWriter finishRecordingWithCompletionHandler:^{
        NSLog(@"Movie completed");

        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        NSString *localVid = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
        NSURL* fileURL = [NSURL fileURLWithPath:localVid];

        __block NSError *error = nil;
        NSString *location = @"Östermalm, Stockholm";
        NSString *author = [[AppManager sharedManager] author];
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
        NSMutableURLRequest *urlRequest = [[APIClient shareClient] multipartFormRequestWithMethod:@"POST" path:@"/ahd/upload" parameters:@{ @"location":location, @"author":author, @"timestamp":@(timestamp) } constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:fileURL name:@"file" error:&error];
        }];
        
        if (!error) {
            AFHTTPRequestOperation *operation = [[APIClient shareClient] HTTPRequestOperationWithRequest:urlRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Success: %@", responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@ %@", operation.responseString, [error localizedDescription]);
            }];
            
            
            [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                NSLog(@"Uploading: %.0f%%", ((float)totalBytesWritten/(float)totalBytesExpectedToWrite)*100.0);
            }];
            [operation start];
        }
        
//        [library writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
//            if (!error) {
//                NSLog(@"Video Saved - %@",assetURL);
//            } else {
//                NSLog(@"%@: Error saving context: %@", [self class], [error localizedDescription]);
//            }
//        }];
        
    }];
    
}

@end

//
//  ViewController.h
//  opengl-inputs-template
//
//  Created by Andreas Areschoug on 4/6/13.
//  Copyright (c) 2013 Andreas Areschoug. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "FeelsFilter.h"
@interface CameraViewController : UIViewController

@property(nonatomic,strong) GPUImageVideoCamera *videoCamera;
@property(nonatomic,strong) FeelsFilter *filter;
@property(nonatomic,strong) GPUImageMovieWriter *movieWriter;


@end


//
//  FeelsFilter.h
//  feels
//
//  Created by Andreas Areschoug on 2013-04-12.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "GPUImage.h"
@interface FeelsFilter : GPUImageFilterGroup

@property(nonatomic,strong) GPUImagePicture *lookupImageSource;
@property(nonatomic,assign) BOOL loading;
@property(nonatomic,assign) float saturation;
@property(nonatomic,strong) UIImage *sourceImage;

@end

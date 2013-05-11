//
//  FeelsFilter.m
//  feels
//
//  Created by Andreas Areschoug on 2013-04-12.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "FeelsFilter.h"

@implementation FeelsFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
//    UIImage *image = [UIImage imageNamed:@"lookup_miss_etikate.png"];
//    NSAssert(image, @"To use GPUImageMissEtikateFilter you need to add lookup_miss_etikate.png from GPUImage/framework/Resources to your application bundle.");
//    
//    _lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
//    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
//    
//    [_lookupImageSource addTarget:lookupFilter atTextureLocation:1];
//    [_lookupImageSource processImage];
//    
//    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
//    self.terminalFilter = lookupFilter;
    
    
    return self;
}

-(void)prepareForImageCapture {
    [_lookupImageSource processImage];

    [super prepareForImageCapture];
}

-(void)setSourceImage:(UIImage *)sourceImage{
    _loading = YES;

    
//    GPUImagePicture *i = [[GPUImagePicture alloc] initWithImage:sourceImage];
//    [i addTarget:saturation];
//    [i processImage];
    _sourceImage = sourceImage;
    
    
    _lookupImageSource = [[GPUImagePicture alloc] initWithImage:_sourceImage];
    
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
    saturation.saturation = _saturation;
    
    [_lookupImageSource addTarget:saturation atTextureLocation:1];
    [_lookupImageSource addTarget:lookupFilter atTextureLocation:1];

    [_lookupImageSource processImage];
    

    NSLog(@"%f",_saturation);
    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
    self.terminalFilter = lookupFilter;
    _loading = NO;
}

-(void)setSaturation:(float)saturation{
    _saturation = saturation;
    NSLog(@"%f",saturation);
}
@end

//
//  MixerController.m
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "MixerController.h"
#import "Intense.h"
#import "AppManager.h"
#import "NSTimer+Block.h"
#import "UIView_DrawRect.h"
#import "MathHelper.h"

@implementation MixerController {
    __block float val;
    UIView *v;
}

static inline float radians(double degrees) { return degrees * M_PI / 180; }

- (void)viewDidLoad {
    [super viewDidLoad];
    val = 1;
    
    v = [UIView viewWithFrame:CGRectMake(50, 50, 170, 170) drawRect:^(CGRect rect) {
        
        CGMutablePathRef path0 = CGPathCreateMutable();
        CGPathMoveToPoint(path0, NULL, 55.56715, 152.8784);
        CGPathAddCurveToPoint(path0, NULL, 52.96215, 152.8784, 50.06665, 152.0869, 47.4668, 150.7671);
        CGPathAddCurveToPoint(path0, NULL, 44.86525, 149.448, 42.56055, 147.59985, 41.1245, 145.5154);
        CGPathAddCurveToPoint(path0, NULL, 41.1245, 145.5154, 4.63059999999999, 92.5901, 4.63059999999999, 92.5901);
        CGPathAddCurveToPoint(path0, NULL, 2.82300000000001, 89.97215, 1.85524999999998, 86.20385, 1.85669999999999, 82.5542);
        CGPathAddCurveToPoint(path0, NULL, 1.8562, 80.0288, 2.31834999999998, 77.5613, 3.26319999999998, 75.57325);
        CGPathAddCurveToPoint(path0, NULL, 3.26319999999998, 75.57325, 30.8390999999999, 17.4995, 30.8390999999999, 17.4995);
        CGPathAddCurveToPoint(path0, NULL, 31.99245, 15.0681, 34.1579499999999, 12.74415, 36.71265, 10.9829);
        CGPathAddCurveToPoint(path0, NULL, 39.26635, 9.22045, 42.2079999999999, 8.02175, 44.8904, 7.80739999999995);
        CGPathAddCurveToPoint(path0, NULL, 44.8904, 7.80739999999995, 108.95775, 2.6599, 108.95775, 2.6599);
        CGPathAddCurveToPoint(path0, NULL, 109.27615, 2.6343, 109.60085, 2.6216, 109.92995, 2.6216);
        CGPathAddCurveToPoint(path0, NULL, 109.9314, 2.6216, 109.93285, 2.6216, 109.93435, 2.6216);
        CGPathAddCurveToPoint(path0, NULL, 112.5393, 2.6216, 115.43435, 3.41309999999998, 118.03395, 4.7329);
        CGPathAddCurveToPoint(path0, NULL, 120.6355, 6.052, 122.9402, 7.8999, 124.37625, 9.9844);
        CGPathAddCurveToPoint(path0, NULL, 124.37625, 9.9844, 160.8694, 62.9104, 160.8694, 62.9104);
        CGPathAddCurveToPoint(path0, NULL, 162.677, 65.52835, 163.6448, 69.29665, 163.6433, 72.9463);
        CGPathAddCurveToPoint(path0, NULL, 163.6438, 75.4717, 163.1814, 77.9392, 162.2366, 79.92725);
        CGPathAddCurveToPoint(path0, NULL, 162.2366, 79.92725, 134.6614, 138.0005, 134.6614, 138.0005);
        CGPathAddCurveToPoint(path0, NULL, 133.50755, 140.4319, 131.34205, 142.7556, 128.78735, 144.51685);
        CGPathAddCurveToPoint(path0, NULL, 126.23365, 146.2793, 123.29225, 147.47805, 120.60965, 147.6924);
        CGPathAddLineToPoint(path0, NULL, 56.5432, 152.8401);
        CGPathAddCurveToPoint(path0, NULL, 56.5432, 152.8401, 56.5432, 152.8401, 56.5432, 152.8401);
        CGPathAddCurveToPoint(path0, NULL, 56.22435, 152.86575, 55.90015, 152.8784, 55.57105, 152.8784);
        CGPathAddCurveToPoint(path0, NULL, 55.5696, 152.8784, 55.5686, 152.8784, 55.56715, 152.8784);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        for (int i = 0; i < 5; i++) {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, 0, 10);
            float midX = 82.5;
            float midY = 77.5;
            CGContextTranslateCTM(context, midX, midY);
            float curve = -1*cosf((val+1)*2*(M_PI/2));
            float scale = map(curve, -1, 1, 0.8, 1.0);
            CGContextScaleCTM(context, scale, scale);
            CGContextRotateCTM(context, radians((330+(map(val+i, 0, 1, 0, 40)  * map(val, 0, 1, 5, 10)))/(i+1)));
            CGContextTranslateCTM(context, -midX, -midY);
            CGContextAddPath(context, path0);
            [[[UIColor blackColor] colorWithAlphaComponent:map(i, 0, 4, 0.8, 0.3)] setStroke];
            CGContextSetLineWidth(context, 0.5);
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
        }
        
        CGPathRelease(path0);
    }];
    
    [self.view addSubview:v];
    
    [NSTimer scheduledTimerWithTimeInterval:1/30.0 completion:^{
        val += 0.0005;
        [v setNeedsDisplay];
    } repeat:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /*
    [NSTimer scheduledTimerWithTimeInterval:1.0 completion:^{
        NSLog(@"%i", (int)([[NSDate date] timeIntervalSince1970] / 6) % (int)val);
    } repeat:YES];
    //[NSTimer scheduledTimerWithTimeInterval:2. target:self selector:@selector(start) userInfo:nil repeats:NO];
    
    double numberOfClipsPlayed = floor([[NSDate date] timeIntervalSince1970] / 6);
    double secondsIntoClip = [[NSDate date] timeIntervalSince1970] - (numberOfClipsPlayed*6);
    
    int numberOfClips = 10;
    double playlistLenght = numberOfClips*6;
    */
    
    
}

- (void)start {
    
    [[Intense shared] play];
    
}

- (IBAction)sliderDidChange:(UISlider *)slider {
   
}

@end

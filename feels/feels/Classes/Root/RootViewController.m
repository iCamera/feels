//
//  RootViewController.m
//  feels
//
//  Created by Hannes Wikström on 2013-04-12.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "RootViewController.h"
#import "ArchiveViewController.h"
#import "CameraViewController.h"
#import "MathHelper.h"
#import "VideoViewController.h"
#import "VideoModel.h"
#import "KVOR.h"
#import "AppManager.h"
#import "HCAnimator.h"
#import "AVPlayerView.h"

@interface RootViewController ()
@property (weak, nonatomic) IBOutlet UIView *detailView;

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UILabel *timeUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *createLabel;
@property (weak, nonatomic) IBOutlet UILabel *archiveLabel;
@property (weak, nonatomic) IBOutlet UIImageView *menuArrow;
@property (weak, nonatomic) IBOutlet UIButton *archiveButton;

@property (weak, nonatomic) IBOutlet UIView *msView;
@property (weak, nonatomic) IBOutlet UILabel *msLabel;
@property (weak, nonatomic) IBOutlet UILabel *msUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *msDescLabel;

@property (weak, nonatomic) IBOutlet UIImageView *vidPlaceholderImage;
@property (weak, nonatomic) IBOutlet UILabel *vidTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *vidDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *vidLocationLabel;
@property (weak, nonatomic) IBOutlet UIView *fadeView;

@property (strong, nonatomic) AVPlayerView *alaskaVideo;

@property (nonatomic, strong) ArchiveViewController *archiveViewController;
@property (nonatomic, assign) BOOL isArchiveMode;
@property (nonatomic, assign) BOOL isFullscreen;
@property (nonatomic, assign) BOOL msActive;
@property (weak, nonatomic) IBOutlet UIView *videoWrapperView;

@property(strong,nonatomic) VideoViewController *videoViewController;

@end

@implementation RootViewController

static inline float StrongEaseOut(float time, float begin, float change, float duration) {
    return change * ((time = time / duration - 1) * time * time * time * time + 1) + begin;
}

float elasticEaseOut(float t, float b, float c, float d){
    if (t == 0) {
        return b;
    }
    
    if ((t /= d) == 1) {
        return b + c;
    }
    
    float p = 1.0;
    float a = 1.0;
    float s = 0;
    
    if (!p) {
        p = d * 0.3;
    }
    
    if (!a || a < fabs(c)) {
        a = c;
        s = p / 4;
    }
    else {
        s = p / (2 * M_PI) * asin(c / a);
    }
    return a * powf(2, -10 * t) * sin((t * d - s) * (2 * M_PI) / p) + c + b;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _alaskaVideo = [[AVPlayerView alloc] initWithFrame:self.view.bounds];
    [_alaskaVideo setPlayerForMp4File:@"small"];
    [self.view addSubview:_alaskaVideo];
    [[_alaskaVideo player]play];
    [_alaskaVideo setDidReachEnd:^(AVPlayerView *view){
        [view.player seekToTime:kCMTimeZero];
    }];
    
    /* MENU */
    [_timeUnitLabel setFont:[UIFont GeoSansLight:11]];
    [_timeUnitLabel setTextColor:[UIColor colorWithRed:0.388 green:0.384 blue:0.365 alpha:1]];
    [_timeUnitLabel setKerning:1.0];
    
    [_timeLabel setFont:[UIFont AvantGardeExtraLight:27]];
    [_timeLabel setTextColor:[UIColor colorWithRed:0.388 green:0.384 blue:0.365 alpha:1]];
    _timeLabel.text = [NSString stringWithFormat:@"%d", [AppManager sharedManager].seconds];
    
    [_createLabel setFont:[UIFont GeoSansLight:17]];
    [_createLabel setTextColor:[UIColor colorWithRed:0.388 green:0.384 blue:0.365 alpha:1]];
    [_createLabel setKerning:1.0];
    
    [_archiveLabel setFont:[UIFont GeoSansLight:11]];
    [_archiveLabel setTextColor:[UIColor colorWithRed:0.388 green:0.384 blue:0.365 alpha:1]];
    [_archiveLabel setKerning:1.0];
    
    _menuArrow.transform = CGAffineTransformMakeRotation(-M_PI);
    
    [_msLabel setFont:[UIFont AvantGardeExtraLight:21]];
    [_msUnitLabel setFont:[UIFont GeoSansLight:11]];
    [_msDescLabel setFont:[UIFont GeoSansLight:10]];
    
    /* VIDEO */
    [_vidTimeLabel setFont:[UIFont AvantGardeExtraLight:32]];
    [_vidDateLabel setFont:[UIFont AvantGardeExtraLight:24]];
    [_vidLocationLabel setFont:[UIFont AvantGardeExtraLight:14]];
    float kern = 1.1;
    [_vidTimeLabel setKerning:kern];
    [_vidDateLabel setKerning:kern];
    [_vidLocationLabel setAdjustsLetterSpacingToFitWidth:YES];
    [_vidLocationLabel setAdjustsFontSizeToFitWidth:YES];
    [_vidDateLabel setAdjustsLetterSpacingToFitWidth:YES];
    [_vidDateLabel setAdjustsFontSizeToFitWidth:YES];
    [_vidTimeLabel setAdjustsLetterSpacingToFitWidth:YES];
    [_vidTimeLabel setAdjustsFontSizeToFitWidth:YES];
    
    CGFloat shOpacity = 0.4;
    CGFloat shRadius = 2.0;
    CGSize shOffset = CGSizeMake(0,0);
    
    _vidTimeLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _vidTimeLabel.layer.shadowOpacity = shOpacity;
    _vidTimeLabel.layer.shadowRadius = shRadius;
    _vidTimeLabel.layer.shadowOffset = shOffset;
    
    _vidDateLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _vidDateLabel.layer.shadowOpacity = shOpacity;
    _vidDateLabel.layer.shadowRadius = shRadius;
    _vidDateLabel.layer.shadowOffset = shOffset;
    
    _vidLocationLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _vidLocationLabel.layer.shadowOpacity = shOpacity;
    _vidLocationLabel.layer.shadowRadius = shRadius;
    _vidLocationLabel.layer.shadowOffset = shOffset;
    
    /* Archive controller */
    self.archiveViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ArchiveViewController"];
    [self addChildViewController:self.archiveViewController];
    self.archiveViewController.view.origin = CGPointMake(self.view.height, 0);
    [self.view addSubview:self.archiveViewController.view];
    [self.view bringSubviewToFront:_menuView];
    
    /* Gesture recongnizers */
    UIPanGestureRecognizer *panGesturizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(menuPanned:)];
    [_archiveButton addGestureRecognizer:panGesturizer];
    
    
    _videoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
    [self addChildViewController:_videoViewController];
    [self.videoWrapperView addSubview:_videoViewController.view];
    _videoViewController.view.backgroundColor = [UIColor blackColor];
    _videoViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    id b = ^(VideoModel *video) {
        //NSLog(@"%@", [video.videoURL absoluteString]);
        _vidLocationLabel.text = [video.location uppercaseString];
        {
            
            _vidDateLabel.alpha = 0;
            _vidTimeLabel.alpha = 0;
            _vidLocationLabel.alpha = 0;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setAMSymbol:@"AM"];
            [dateFormatter setPMSymbol:@"PM"];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            [dateFormatter setDateFormat:@"hh:mm a"];
            _vidTimeLabel.text = [[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:video.timestamp]] uppercaseString];
            [dateFormatter setDateFormat:@"dd LLL yyyy"];
            _vidDateLabel.text = [[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:video.timestamp]] uppercaseString];
            
            [_vidTimeLabel setKerning:kern];
            [_vidDateLabel setKerning:kern];
            [_vidLocationLabel setAdjustsLetterSpacingToFitWidth:YES];
            [_vidLocationLabel setAdjustsFontSizeToFitWidth:YES];
            [_vidDateLabel setAdjustsLetterSpacingToFitWidth:YES];
            [_vidDateLabel setAdjustsFontSizeToFitWidth:YES];
            [_vidTimeLabel setAdjustsLetterSpacingToFitWidth:YES];
            [_vidTimeLabel setAdjustsFontSizeToFitWidth:YES];
            
            [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
                _vidDateLabel.alpha = 1;
                _vidTimeLabel.alpha = 1;
                _vidLocationLabel.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 delay:3 options:0 animations:^{
                    
                    _vidDateLabel.alpha = 0;
                    _vidTimeLabel.alpha = 0;
                    _vidLocationLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }
    };
    
    
    [_videoViewController setVideoDidChange:b];
    
    [KVOR target:[AppManager sharedManager] keyPath:@"seconds" task:^(NSString *keyPath, NSDictionary *change) {
        //BAM!
        self.timeLabel.text = [NSString stringWithFormat:@"%d", [AppManager sharedManager].seconds];
    }];
    
    [KVOR target:[AppManager sharedManager] keyPath:@"points" task:^(NSString *keyPath, NSDictionary *change) {
        NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
        numberFormat.usesGroupingSeparator = YES;
        numberFormat.groupingSeparator = @",";
        numberFormat.groupingSize = 3;
        //self.msLabel.text = [NSString stringWithFormat:@"%d", [AppManager sharedManager].points];
        self.msLabel.text = [numberFormat stringFromNumber:[NSNumber numberWithInt:[AppManager sharedManager].points]];
    }];
    _videoViewController.view.userInteractionEnabled = NO;
    [_videoWrapperView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    
    id block = ^(UIScrollView *scrollView){
        if (scrollView.contentOffset.x < 0) {
            float left = 0;
            
            left = -(scrollView.contentOffset.x + 8);
            
            _menuView.left = left;
            self.archiveViewController.view.left = left+_menuView.width-14;
            _videoWrapperView.left = map(clamp(0, 1, left/(self.view.bounds.size.width - self.view.width)), 1, 0, 0, -120);
            
            _fadeView.alpha = map(left/(self.view.bounds.size.width - self.view.width), 1, 0, 0, 0.9);
            _archiveViewController.imageViewsContainer.left = scrollView.contentOffset.x + 8;
        } else {
            float left = -(8);
            
            _menuView.left = left;
            self.archiveViewController.view.left = left+_menuView.width-14;
            _videoWrapperView.left = map(clamp(0, 1, left/(self.view.bounds.size.width - self.view.width)), 1, 0, 0, -120);
            
            _fadeView.alpha = map(left/(self.view.bounds.size.width - self.view.width), 1, 0, 0, 0.9);
            _archiveViewController.imageViewsContainer.left = 8;
        }
    };
    [_archiveViewController setDidScroll:block];
    _alaska = YES;
    [self updateVideoMode];
}

-(void)tap:(UITapGestureRecognizer *)tap{
    NSLog(@"HEY");
    
    if (_isFullscreen) {
        _isFullscreen = NO;
    } else {
        _isFullscreen = YES;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        if (_isFullscreen) {
            _menuView.left = self.view.height;
            _detailView.alpha = 0.0;
        } else {
            _menuView.left = self.view.height - _menuView.width + 7;
            _detailView.alpha = 1.0;
        }
        
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.archiveViewController.view.bounds = self.view.bounds;
    _alaskaVideo.frame = self.view.bounds;
    self.archiveViewController.view.origin = CGPointMake(self.view.height, 0);
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _videoWrapperView.alpha = 0.0;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _videoWrapperView.alpha = 1.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createButtonTapped:(id)sender {
    
    CameraViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)timeButtonTapped:(id)sender {
    [HCAnimator periodWithDuration:0.3 delay:0.0 timingFunction:elasticEaseOut updateBlock:^(float progress) {
        _msView.top = (!_msActive) ? map(progress, 0, 1, 0, -_msView.height) : map(progress, 1, 0, 0, -_msView.height);
    } completeBlock:^{
        //..
    }];
    /*if (!_msActive) {
        [UIView animateWithDuration:0.3 animations:^{
            _msView.top = 0;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            _msView.top = -_msView.height;
        }];
    }*/
        
    _msActive = !_msActive;
}

- (IBAction)archiveButtonTapped:(id)sender {
    [self showArchive:!_isArchiveMode animated:YES];
}

- (void)showArchive:(BOOL)show animated:(BOOL)animated {
    if (show) {
        [UIView animateWithDuration:0.3 animations:^{
            self.archiveViewController.view.left = _menuView.width-13;
            _menuView.left = -7;
            _videoWrapperView.left = -120;
            _fadeView.alpha = 1;
            _archiveLabel.text = @"STREAM";
            _menuArrow.transform = CGAffineTransformMakeRotation(0);
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.archiveViewController.view.origin = CGPointMake(self.view.height, 0);
            _menuView.left = self.view.height - _menuView.width +7;
            _videoWrapperView.left = 0;
            _fadeView.alpha = 0;
            _archiveLabel.text = @"ARCHIVE";
            _menuArrow.transform = CGAffineTransformMakeRotation(M_PI);
            _archiveViewController.imageViewsContainer.left = -2;
        }];
    }
    
    _isArchiveMode = show;
}

-(void)menuPanned:(UIPanGestureRecognizer *)pan{
    CGPoint translatedPoint = [pan translationInView:pan.view];
    
    if ([pan state] == UIGestureRecognizerStateChanged) {
        float left = 0;

        if (_isArchiveMode) {
            left = translatedPoint.x-2;
        } else {
            left = translatedPoint.x + self.view.bounds.size.width - pan.view.width;
        }
        
        _menuView.left = left;
        self.archiveViewController.view.left = left+_menuView.width-14;
        _videoWrapperView.left = map(clamp(0, 1, left/(self.view.bounds.size.width - pan.view.width)), 1, 0, 0, -120);
        
        _fadeView.alpha = map(left/(self.view.bounds.size.width - pan.view.width), 1, 0, 0, 0.9);
        
        } else if ([pan state] == UIGestureRecognizerStateEnded || [pan state] == UIGestureRecognizerStateCancelled){
            CGPoint velocity = [pan velocityInView:self.view];
            if (_isArchiveMode) {
                if (velocity.x < -400.0 || translatedPoint.x < -150) {
                    [self showArchive:YES animated:YES];
                } else {
                    [self showArchive:NO animated:YES];
                }
            } else {
                if (velocity.x > 400.0 || translatedPoint.x > 150 ) {
                    [self showArchive:NO animated:YES];
                } else {
                    [self showArchive:YES animated:YES];
                }
            }
        }
}

-(void)setAlaska:(BOOL)alaska{
    _alaska = alaska;
    [self updateVideoMode];
}


-(void)updateVideoMode{

    if (_alaska) {
        [self.view insertSubview:_alaskaVideo belowSubview:_archiveViewController.view];
        _alaskaVideo.hidden = NO;
    }else{

        _alaskaVideo.hidden = YES;
    }
    
}

@end

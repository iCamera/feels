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

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UILabel *timeUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *createLabel;
@property (weak, nonatomic) IBOutlet UILabel *archiveLabel;
@property (weak, nonatomic) IBOutlet UIImageView *menuArrow;
@property (weak, nonatomic) IBOutlet UIButton *archiveButton;

@property (weak, nonatomic) IBOutlet UIImageView *vidPlaceholderImage;
@property (weak, nonatomic) IBOutlet UILabel *vidTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *vidDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *vidLocationLabel;
@property (weak, nonatomic) IBOutlet UIView *fadeView;

@property (nonatomic, strong) ArchiveViewController *archiveViewController;
@property (nonatomic, assign) BOOL isArchiveMode;
@property (weak, nonatomic) IBOutlet UIView *videoWrapperView;

@property(strong,nonatomic) VideoViewController *videoViewController;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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
    
    /* VIDEO */
    [_vidTimeLabel setFont:[UIFont AvantGardeExtraLight:32]];
    [_vidDateLabel setFont:[UIFont AvantGardeExtraLight:25]];
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
    
    /* Gesture recongnizer */
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
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.archiveViewController.view.bounds = self.view.bounds;
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
    NSLog(@"CREATE THAT MTRFCKER");
    
    CameraViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)timeButtonTapped:(id)sender {
    NSLog(@"SHOW ME THAT BTCH");
}

- (IBAction)archiveButtonTapped:(id)sender {
    [self showArchive:!_isArchiveMode animated:YES];
}

- (void)showArchive:(BOOL)show animated:(BOOL)animated {
    if (show) {
        [UIView animateWithDuration:0.6 animations:^{
            self.archiveViewController.view.left = _menuView.width-13;
            _menuView.left = -7;
            _videoWrapperView.left = -120;
            _fadeView.alpha = 1;
            _archiveLabel.text = @"STREAM";
            _menuArrow.transform = CGAffineTransformMakeRotation(0);
        }];
    } else {
        [UIView animateWithDuration:0.6 animations:^{
            self.archiveViewController.view.origin = CGPointMake(self.view.height, 0);
            _menuView.left = self.view.height - _menuView.width +7;
            _videoWrapperView.left = 0;
            _fadeView.alpha = 0;
            _archiveLabel.text = @"ARCHIVE";
            _menuArrow.transform = CGAffineTransformMakeRotation(M_PI);
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

@end

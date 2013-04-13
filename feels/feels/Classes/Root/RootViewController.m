//
//  RootViewController.m
//  feels
//
//  Created by Hannes Wikström on 2013-04-12.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "RootViewController.h"
#import "ArchiveViewController.h"

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UILabel *timeUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *createLabel;
@property (weak, nonatomic) IBOutlet UILabel *archiveLabel;
@property (weak, nonatomic) IBOutlet UIImageView *menuArrow;

@property (weak, nonatomic) IBOutlet UIImageView *vidPlaceholderImage;
@property (weak, nonatomic) IBOutlet UILabel *vidTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *vidDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *vidLocationLabel;
@property (weak, nonatomic) IBOutlet UIView *fadeView;

@property (nonatomic, strong) ArchiveViewController *archiveViewController;
@property (nonatomic, assign) BOOL isArchiveMode;

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
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.archiveViewController.view.bounds = self.view.bounds;
    self.archiveViewController.view.origin = CGPointMake(self.view.height, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createButtonTapped:(id)sender {
    NSLog(@"CREATE THAT MTRFCKER");
}

- (IBAction)timeButtonTapped:(id)sender {
    NSLog(@"SHOW ME THAT BTCH");
}

- (IBAction)archiveButtonTapped:(id)sender {
    if (_isArchiveMode) {
        [UIView animateWithDuration:0.6 animations:^{
            self.archiveViewController.view.origin = CGPointMake(self.view.height, 0);
            _menuView.left = self.view.height - _menuView.width +7;
            _vidPlaceholderImage.left = 0;
            _fadeView.alpha = 0;
        }];
    } else {
        [UIView animateWithDuration:0.6 animations:^{
            self.archiveViewController.view.origin = CGPointMake(0, 0);
            _menuView.left = -10;
            _vidPlaceholderImage.left = -40;
            _fadeView.alpha = 1;
        }];
    }
    
    _isArchiveMode = !_isArchiveMode;
}

@end

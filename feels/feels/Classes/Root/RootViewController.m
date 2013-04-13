//
//  RootViewController.m
//  feels
//
//  Created by Hannes Wikström on 2013-04-12.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *createLabel;
@property (weak, nonatomic) IBOutlet UILabel *archiveLabel;

@property (weak, nonatomic) IBOutlet UILabel *vidTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *vidDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *vidLocationLabel;

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
    
    [_vidTimeLabel setFont:[UIFont AvantGardeExtraLight:32]];
    [_vidDateLabel setFont:[UIFont AvantGardeExtraLight:25]];
    [_vidLocationLabel setFont:[UIFont AvantGardeExtraLight:14]];
    float kern = 1.1;
    [_vidTimeLabel setKerning:kern];
    [_vidDateLabel setKerning:kern];
    [_vidLocationLabel setAdjustsLetterSpacingToFitWidth:YES];
    [_vidLocationLabel setAdjustsFontSizeToFitWidth:YES];
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
    NSLog(@"BRING OUT THAT FCKR");
}
@end

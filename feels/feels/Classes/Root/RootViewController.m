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

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [_timeUnitLabel setFont:[UIFont GeoSansLight:11]];
    [_timeUnitLabel setTextColor:[UIColor colorWithRed:0.388 green:0.384 blue:0.365 alpha:1]];
    [_timeUnitLabel setKerning:1.0];
    
    [_timeLabel setFont:[UIFont AvantGardeExtraLight:27]];
    [_timeLabel setTextColor:[UIColor colorWithRed:0.388 green:0.384 blue:0.365 alpha:1]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

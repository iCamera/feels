//
//  ArchiveViewController.m
//  feels
//
//  Created by Hannes Wikström on 4/13/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "ArchiveViewController.h"

@interface ArchiveViewController ()

@end

@implementation ArchiveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self.view addGestureRecognizer:tgr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapped {
    //[self.view removeFromSuperview];
}

@end

//
//  ArchiveViewController.m
//  feels
//
//  Created by Hannes Wikström on 4/13/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "ArchiveViewController.h"

@interface ArchiveViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
    
    NSMutableArray *videoImages = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"sweet_lips", @"sweet_lips", @"sweet_lips", @"sweet_lips", @"sweet_lips", @"sweet_lips", nil]];
    
    for (int i=0; i<[videoImages count]; i++) {
        UIImageView *videoImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[videoImages objectAtIndex:i]]];
        videoImgView.size = CGSizeMake(284, 160);
        [videoImgView setContentMode:UIViewContentModeScaleAspectFill];
        videoImgView.top = (i%2==0) ? 0 : 160;
        videoImgView.left = ceil(i/2)*284;
        [self.scrollView addSubview:videoImgView];
    }

    self.scrollView.width -= 48; //Menu width
    CGFloat contentWidth = ceil([videoImages count]/2) * 284;
    self.scrollView.contentSize = CGSizeMake(contentWidth, 320);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    BOOL b = YES;
    int i = 1;
    while (b) {
        NSString *localVid = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Movie_out%i.mp4",i]];
        NSURL *fileURL = [NSURL fileURLWithPath:localVid];
        NSLog(@"%@",fileURL);
        BOOL trams = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"Documents/Movie_out%i.mp4",i]];
        
        if (!trams) {
            b = NO;
        }
        
        i++;
    }
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

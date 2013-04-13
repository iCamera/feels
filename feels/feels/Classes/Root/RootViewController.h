//
//  RootViewController.h
//  feels
//
//  Created by Hannes Wikström on 2013-04-12.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController

- (IBAction)createButtonTapped:(id)sender;
- (IBAction)timeButtonTapped:(id)sender;
- (IBAction)archiveButtonTapped:(id)sender;

- (void)showArchive:(BOOL)show animated:(BOOL)animated;

@end

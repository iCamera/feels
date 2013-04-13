//
//  VideoViewController.h
//  feels
//
//  Created by Simon Andersson on 4/13/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoModel;

typedef void(^VideoDidChange)(VideoModel *videoModel);

@interface VideoViewController : UIViewController
@property (nonatomic, copy) VideoDidChange videoDidChange;
@property (nonatomic, assign) BOOL stopPlaying;
@end

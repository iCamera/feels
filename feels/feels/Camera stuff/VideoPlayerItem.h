//
//  PlayerItem.h
//  redbull-ss-ios
//
//  Created by Anton Holmquist on 12/6/12.
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import <Foundation/Foundation.h>

/* PlayerItem
 
 A playerItem consists of one main video and multiple ad urls (prerolls)
 
 */

@interface VideoPlayerItem : NSObject

@property (nonatomic, strong) UIImage *thumbnail;

// URLs to ad videos (prerolls)
@property (nonatomic, strong) NSArray *adURLs;

// URLs to main video
@property (nonatomic, strong) NSURL *mainURL;

+ (VideoPlayerItem*)item;

@end

//
//  PlayerView.h
//  redbull-ss-ios
//
//  Created by Anton Holmquist on 12/6/12.
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoPlayerItem,AwesomeVideo;
typedef void(^DidFinnishPlaying)(VideoPlayerItem *videoItem);



/* VideoPlayerView
 
 Only one can be active at a time. This is handeled internally.
 
 */


@protocol VideoPlayerViewDelegate;

@interface VideoPlayerView : UIView

@property (nonatomic, strong) VideoPlayerItem *item;
@property (nonatomic, copy) DidFinnishPlaying didFinnisPlaying;

@property (nonatomic, readonly) BOOL paused; // Readonly. Defaults to YES.
@property (nonatomic, strong) UIImageView *playiconImageView;



// Automatically toggle between embedded/fullscreen landscape when device is oriented
// Note: If this is YES, this view shouldn't exist in view controller
// that autorotates!
@property (nonatomic, assign) BOOL autoToggleFullscreenOnDeviceLandscape;

@property (nonatomic, assign) id<VideoPlayerViewDelegate> delegate;


- (void)seekToTime:(double)time completion:(void(^)())completion;
- (int)getCurrentTime;

- (void)play;
- (void)pause;

// If this player view is currently active, deactivate it. It will kill the player and stuff.
- (void)deactivateIfActive;

// Sets the currently active session. This will load player and stuff.
//+ (void)setActive:(VideoPlayerView*)instance;
//+ (void)setupGlobalAudioSession; // Needs to be set once. Will make airplay play correctly in background, etc.
//+ (BOOL)isActive:(VideoPlayerView*)instance;

@end

@protocol VideoPlayerViewDelegate <NSObject>

@required
- (void)videoPlayerChangedStateStarted:(BOOL)started;

@end

//
//  PlayerView.m
//  redbull-ss-ios
//
//  Created by Anton Holmquist on 12/6/12.
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import "VideoPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "VideoPlayerItem.h"
#import "NSTimer+Block.h"



@interface VideoPlayerFullscreenView : UIView

- (void)attachPlayerContainerView:(UIView*)view; // Adds to superview
- (void)detachPlayerContainerView; // Removes from superview

// This is the view that gets
@property (nonatomic, strong) UIView *backgroundView; // Black plate
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *attachedPlayerContainerView;

// This is stored when attached, so we can use it.
@property (nonatomic, assign) CATransform3D embeddedContainerViewTransform;
@property (nonatomic, assign) CGSize embeddedContainerViewSize;

@end

@implementation VideoPlayerFullscreenView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.autoresizesSubviews = YES;
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.backgroundView];
        
        self.containerView = [[UIView alloc] init];
        self.containerView.autoresizesSubviews = YES;
        [self addSubview:self.containerView];
        
        [self updateContainerViewFrameForCurrentState];
    }
    
    return self;
}


- (void)updateContainerViewFrameForCurrentState {
    

    
   // NSLog(@"updateContainerViewFrameForCurrentState: %d", self.displayState);
    
    CGSize size = CGSizeZero;
    CATransform3D transform = CATransform3DIdentity;
    
    
//    self.backgroundView.alpha = VideoPlayerDisplayStateIsFullscreen(self.displayState) ? 1 : 0;
//    
//    if (self.displayState == kVideoPlayerDisplayStateEmbedded) {
//        size = self.embeddedContainerViewSize;
//        transform = self.embeddedContainerViewTransform;
//    } else if (VideoPlayerDisplayStateIsFullscreen(self.displayState)) {
//        
//        CGFloat rotation = 0;
//        
//        transform = CATransform3DMakeTranslation(self.center.x, self.center.y, 0);
//        
//        if (self.displayState == kVideoPlayerDisplayStateFullscreenPortrait || self.displayState == kVideoPlayerDisplayStateFullscreenPortraitUpsideDown) {
//            size = self.size;
//        } else {
//            size = CGSizeMake(self.size.height, self.size.width);
//        }
//        
//        
//        
//        
//        if (self.displayState == kVideoPlayerDisplayStateFullscreenPortraitUpsideDown) {
//            rotation = M_PI;
//        } else if (self.displayState == kVideoPlayerDisplayStateFullscreenLandscapeLeft) {
//            rotation = -M_PI / 2;
//        } else if (self.displayState == kVideoPlayerDisplayStateFullscreenLandscapeRight) {
//            rotation = M_PI / 2;
//        }
//        
//        transform = CATransform3DRotate(transform, rotation, 0, 0, 1);
//    }
    
    
    self.containerView.bounds = CGRectMake(0, 0, size.width, size.height);
    self.containerView.layer.transform = transform;
}

- (void)attachPlayerContainerView:(UIView*)view {
    
    if(self.attachedPlayerContainerView) {
        [self detachPlayerContainerView];
        [self attachPlayerContainerView:view];
        return;
    }
    
    if (!self.superview) {
        return;
    }
    //NSAssert(!self.attachedPlayerContainerView, @"Need to detatch before attaching new");
    //NSAssert(view.superview, @"View needs to have superview when being attached! So we can store embedded transform.");
    
    // Store embedded view transform and size
    
    self.exclusiveTouch = YES;
    self.userInteractionEnabled = YES;
    self.hidden = NO;
    
    self.embeddedContainerViewSize = view.size;
    
    CGPoint position = [self.layer convertPoint:view.layer.position fromLayer:view.layer.superlayer];
    
    CATransform3D t = CATransform3DIdentity;
    t = CATransform3DTranslate(t, position.x, position.y, 0);
    self.embeddedContainerViewTransform = t;
    
    
    // Attach
    
    self.attachedPlayerContainerView = view;
    self.attachedPlayerContainerView.frame = self.containerView.bounds;
    self.attachedPlayerContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.containerView addSubview:self.attachedPlayerContainerView];
    
    [self updateContainerViewFrameForCurrentState];
}

- (void)detachPlayerContainerView {
    [self.attachedPlayerContainerView removeFromSuperview];
    self.attachedPlayerContainerView = nil;
    
    self.exclusiveTouch = NO;
    self.userInteractionEnabled = NO;
    self.hidden = YES;
}

@end

// There can only be one active video player view globally
static __weak VideoPlayerView *ACTIVE_VIDEO_PLAYER_VIEW_INSTANCE = nil;


// Used for fullscreen video
static VideoPlayerFullscreenView *VIDEO_PLAYER_FULLSCREEN_CONTAINER_VIEW = nil;

@interface PlayerLayerView : UIView

@property (nonatomic, strong) AVPlayer* player;

@end

@interface VideoPlayerViewState : NSObject

@property (nonatomic, assign) int playerItemIndex;
@property (nonatomic, assign) CMTime time;

@end

@implementation VideoPlayerViewState

@end

@interface VideoPlayerView ()
{
    BOOL _loading;
}

@property (nonatomic, strong) AVPlayer *adPlayer;
@property (nonatomic, strong) NSMutableArray *adPlayerItems;

@property (nonatomic, strong) AVPlayer *mainPlayer;
@property (nonatomic, strong) AVPlayerItem *mainPlayerItem;

@property (nonatomic, strong) UIView *playerContainerView; // Contains the actual player
@property (nonatomic, strong) PlayerLayerView *playerLayerView;

@property (nonatomic, strong) AVPlayerItem *currentPlayerItem; // Needs to be atomic

@property (nonatomic, assign) BOOL active;
@property (nonatomic, readwrite) BOOL paused;

// This is used when deactivated to be restored when activated
@property (nonatomic, strong) VideoPlayerViewState *storedState;
@property (nonatomic, strong) NSValue *pendingSeekTime; // CMTime

@property (nonatomic, strong) UIImageView *thumbnailView;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong) id periodicTimeObserver;

@property (nonatomic, readonly) VideoPlayerFullscreenView *sharedFullscreenView;

@property (nonatomic, assign) BOOL isScrubbing;
@property (nonatomic, assign) BOOL pausedForScrubbing;

@end

@implementation VideoPlayerView

- (id)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        //self.displayState = kVideoPlayerDisplayStateEmbedded;

        _paused = YES;
         
        //self.item = item;
        
        self.backgroundColor = [UIColor blackColor];
        
        self.autoresizesSubviews = YES;
        
        self.playerContainerView = [[UIView alloc] initWithFrame:self.bounds];
        self.playerContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.playerContainerView.autoresizesSubviews = YES;
        self.playerContainerView.backgroundColor = [UIColor blackColor];
        [self attachPlayerContainerView];
        
        self.playerLayerView = [[PlayerLayerView alloc] initWithFrame:self.playerContainerView.bounds];
        self.playerLayerView.backgroundColor = [UIColor blackColor];
        self.playerLayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.playerContainerView addSubview:self.playerLayerView];
        
        
        // Temp
        UISegmentedControl *s = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"e", @"p", @"pu", @"ll", @"lr", nil]];
        s.segmentedControlStyle = UISegmentedControlStyleBar;
        s.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        s.frame = CGRectMake(0, 0, self.playerContainerView.width, 40);
        s.selectedSegmentIndex = 0;
        [s addTarget:self action:@selector(temp:) forControlEvents:UIControlEventValueChanged];
        //[self.playerContainerView addSubview:s];
        
        self.thumbnailView = [[UIImageView alloc] init];
        self.thumbnailView.frame = self.bounds;
        self.thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.thumbnailView];
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        //[self.playerContainerView addSubview:self.activityView];
        [self.activityView centerInSuperview];
        
        self.playiconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"player_big_play_button"]];
        [self addSubview:self.playiconImageView];
        
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [nc addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [nc addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        [self addObserver:self forKeyPath:@"item" options:NSKeyValueObservingOptionPrior context:nil];
        [self addObserver:self forKeyPath:@"paused" options:0 context:nil];
        
        [self updateForCurrentDisplayState];
        
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)dealloc {
    [self setCurrentPlayerItem:nil];
    
    if (ACTIVE_VIDEO_PLAYER_VIEW_INSTANCE == self) {
        [[self class] setActive:nil];
    }
    
    [self removeObserver:self forKeyPath:@"item"];
    [self removeObserver:self forKeyPath:@"paused"];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}


- (UIView*)sharedFullscreenView {
    if (!VIDEO_PLAYER_FULLSCREEN_CONTAINER_VIEW) {
        
        UIScreen *screen = [UIScreen mainScreen];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        VideoPlayerFullscreenView *v = [[VideoPlayerFullscreenView alloc] initWithFrame:screen.bounds];
        v.userInteractionEnabled = NO;
        v.hidden = YES;
        v.backgroundColor = [UIColor clearColor];
        [window addSubview:v];
        
        VIDEO_PLAYER_FULLSCREEN_CONTAINER_VIEW = v;
    } return VIDEO_PLAYER_FULLSCREEN_CONTAINER_VIEW;
}

#pragma mark - Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    
    if (object == self && [keyPath isEqual:@"item"]) {
        
        BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
        
        // Only reload like this if we're currently active
        if ([[self class] isActive:self]) {
            
            // First change notificaiton
            if (isPrior) {
                [self shutdownForActive:NO]; // This method is only allowed to call if active, and we just checked that.
                self.storedState = nil; // Clear stored state
            }
            
            // Second change notification
            else {
                if (self.item) {
                    [self setupForActive];
                }
            }
        }
    
        if (!isPrior) {
            self.thumbnailView.image = self.item.thumbnail;
        }
    }
    
    
    AVPlayerItem *playerItem = (AVPlayerItem*)object;
    AVPlayer *player = [self playerForCurrentPlayerItem];
    
    if ([keyPath isEqual:@"status"] || [keyPath isEqual:@"playbackLikelyToKeepUp"] || [keyPath isEqual:@"playbackBufferFull"]) {
        
        if (playerItem.status == AVPlayerItemStatusReadyToPlay && self.pendingSeekTime) {
            CMTime time = [self.pendingSeekTime CMTimeValue];
            
            if (CMTIME_IS_VALID(time)) {
                // Black out temporaily to avoid seek glitch
                self.playerLayerView.hidden = YES;
                [player seekToTime:time
                   toleranceBefore:kCMTimeZero
                    toleranceAfter:kCMTimeZero
                 completionHandler:^(BOOL finished) {
                     self.playerLayerView.hidden = NO;
                 }];
            }
  
            self.pendingSeekTime = nil;
        } else if (playerItem.status == AVPlayerItemStatusReadyToPlay && playerItem.playbackLikelyToKeepUp) {
            
            // This happens the first time when waiting to play. We then trigger the play here.
            if (!self.paused) {
                [player play];
            }
        }
        
        
        [self updateLoadingState];
    }
    
    
    if (object == self && [keyPath isEqual:@"paused"]) {
        [self updateControlBar];
    }
    
}

#pragma mark - Notifications

- (void)applicationDidEnterBackground:(NSNotification*)n {
    
    /*
    if (!paused) {
        
        if (!self.airPlayActive) {
            pausedBeforeResignActive = YES;
            [self togglePlay:nil];
        }
    }
     */
}

- (void)applicationWillEnterForeground:(NSNotification*)n {
    
    
    /*
    
    if (!self.airPlayActive) {
        // ALWAYS RELOAD MAIN IF NOT AIRPLAYING!! (Since it's streaming!) This YES will be overrided if it's live stream.
        [self reloadMainVideoItemAndKeepTime:YES];
        
        if (paused && pausedBeforeResignActive) {
            [self togglePlay:nil];
        } pausedBeforeResignActive = NO;
    }
    
    */
    
    [self reloadAndKeepTime:YES];
}

- (void)deviceOrientationDidChange:(NSNotification*)n {
    return;
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    
//    if (self.active && self.autoToggleFullscreenOnDeviceLandscape &&UIDeviceOrientationIsValidInterfaceOrientation(deviceOrientation)) {
//        
//        UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)deviceOrientation;
//        
//        if (self.autoToggleFullscreenOnDeviceLandscape) {
//            
//            VideoPlayerDisplayState displayState;
//            
//            if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
//                displayState = kVideoPlayerDisplayStateEmbedded;
//            } else {
//                displayState = interfaceOrientation == UIInterfaceOrientationLandscapeLeft ? kVideoPlayerDisplayStateFullscreenLandscapeLeft : kVideoPlayerDisplayStateFullscreenLandscapeRight;
//            }
//            
//            [self setDisplayState:displayState animated:YES];
//        }
//        
//    }
    
}

#pragma mark - Loading

- (void)setLoading:(BOOL)loading {
    if (_loading != loading) {
        _loading = loading;
        //_loading ? [self.activityView startAnimating] : [self.activityView stopAnimating];
    }
}

- (void)setCurrentPlayerItem:(AVPlayerItem *)currentPlayerItem {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    AVPlayerItem *playerItem = _currentPlayerItem;
    AVPlayer *player = [self playerForCurrentPlayerItem];
    
    
    // 1. Shutdown
    if (playerItem) {
        
        [nc removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [nc removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem]; 

        [playerItem removeObserver:self forKeyPath:@"status"];
        [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
        
        if (self.periodicTimeObserver) {
            [player removeTimeObserver:self.periodicTimeObserver];
            self.periodicTimeObserver = nil;
        }
    }
    
    
    // 2. Switch
    _currentPlayerItem = currentPlayerItem;
    playerItem = _currentPlayerItem;
    
    
    // Player item has changed, so update player reference
    player = [self playerForCurrentPlayerItem];
    
    
    // 3. Setup
    if (playerItem) {
        [nc addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        
        [nc addObserver:self selector:@selector(playerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];

        [playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:nil];
        [playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:0 context:nil];
        
        __weak id s = self;
        
        self.periodicTimeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [s updateControlBar];
            [s updateLoadingState];
        }];
        
    }
    
    if (_currentPlayerItem) {
        NSAssert(player, @"Player must exist here if player item does");
        self.playerLayerView.player = player;
        [player replaceCurrentItemWithPlayerItem:playerItem];
    }
    
    [self updateLoadingState];
    
}

- (AVPlayer*)playerForCurrentPlayerItem {
    AVPlayer *player = _currentPlayerItem == self.mainPlayerItem ? self.mainPlayer : self.adPlayer;
    return player;
}



- (void)updateControlBar {
    
    //NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
    
//    
//    // Play
//    VideoPlayerInterfaceControlBar *controlBar = self.interfaceView.controlBar;
//    
//    controlBar.paused = self.paused && !self.pausedForScrubbing;
//    
//    // Scrubber
//    AVPlayerItem *playerItem = self.currentPlayerItem;
//
//    VideoPlayerInterfaceScrubber *scrubber = controlBar.scrubber;
//    
//    // Load duration on other thread since it's slow!
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        double duration = CMTimeGetSeconds(playerItem.duration);
//        double currentTime = CMTimeGetSeconds(playerItem.currentTime);
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            scrubber.duration = duration;
//            scrubber.currentTime = currentTime;
//            scrubber.loadedTimeRanges = playerItem.loadedTimeRanges;
//            scrubber.seekableTimeRanges = playerItem.seekableTimeRanges;
//        });
//    });
//    
//
//    //t = [NSDate timeIntervalSinceReferenceDate] - t;
   // NSLog(@"time: %f", t);
}


- (void)play {
    
    if (!self.paused) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.playiconImageView.alpha = 0;
    }];
    
    self.paused = NO;
    
    [self activateIfNeccessary];
    
    [[self playerForCurrentPlayerItem] play];
    
    if (self.delegate) {
        [self.delegate videoPlayerChangedStateStarted:YES];
    }
}

- (void)pause {
    
    if (self.paused) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.playiconImageView.alpha = 1.0;
    }];
    
    [self.playiconImageView.superview bringSubviewToFront:self.playiconImageView];
    
    self.paused = YES;
    [[self playerForCurrentPlayerItem] pause];
    
    if (self.delegate) {
        [self.delegate videoPlayerChangedStateStarted:NO];
    }
}

- (AVPlayer*)playerForItem:(AVPlayerItem*)item {
    
    AVPlayer *player = nil;
    
    if ([self.adPlayerItems containsObject:item]) {
        player = self.adPlayer;
    }
    
    return player;
}



- (void)updateLoadingState {
//    
//    AVPlayerItem *playerItem = self.currentPlayerItem;
//    AVPlayer *player = [self playerForCurrentPlayerItem];
//    
//    BOOL loading = (playerItem.status != AVPlayerItemStatusReadyToPlay) || !playerItem.playbackLikelyToKeepUp;
//    
//    CMTime currentTime = playerItem.currentTime;
//    double time = CMTIME_IS_NUMERIC(currentTime) && CMTIME_IS_VALID(currentTime) ? CMTimeGetSeconds(currentTime) : 0;
//    
//    if (!self.paused && (player.rate < 1.0 || time == 0)) {
//        
//        loading = YES;
//        
//    }
////    else if (self.interfaceView.controlBar.scrubber.playerSeeking) {
////        loading = YES;
////    }
//    
//    if (self.paused && !self.pausedForScrubbing && ![playerItem isPlaybackLikelyToKeepUp]) {
//        loading = NO;
//    }
//    
//    if (!self.active) {
//        loading = NO;
//    }
//    
//    self.loading = loading;
//    
//    self.videoLoadingView.frame = self.playerContainerView.bounds;
}

- (void)skipToNextPlayerItem {
    // Ad finished
    if ([self.adPlayerItems containsObject:_currentPlayerItem]) {
        
        //AVPlayerItem *playerItem = (AVPlayerItem*)n.object;
        int index = [self.adPlayerItems indexOfObject:_currentPlayerItem];
        
        // Do we have more ads?
        if (index < self.adPlayerItems.count - 1) {
            AVPlayerItem *nextItem = [self.adPlayerItems objectAtIndex:index + 1];
            [self setCurrentPlayerItem:nextItem];
        }
        
        // Else start main video
        else {
            [self setCurrentPlayerItem:self.mainPlayerItem];
        }
        
    }
    
    // Main finished
    else if (_currentPlayerItem == self.mainPlayerItem) {
        
    }
}

- (void)playerItemDidPlayToEndTime:(NSNotification*)n {
    [self skipToNextPlayerItem];
    if (_didFinnisPlaying) {
        _didFinnisPlaying(_item);
    }
}


- (void)playerItemFailedToPlayToEndTime:(NSNotification*)n {
    NSError *error = [n.userInfo objectForKey:AVPlayerItemFailedToPlayToEndTimeErrorKey];
    
    NSLog(@"playerItemFailedToPlayToEndTime: %@", error);
    
    [self skipToNextPlayerItem];
}

- (void)playerItemPlaybackStalled:(NSNotification*)n {
    
    if ([self.adPlayerItems containsObject:n.object]) {
        //AVPlayerItem *playerItem = (AVPlayerItem*)n.object;
        //int index = [self.adPlayerItems indexOfObject:n.object];
    }
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // self.paused ? [self play] : [self pause];

    
    
}

- (void)tap {
//    NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
    [self activateIfNeccessary];
//    t = [NSDate timeIntervalSinceReferenceDate] - t;
    //NSLog(@"time: %f", t);
    
    
    if (self.paused) {
        
        [self updateLoadingState];
        
        // Short delay to get the impression of fast load
        [NSTimer scheduledTimerWithTimeInterval:0.01 completion:^{
            [self play];
            [self updateLoadingState];
            
            // [self setDisplayState:kVideoPlayerDisplayStateFullscreenPortrait animated:YES];
            
        }];
    } else {
        [self pause];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.playiconImageView centerInSuperview];
    //[self.activityView centerInSuperview];
    
    //NSLog(@"%p, %p,  frame: %@", self, self.superview, NSStringFromCGRect(self.frame));
}

#pragma mark - Display State
//
//
//- (void)setDisplayState:(VideoPlayerDisplayState)displayState animated:(BOOL)animated {
//
//    if (_displayState == displayState) {
//        return;
//    }
//    
//    VideoPlayerDisplayState oldDisplayState = _displayState;
//    _displayState = displayState;
//    
//    // Attach to view
//    __weak VideoPlayerFullscreenView *fullscreenView = [self sharedFullscreenView];
//    
//    
//    // If not currently fullscreen but will become
//    if (!VideoPlayerDisplayStateIsFullscreen(oldDisplayState) && VideoPlayerDisplayStateIsFullscreen(_displayState) ) {
//           
//        [fullscreenView attachPlayerContainerView:self.playerContainerView];
//        
//    }
//    
//    [self updateForCurrentDisplayState];
//    
//    // Animate to fullscreen
//    [fullscreenView setDisplayState:displayState animated:YES completion:^{
//        
//        
//        // If was fullscreen but is no more, detach it
//        if (VideoPlayerDisplayStateIsFullscreen(oldDisplayState) && !VideoPlayerDisplayStateIsFullscreen(_displayState)) {
//            [fullscreenView detachPlayerContainerView];
//            [self attachPlayerContainerView];
//        }
//    }];
//    
//}

- (void)updateForCurrentDisplayState {
    
//    VideoPlayerInterfaceType interfaceType = kVideoPlayerInterfaceTypePhoneEmbedded;
//    
//    if (self.displayState == kVideoPlayerDisplayStateEmbedded) {
//        interfaceType = kVideoPlayerInterfaceTypePhoneEmbedded;
//    } else {
//        interfaceType = kVideoPlayerInterfaceTypePhoneFullscreen;
//    }
//    
//    self.interfaceView.type = interfaceType;
//    [self.playerContainerView bringSubviewToFront:self.interfaceView];
    [self.playerContainerView bringSubviewToFront:self.playiconImageView];
}

- (void)attachPlayerContainerView {
    self.playerContainerView.frame = self.bounds;
    [self addSubview:self.playerContainerView];
    [self.thumbnailView.superview bringSubviewToFront:self.thumbnailView];
    [self.playiconImageView.superview bringSubviewToFront:self.playiconImageView];
    
    
}

#pragma mark - Active

- (void)activateIfNeccessary {
    [[self class] setActive:self];
}

- (void)deactivateIfActive {
    if (self.active) {
        [[self class] setActive:nil];
    }
}

// Prepare internally for being active.
// IT IS NOT ALLOWED TO CALL THIS METHOD IF VIEW IS NOT GLOBALLY ACTIVE
- (void)setupForActive {
    
    NSAssert([[self class] isActive:self], @"Can't activate internally without being globally active. Use class method instead.");
    
    if (self.active) {
        return;
    }
    
    [self activateIfNeccessary];
    
    
    // Make sure we have the right audio session
    [[self class] setupGlobalAudioSession];
    
    
    self.active = YES;
    self.thumbnailView.hidden = YES;
    
    self.adPlayer = [[AVPlayer alloc] init];
    self.mainPlayer = [[AVPlayer alloc] init];
    
    self.adPlayerItems = [NSMutableArray array];
    for (NSURL *url in self.item.adURLs) {
        // Create player item
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
        [self.adPlayerItems addObject:playerItem];
    }
    
    self.mainPlayerItem = [[AVPlayerItem alloc] initWithURL:self.item.mainURL];
    
    
    // Restore state or create the first player item
    
    AVPlayerItem *playerItem = nil;
    
    if (self.adPlayerItems.count == 0) {
        playerItem = self.mainPlayerItem;
    } else if (self.storedState) {
        playerItem = self.storedState.playerItemIndex == self.adPlayerItems.count ? self.mainPlayerItem : [self.adPlayerItems objectAtIndex:self.storedState.playerItemIndex];
    
    } else {
        playerItem = [self.adPlayerItems objectAtIndex:0];
        
    }
    
    
    
    [self setCurrentPlayerItem:playerItem];
    
    
    
    if (self.storedState) {
        // Will seek to this asap.
        self.pendingSeekTime = [NSValue valueWithCMTime:self.storedState.time];
        
        self.storedState = nil;
    }
    
    
    [self updateLoadingState];
    [self updateControlBar];
    
    
    
}

// Prepare internally for not being active
// IT IS NOT ALLOWED TO CALL THIS METHOD IF VIEW IS NOT GLOBALLY ACTIVE
- (void)shutdownForActive:(BOOL)pause {
    
    NSAssert([[self class] isActive:self], @"Can't activate internally without being globally active. Use class method instead.");
    
    if (!self.active) {
        return;
    }
    
    // Pause
    if (pause) {
        [self pause];
    }
    
    
    self.active = NO;
    self.thumbnailView.hidden = NO;
    
    self.storedState = [[VideoPlayerViewState alloc] init];
    self.storedState.playerItemIndex = _currentPlayerItem == self.mainPlayerItem ? self.adPlayerItems.count : [self.adPlayerItems indexOfObject:_currentPlayerItem];
    self.storedState.time = _currentPlayerItem.currentTime;
    
    
    [self setCurrentPlayerItem:nil];
    
    [self.adPlayer pause];
    [self.mainPlayer pause];    
    
    [self.adPlayer replaceCurrentItemWithPlayerItem:nil];
    [self.mainPlayer replaceCurrentItemWithPlayerItem:nil];
    
    self.adPlayer = nil;
    self.mainPlayer = nil;
    
    self.adPlayerItems = nil;
    
    [self updateLoadingState];
}

// If current item is active. Reload player and all that stuff. Used when a serious error has occured
// and we need to reset and start again. 
- (void)reloadActive {
    if (self.active) {
        [self shutdownForActive:NO];
        [self setupForActive];
    }
}

- (void)reloadAndKeepTime:(BOOL)keepTime {
    AVPlayer *player = [self playerForCurrentPlayerItem];
    
    //double currentMainTime = CMTIME_IS_NUMERIC(player.currentTime) ? CMTimeGetSeconds(player.currentTime) : 0;
    
    CMTime currentTime = player.currentTime;
    NSValue *currentTimeValue = [NSValue valueWithCMTime:currentTime];
    
    
    [self reloadActive];
    
    self.pendingSeekTime = currentTimeValue;
    
}

#pragma mark - Actions

- (void)togglePlay {
    self.paused ? [self play] : [self pause];
}

- (void)jumpBack {
    AVPlayerItem *playerItem = self.currentPlayerItem;
    double currentTime = CMTimeGetSeconds(playerItem.currentTime);
    double seekTime = MAX(0, currentTime - 30);
    
    
    if (!isnan(seekTime)) {
        [self seekToTime:seekTime completion:^{}];
    }
}

#pragma mark - Scrubber Delegate


- (void)seekToTime:(double)time completion:(void(^)())completion  {
//    VideoPlayerInterfaceScrubber *scrubber = self.interfaceView.controlBar.scrubber;
//    scrubber.playerSeeking = YES;
    
    [self updateLoadingState];
    
    AVPlayerItem *playerItem = self.currentPlayerItem;
    AVPlayer *player = [self playerForCurrentPlayerItem];
    
    // Assume we're going to get there  
//    [scrubber setCurrentTime:time];
    
    NSLog(@"%@",player);
    
    [player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)
     completionHandler:^(BOOL finished) {
         
//         scrubber.playerSeeking = NO;
//         [scrubber setCurrentTime:CMTimeGetSeconds(playerItem.currentTime)];
         [self updateLoadingState];
         if (completion) {
             completion();             
         }

     }];
}

-(int)getCurrentTime{
    if (!self.currentPlayerItem) return 0;
    
    return CMTimeGetSeconds(self.currentPlayerItem.currentTime);
}


#pragma mark - Static

+ (void)setActive:(VideoPlayerView*)instance {
    if (ACTIVE_VIDEO_PLAYER_VIEW_INSTANCE != instance) {
        [ACTIVE_VIDEO_PLAYER_VIEW_INSTANCE shutdownForActive:YES];
        ACTIVE_VIDEO_PLAYER_VIEW_INSTANCE = instance;
        [ACTIVE_VIDEO_PLAYER_VIEW_INSTANCE setupForActive];
    }
}

+ (BOOL)isActive:(VideoPlayerView*)instance {
    return ACTIVE_VIDEO_PLAYER_VIEW_INSTANCE == instance;
}

+ (void)setupGlobalAudioSession {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}


@end


@implementation PlayerLayerView

+ (Class)layerClass {
	return [AVPlayerLayer class];
}

- (AVPlayer*)player {
	return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player {
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

@end
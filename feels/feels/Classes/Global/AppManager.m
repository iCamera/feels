//
//  AppManager.m
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "AppManager.h"
#import "APIClient.h"
#import "TimeHolder.h"
#import "UIDevice+IdentifierAddition.h"
#import "VideoModel.h"
#import "NSTimer+Block.h"
#import "KVOR.h"

@interface AppManager () <UIAlertViewDelegate>
@property (nonatomic, strong) TimeHolder *currentTimeHolder;
@property (nonatomic, readonly) NSTimeInterval time;
@property (nonatomic, strong) NSTimer *videoFetchingTimer;
@property (nonatomic, strong) NSTimer *getPointsTimer;
@end

@implementation AppManager

+ (AppManager *)sharedManager {
    static AppManager *INSTANCE = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        INSTANCE = [[AppManager alloc] init];
    });
    
    return INSTANCE;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.videos = [NSMutableArray array];
        self.startIndex = -1;
        self.loading = YES;
        
        /* Points / seconds */
        BOOL hasLaunchedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:kLaunchedBefore];
        self.points = [[NSUserDefaults standardUserDefaults] integerForKey:kUsersAmountOfPoints];
        if (!hasLaunchedBefore) {
            self.points = 6000; //first time
            [[NSUserDefaults standardUserDefaults] setInteger:self.points forKey:kUsersAmountOfPoints];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLaunchedBefore];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        self.seconds = self.points / 1000;
    }
    return self;
}

- (NSString *)author {
    return [[UIDevice currentDevice] uniqueDeviceIdentifier];
}

- (void)start {
    [self startGettingPoints:1.0/10];
    [[AppManager sharedManager] syncServerWithCompleteBlock:^{
        [self startFetchingVideos];
        self.startTimestamp = self.serverTimeIntervalSince1970;
    }];
}

- (void)startGettingPoints:(float)delay {
    [self.getPointsTimer invalidate];
    self.getPointsTimer = nil;
    self.getPointsTimer = [NSTimer scheduledTimerWithTimeInterval:delay completion:^{
        [self getPoints];
    } repeat:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.getPointsTimer forMode:NSRunLoopCommonModes];
}

- (void)getPoints {
    if (self.points >= 18000)
        return;
    
    int oldPoints = self.points;
    int increment = 1;
    if (self.points == 6000) {
        [self startGettingPoints:1.0/5];
    } else if (self.points == 12000) {
        [self startGettingPoints:1.0/2];
    }
    
    /*
    int increment;
    if (self.points < 6000) {
        increment = 10;
    } else if (self.points < 12000) {
        increment = 5;
    } else {
        increment = 2;
    }*/
    
    //int oldPoints = self.points;
    self.points += increment;
    
    if (oldPoints/1000 - self.points/1000) {
        //User got a new second!
        self.seconds = self.points / 1000;
    }
}

- (void)addPointsFromSeconds:(int)seconds {
    self.points += seconds*2;
    if (self.points > 18000) {
        self.points = 18000;
    }
}

- (void)startFetchingVideos {
    self.videoFetchingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 completion:^{
        [self fetchVideos];
    } repeat:YES];
    [self fetchVideos];
}

- (void)fetchVideos {
    VideoModel *videoModel = [self.videos lastObject];
    NSString *lastID = [NSString stringWithFormat:@"%i", videoModel.index+1] ?: @"0";
    
    [self fetchVideosWithBlock:^(NSMutableArray *videos) {
        if ([videos count] > 0) {
            [videos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (![self.videos containsObject:obj]) {
                    [self.videos addObject:obj];
                    self.startTimestamp -= 6;
                }
            }];
            
            if (self.startIndex < 0) {
                NSTimeInterval date = self.serverTimeIntervalSince1970;
                
                if (self.videos.count > 0) {
                    self.loading = NO;
                    self.startIndex = (int)(date / 6) % (int)self.videos.count;
                    
                    double numberOfClipsPlayed = floor(self.serverTimeIntervalSince1970 / 6);
                    double secondsIntoClip = self.serverTimeIntervalSince1970 - (numberOfClipsPlayed*6);
                    
                    NSLog(@"%f", secondsIntoClip);
                    
                    self.startSecondTimeInterval = secondsIntoClip;
                    self.play = YES;
                }
            }
        }
        
    } afterIndex:lastID];
}

- (void)fetchVideosWithBlock:(void(^)(NSMutableArray *videos))completeBlock afterIndex:(NSString *)index {
    
    [[APIClient shareClient] getPath:[NSString stringWithFormat:@"/ahd/stream/%@", index] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *videos = [NSMutableArray array];
        if ([responseObject nullCheckedObjectForKey:@"success"]) {
            for (NSDictionary *dict in responseObject[@"data"]) {
                VideoModel *video = [[VideoModel alloc] initWithDictionary:dict];
                if (![videos containsObject:video]) {
                    [videos addObject:video];
                }
            }
        }
        
        completeBlock(videos);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

static inline double calcServerTimeOffset(double  localSent, double  localReceived, double  serverReceived, double serverSent) {
    float offset = round((serverReceived - localSent + serverReceived - localReceived) / 2.0f);
    return offset;
}

static inline double calcRequestDelay(double localSent, double localReceived, double serverReceived, double serverSent) {
    return (localReceived - localSent) - (serverSent - serverReceived);
}

static int count = 0;
- (void)syncServerWithCompleteBlock:(void(^)())block {
    
    double localSent = [[NSDate date] timeIntervalSince1970];
    [[APIClient shareClient] getPath:@"/ahd/server/timestamp" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"success"]) {
            
            double localReceived = [[NSDate date] timeIntervalSince1970];
            responseObject = responseObject[@"data"];
            
            double serverReceived = [[responseObject objectForKey:@"timestamp"] doubleValue];
            double serverSent = [[responseObject objectForKey:@"timestamp"] doubleValue];
            
            double offset = calcServerTimeOffset(localSent, localReceived, serverReceived, serverSent);
            double delay = calcRequestDelay(localSent, localReceived, serverReceived, serverSent);
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            
            if (_currentTimeHolder == nil || fabs(_currentTimeHolder.time - now) > 30 || delay < _currentTimeHolder.delay) {
                _currentTimeHolder = [[TimeHolder alloc] init];
                _currentTimeHolder.offset = offset;
                _currentTimeHolder.time = now;
                _currentTimeHolder.delay = delay;
            }
            
            _time = now + offset;
            count++;
            if (count < 10) {
                [self syncServerWithCompleteBlock:block];
            }
            else {
                count = 0;
                block();
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [operation responseString]);
    }];
}

- (NSTimeInterval)serverTimeIntervalSince1970 {
    double now = [[NSDate date] timeIntervalSince1970];
    return now + _currentTimeHolder.offset;
}

@end

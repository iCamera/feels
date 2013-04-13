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

@interface AppManager ()
@property (nonatomic, strong) TimeHolder *currentTimeHolder;
@property (nonatomic, readonly) NSTimeInterval time;
@property (nonatomic, strong) NSTimer *videoFetchingTimer;
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
    }
    return self;
}

- (NSString *)author {
    return [[UIDevice currentDevice] uniqueDeviceIdentifier];
}

- (void)start {
    [[AppManager sharedManager] syncServerWithCompleteBlock:^{
        [self startFetchingVideos];
        self.startTimestamp = self.serverTimeIntervalSince1970;
        
    }];
}

- (void)startFetchingVideos {
    self.videoFetchingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 completion:^{
        VideoModel *videoModel = [self.videos lastObject];
        NSString *lastID = videoModel.ID ?: @"0";
        
        [self fetchVideosWithBlock:^(NSMutableArray *videos) {
            if ([videos count] > 0) {
                [videos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if (![self.videos containsObject:obj]) {
                        [self.videos addObject:obj];
                        self.startTimestamp -= 6;
                    }
                }];
                
                if (self.startIndex < 0) {
                    NSTimeInterval date = self.serverTimeIntervalSince1970 - self.startTimestamp;
                    NSLog(@"%f", date);
                    
                    if (self.videos.count > 0) {
                        NSLog(@"%i", (int)(date / 6) % (int)self.videos.count);
                    }
                    self.startIndex = (int)(date / 6) % (int)self.videos.count;
                }
            }
        } afterIndex:lastID];
    } repeat:YES];
}

- (void)fetchVideosWithBlock:(void(^)(NSMutableArray *videos))completeBlock afterIndex:(NSString *)index {
    
    [[APIClient shareClient] getPath:@"/ahd/stream/0" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        NSLog(@"Error: %@", operation.responseString);
    }];
}

static inline double calcServerTimeOffset(double  localSent, double  localReceived, double  serverReceived, double serverSent) {
    float offset = round((serverReceived - localSent + serverReceived - localReceived) / 2.0f);
    return offset;
}

static inline double calcRequestDelay(double localSent, double localReceived, double serverReceived, double serverSent) {
    return (localReceived - localSent) - (serverSent - serverReceived);
}

- (void)syncServerWithCompleteBlock:(void(^)())block {
    [[APIClient shareClient] getPath:@"/ahd/server/timestamp" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        double localSent = [[NSDate date] timeIntervalSince1970];
        
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
            block();
            
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
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

@interface AppManager ()
@property (nonatomic, strong) TimeHolder *currentTimeHolder;
@property (nonatomic, readonly) NSTimeInterval time;
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

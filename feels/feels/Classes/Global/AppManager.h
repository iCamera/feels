//
//  AppManager.h
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppManager : NSObject

@property (nonatomic, strong) NSMutableArray *videos;
@property (nonatomic, assign) double startTimestamp;
@property (nonatomic, assign) int startIndex;
+ (AppManager *)sharedManager;

- (NSString *)author;

- (void)start;
- (void)syncServerWithCompleteBlock:(void(^)())block;
- (NSTimeInterval)serverTimeIntervalSince1970;
- (void)fetchVideosWithBlock:(void(^)(NSMutableArray *videos))completeBlock afterIndex:(NSString *)index;



@end

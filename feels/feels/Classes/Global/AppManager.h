//
//  AppManager.h
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppManager : NSObject
+ (AppManager *)sharedManager;

- (void)syncServerWithCompleteBlock:(void(^)())block;
- (NSTimeInterval)serverTimeIntervalSince1970;

@end

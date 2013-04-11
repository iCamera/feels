//
//  NSTimer+Block.m
//  Axe Enterprise
//
//  Created by Simon Andersson on 4/20/12.
//  Copyright (c) 2012 Hiddencode.me. All rights reserved.
//

#import "NSTimer+Block.h"

@implementation NSTimer (Block)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)ti completion:(void(^)())block {
    return [self scheduledTimerWithTimeInterval:ti completion:block repeat:NO];
}

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)ti completion:(void(^)())block repeat:(BOOL)yesOrNo {
    void (^completeBlock)() = [block copy];
    id timer = [self scheduledTimerWithTimeInterval:ti target:self selector:@selector(completionBlockExecution:) userInfo:completeBlock repeats:yesOrNo];

    return timer;
}

+ (void)completionBlockExecution:(NSTimer *)timer {
    if (timer.userInfo) {
        void (^block)() = (void (^)())timer.userInfo;
        block();
    }
}

@end
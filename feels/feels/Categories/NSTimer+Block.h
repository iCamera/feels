//
//  NSTimer+Block.h
//  Axe Enterprise
//
//  Created by Simon Andersson on 4/20/12.
//  Copyright (c) 2012 Hiddencode.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Block)
+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)ti completion:(void(^)())block;
+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)ti completion:(void(^)())block repeat:(BOOL)yesOrNo;
@end
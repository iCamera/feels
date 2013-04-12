//
//  Mixer.h
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MixerTickBlock)(void);

@interface Mixer : NSObject

+ (Mixer *)table;
- (void)startWithBPM:(int)bpm;

@property (nonatomic, copy) MixerTickBlock tickBlock;
@property (nonatomic, copy) MixerTickBlock beatBlock;

@end

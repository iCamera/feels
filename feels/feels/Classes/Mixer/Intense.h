//
//  Intense.h
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Intense : NSObject

+ (Intense *)shared;

- (void)play;
- (void)pause;
- (void)stop;

@end

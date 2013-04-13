//
//  UILabel+Feels.h
//  feels
//
//  Created by Hannes Wikström on 4/13/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Feels)

- (void) setText:(NSString *)text withKerning:(CGFloat)kerning;
- (void) setKerning:(CGFloat)kerning;

@end

//
//  UILabel+Feels.m
//  feels
//
//  Created by Hannes Wikström on 4/13/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "UILabel+Feels.h"

@implementation UILabel (Feels)

-(void) setText:(NSString *)text withKerning:(CGFloat)kerning {
    if ([self respondsToSelector:@selector(setAttributedText:)]) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedString addAttribute:NSKernAttributeName
                                 value:[NSNumber numberWithFloat:kerning]
                                 range:NSMakeRange(0, [text length])];
        [self setAttributedText:attributedString];
    }
    else
        [self setText:text];
}

-(void) setKerning:(CGFloat)kerning {
    [self setText:self.text withKerning:kerning];
}

@end

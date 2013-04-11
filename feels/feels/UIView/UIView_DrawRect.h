//
//  UIView_DrawRect.h
//
//  Created by Simon Andersson on 2/15/12.
//  Copyright (c) 2012 Hiddencode.me. All rights reserved.
//


typedef void(^DrawRectBlock)(CGRect rect);

@interface HCView : UIView {
@private
    DrawRectBlock block;
}

- (void)setDrawRectBlock:(DrawRectBlock)b;

@end

@interface UIView (DrawRect)
+ (UIView *)viewWithFrame:(CGRect)frame drawRect:(DrawRectBlock)block;
@end
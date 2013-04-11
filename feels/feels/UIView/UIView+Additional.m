//
//  UIView+Additional.m
//
//  Created by Simon Andersson on 8/19/11.
//  Copyright 2011 Hiddencode.me. All rights reserved.
//

#import "UIView+Additional.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Additional)

#pragma mark - Setters

- (void)setHeight:(CGFloat)val {
    CGRect frame = self.frame;
    frame.size.height = val;
    self.frame = frame;
}

- (void)setWidth:(CGFloat)val {
    CGRect frame = self.frame;
    frame.size.width = val;
    self.frame = frame;
}

- (void)setLeft:(CGFloat)val {
    CGRect frame = self.frame;
    frame.origin.x = val;
    self.frame = frame;
}

- (void)setTop:(CGFloat)val {
    CGRect frame = self.frame;
    frame.origin.y = val;
    self.frame = frame;
}

- (void)setRight:(CGFloat)val {
    self.left = self.width + val;
}

- (void)setBottom:(CGFloat)val {
    self.top = self.height + val;
}

- (void)setSize:(CGSize)val {
    CGRect frame = self.frame;
    frame.size = val;
    self.frame = frame;
}

- (void)setOrigin:(CGPoint)val {
    CGRect frame = self.frame;
    frame.origin = val;
    self.frame = frame;
}

#pragma mark - Getters

- (CGFloat)width { return self.frame.size.width; }
- (CGFloat)height { return self.frame.size.height; }
- (CGFloat)left { return self.frame.origin.x; }
- (CGFloat)top { return self.frame.origin.y; }
- (CGFloat)right { return self.left + self.width; }
- (CGFloat)bottom { return self.top + self.height; }
- (CGSize)size { return self.frame.size; }
- (CGPoint)origin { return self.frame.origin; }

- (CGFloat)screenX {
    CGFloat x = 0;
    for (UIView *view = self; view; view = view.superview) {
        x += view.left;
    } return x;
}

- (CGFloat)screenY {
    CGFloat y = 0;
    for (UIView *view = self; view; view = view.superview) {
        y += view.top;
    } return y;
}

#pragma mark - Position

- (void)setBottomRelativeToSuperview:(CGFloat)val {
    self.top = self.superview.height - self.height - val;
}

- (void)setRightRelativeToSuperview:(CGFloat)val {
    self.left = self.superview.width - self.width - val;
}

- (void)centerHorizontalInSuperview {
    self.origin = CGPointMake((self.superview.width - self.width) / 2, self.top);
}

- (void)centerVerticalInSuperview {
    
    self.origin = CGPointMake(self.left, (self.superview.height - self.height) / 2);
}

- (void)centerInSuperview {
    self.origin = CGPointMake(rint((self.superview.width - self.width) / 2), rint((self.superview.height - self.height) / 2));
}


#pragma mark - Hierarchy


- (void)sendToBack { [self.superview sendSubviewToBack:self]; }

- (void)bringToFront { [self.superview bringSubviewToFront:self]; }

#pragma mark - View

- (void)fullsizeWithScale {
    self.frame = self.superview.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
}

- (void)snapTopContent {
    
    if([self.subviews count] <= 0) return;
    
    CGFloat maxWidth = 0, maxHeight = 0;
    
    for (UIView *v in self.subviews) {
        if(!v.hidden) {
            if (v.width + v.left > maxWidth) { 
                maxWidth = v.width + v.left;
            }
            
            if (v.height + v.top > maxHeight) {
                maxHeight = v.height + v.top;
            }
        }
    }
    
    [self setSize:CGSizeMake(maxWidth, maxHeight)];
}


- (void)addSubviews:(NSArray *)array {
    for (id v in array) {
        [self addSubview:(UIView *)v];
    }
}

- (void)addSubviewAtNextHighetsHeight:(UIView *)v withPadding:(CGFloat)padding {
    CGFloat h = 0;
    
    for (UIView *v in self.subviews) {
        if(!v.hidden) {
            if (v.height + v.top > h)
                h = v.height + v.top;
        }
    }
    
    v.top = h + padding;
    
    [self addSubview:v];
}

- (void)removeAllSubviews {
    for (id subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    CGPoint newPoint = CGPointMake(self.bounds.size.width * anchorPoint.x, self.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(self.bounds.size.width * self.layer.anchorPoint.x, self.bounds.size.height * self.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, self.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, self.transform);
    
    CGPoint position = self.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    self.layer.position = position;
    self.layer.anchorPoint = anchorPoint;
}

- (UIImage *)snapshot {
    return [self snapshotWithTransparancy:NO];
}

- (UIImage *)snapshotWithTransparancy:(BOOL)transparent {
    UIGraphicsBeginImageContextWithOptions(self.size, !transparent, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.layer renderInContext:context];
    UIImage *render = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return render;
}

@end
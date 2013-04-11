//
//  UIView+Additional.h
//
//  Created by Simon Andersson on 8/19/11.
//  Copyright 2011 Hiddencode.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (Additional)

#pragma mark - Getters/Setters
@property(nonatomic, readwrite) CGFloat width;
@property(nonatomic, readwrite) CGFloat height;
@property(nonatomic, readwrite) CGFloat top;
@property(nonatomic, readwrite) CGFloat left;
@property(nonatomic, readwrite) CGFloat right;
@property(nonatomic, readwrite) CGFloat bottom;
@property(nonatomic, readonly)  CGFloat screenX;
@property(nonatomic, readonly)  CGFloat screenY;
@property(nonatomic, readwrite) CGSize size;
@property(nonatomic, readwrite) CGPoint origin;

#pragma mark - Position
- (void)setBottomRelativeToSuperview:(CGFloat)val;
- (void)setRightRelativeToSuperview:(CGFloat)val;
- (void)centerHorizontalInSuperview;
- (void)centerVerticalInSuperview;
- (void)centerInSuperview;

#pragma mark - Hierarchy
- (void)sendToBack;
- (void)bringToFront;

#pragma mark - View
- (void)fullsizeWithScale;
- (void)snapTopContent;
- (void)addSubviews:(NSArray *)array;
- (void)addSubviewAtNextHighetsHeight:(UIView *)v withPadding:(CGFloat)padding;
- (void)removeAllSubviews;

- (void)setAnchorPoint:(CGPoint)point;

- (UIImage *)snapshot;
- (UIImage *)snapshotWithTransparancy:(BOOL)transparent;

@end

//
//  ArchiveViewController.h
//  feels
//
//  Created by Hannes Wikström on 4/13/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "ViewController.h"

@interface ArchiveViewController : UIViewController

typedef void(^ScrollViewDidScroll)(UIScrollView *scrollview);
typedef void(^ScrollViewDidEndDraggin)(UIScrollView *scrollview);
@property (nonatomic,copy) ScrollViewDidScroll didScroll;
@property (nonatomic,copy) ScrollViewDidEndDraggin didEndScroll;
@property (nonatomic, strong) UIView *imageViewsContainer;
@end

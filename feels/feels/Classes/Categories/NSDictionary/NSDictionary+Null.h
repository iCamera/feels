//
//  NSDictionary+Null.h
//  redbull-ss-ios
//
//  Created by Simon Andersson on 12/21/12.
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Null)

- (id)nullCheckedObjectForKey:(id)key;

@end
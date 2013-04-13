//
//  Video.h
//  feels
//
//  Created by Simon Andersson on 4/13/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) int index;

- (id)initWithDictionary:(NSDictionary *)dict;

@end

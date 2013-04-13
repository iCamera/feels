//
//  Video.m
//  feels
//
//  Created by Simon Andersson on 4/13/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "VideoModel.h"
#import "NSDictionary+Null.h"

@implementation VideoModel

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.author = [dict nullCheckedObjectForKey:@"author"];
        self.ID = [dict nullCheckedObjectForKey:@"id"];
        
        NSString *videoURLString = [dict nullCheckedObjectForKey:@"author"];
        self.videoURL = [NSURL URLWithString:videoURLString];
        self.location = [dict nullCheckedObjectForKey:@"location"];
        self.timestamp = [[dict nullCheckedObjectForKey:@"timestamp"] doubleValue];
        self.index = [[dict nullCheckedObjectForKey:@"index"] intValue];
    }
    return self;
}

- (NSUInteger)hash {
    return [self.ID hash];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[VideoModel class]] ? [self.ID isEqualToString:[object ID]] : NO;
}

@end

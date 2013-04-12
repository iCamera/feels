//
//  APIClient.m
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "APIClient.h"

@implementation APIClient

+ (APIClient *)shareClient {
    static APIClient *INSTANCE = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        INSTANCE = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://dev.hiddencode.me/ahd"]];
    });
    
    return INSTANCE;
}


- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end

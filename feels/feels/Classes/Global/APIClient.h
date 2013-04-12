//
//  APIClient.h
//  feels
//
//  Created by Simon Andersson on 4/12/13.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "AFNetworking.h"

@interface APIClient : AFHTTPClient

+ (APIClient *)shareClient;

@end

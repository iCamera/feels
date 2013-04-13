//
//  SessionManager.m
//  devote-ios
//
//  Created by Simon Andersson on 3/12/13.
//  Copyright (c) 2013 Monterosa. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager()<CLLocationManagerDelegate>

@end

@implementation LocationManager

+ (LocationManager *)sharedManager {
    
    static LocationManager *LOCATION_MANAGER_INSTANCE = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LOCATION_MANAGER_INSTANCE = [[self alloc] init];
    });
    
    return LOCATION_MANAGER_INSTANCE;
}

-(void)startTracking{
    [_locationManager startUpdatingLocation];
}

-(void)stopTracking{
    [_locationManager stopUpdatingLocation];
}

-(id)init {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    return self;
}

@end

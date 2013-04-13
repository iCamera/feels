//
//  SessionManager.h
//  devote-ios
//
//  Created by Simon Andersson on 3/12/13.
//  Copyright (c) 2013 Monterosa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

@property(nonatomic,strong) CLLocationManager *locationManager;

+ (LocationManager *)sharedManager;

-(void)startTracking;
-(void)stopTracking;

@end

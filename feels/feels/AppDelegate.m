//
//  AppDelegate.m
//  feels
//
//  Created by Andreas Areschoug on 2013-04-11.
//  Copyright (c) 2013 Feels. All rights reserved.
//

#import "AppDelegate.h"
#import "AppManager.h"
#import "APIClient.h"
#import "UIDevice+IdentifierAddition.h"
#import "NSTimer+Block.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    /* TA INTE BORT
     
    __block NSError *error = nil;
    NSString *location = @"Östermalm, Stockholm";
    NSString *author = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSMutableURLRequest *urlRequest = [[APIClient shareClient] multipartFormRequestWithMethod:@"POST" path:@"/ahd/upload" parameters:@{ @"location":location, @"author":author, @"timestamp":@(timestamp) } constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mov"] name:@"file" error:&error];
    }];
    
    if (!error) {
        AFHTTPRequestOperation *operation = [[APIClient shareClient] HTTPRequestOperationWithRequest:urlRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", NSStringFromClass([responseObject class]));
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@ %@", operation.responseString, [error localizedDescription]);
        }];
        
        
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            NSLog(@"Uploading: %.0f%%", ((float)totalBytesWritten/(float)totalBytesExpectedToWrite)*100.0);
        }];
        [operation start];
    }
    */
    
    NSLog(@"%@",[UIFont fontNamesForFamilyName:@"GeosansLight"]);
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] setInteger:[AppManager sharedManager].points forKey:kUsersAmountOfPoints];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

//
//  CLAppDelegate.m
//  CurioIOSSDKSample
//
//  Created by Harun Esur on 24/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CLAppDelegate.h"
#import "CurioSDK.h"

@implementation CLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    [[CurioSDK shared] startSession:launchOptions];

    
    
//    [[CurioSDK shared] startSession:@"http://curio.turkcell.com.tr/api/v2"
//                             apiKey:@"32f468f0d9c511e3a0760f5a28372ef6"
//                       trackingCode:@"1X1Y6A6P"
//                     sessionTimeout:4
//            periodicDispatchEnabled:FALSE
//                     dispatchPeriod:1
//            maxCachedActivitiyCount:50
//                     loggingEnabled:TRUE
//                           logLevel:3
//     registerForRemoteNotifications:TRUE
//            notificationDataPushUrl:@"https://curio.turkcell.com.tr/api/visitor/setPushData"
//                  notificationTypes:@"Sound,Badge,Alert"
//                   appLaunchOptions:launchOptions];
    

    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
 
    [[CurioNotificationManager shared] didReceiveNotification:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [[CurioNotificationManager shared] didRegisteredForNotifications:deviceToken];
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for remote natifications: %@",error.localizedDescription);
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

//
//  CurioNotificationManager.m
//  CurioSDK
//
//  Created by Marcus Frex on 17/11/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//


#import "CurioSDK.h"

@implementation CurioNotificationManager

+ (CS_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

- (NSString *) deviceToken {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [userDefaults objectForKey:CS_CONST_DEV_TOK];
}

- (void) setDeviceToken:(NSString *) deviceToken {
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:deviceToken forKey:CS_CONST_DEV_TOK];
    [userDefaults synchronize];
    
    
}


- (void) postToServer:(NSDictionary *)userInfo {
    
    
    @synchronized(self) {
        
        
        NSString *sUrl = [[CurioSettings shared] notificationDataPushURL];
        
        CS_Log_Info(@"Notification URL: %@ %@",sUrl,CS_RM_STR_NEWLINE(userInfo));
        
        NSURL *url = [NSURL URLWithString:sUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPShouldHandleCookies:NO];
        [request setValue:CS_OPT_USER_AGENT forHTTPHeaderField:@"User-Agent"];
        [request setHTTPBody:[[[CurioUtil shared] dictToPostBody:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [self deviceToken], @"deviceToken",
                                                                  [[CurioUtil shared] vendorIdentifier], @"visitorCode",
                                                                  [[CurioSettings shared] trackingCode], @"trackingCode",
                                                                  userInfo != nil ? [userInfo objectForKey:@"messageId"] : nil, @"messageId",
                                                                  nil]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data  = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        CS_Log_Info(@"Post response: %ld => %@",(long)httpResponse.statusCode,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        if (error != nil) {
            CS_Log_Warning(@"Warning: %ld , %@ %@",(long)error.code, sUrl, error.localizedDescription);
        }
        
        
    }

    
}

- (BOOL) hasItem:(NSString *)item in:(NSString *)in {
    
    NSArray *items = in != nil ? [in componentsSeparatedByString:@","] : [NSArray new];
    
    __block BOOL ret = FALSE;
    
    [items enumerateObjectsUsingBlock:^(NSString  *obj, NSUInteger idx, BOOL *stop) {
        
        //Stuff from preventing user mistakes
        NSString *check = [[obj stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        NSString *with = [[item stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        
        if ([check isEqualToString:with]) {
            ret = TRUE;
            *stop = TRUE;
        }
        
    }];
    
    return ret;
}

- (void) registerForNotifications {
    
    
    
    
    UIApplication *app = [UIApplication sharedApplication];
    
    NSString *regNotificationTypes = [[CurioSettings shared] notificationTypes];
    
    BOOL hasSound =[self hasItem:@"Sound" in:regNotificationTypes];
    BOOL hasAlert = [self hasItem:@"Alert" in:regNotificationTypes];
    BOOL hasBadge = [self hasItem:@"Badge" in:regNotificationTypes];
    
    CS_Log_Info(@"Registering for %@ %@ %@ notifications",
                (hasSound ? @"Sound" : @"") ,
                (hasAlert ? @"Alert" : @"") ,
                (hasBadge ? @"Badge" : @""))
    
    

    // If iOS version is 8.0
    if ([app respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        
        UIUserNotificationType notType = ((hasSound ? UIUserNotificationTypeSound : 0) |
                                          (hasAlert ? UIUserNotificationTypeAlert : 0) |
                                          (hasBadge ? UIUserNotificationTypeBadge : 0));
        
        CS_Log_Info(@"Registering for >= 8.0 notifications");
        
        [app registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          notType categories:nil]];
        
        [app registerForRemoteNotifications];
    }
    else
    // If iOS version is less than 8.0
    {
        UIRemoteNotificationType notType = ((hasSound ? UIRemoteNotificationTypeSound : 0) |
                                          (hasAlert ? UIRemoteNotificationTypeAlert : 0) |
                                          (hasBadge ? UIRemoteNotificationTypeBadge : 0));

        CS_Log_Info(@"Registering for 8.0 < notifications");
        
        [app registerForRemoteNotificationTypes:
         notType];
    }
}

- (void) didRegisteredForNotifications:(NSData *)deviceToken {
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [self setDeviceToken:token];
    
    CS_Log_Info(@"Device token: %@",token);
    
    NSDictionary *notif = [[[CurioSDK shared] appLaunchOptions] objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    // Means app is started by push notification
    if (notif) {
        
        [self postToServer:notif];
    }
    
}


- (void) didReceiveNotification:(NSDictionary *)userInfo {

    UIApplication *application = [UIApplication sharedApplication];
    
    // Means app resumed by push notification
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground)
        [self postToServer:userInfo];
    else {
        CS_Log_Info(@"Received notification %@ and ignoring",userInfo);
    }
    
}

@end

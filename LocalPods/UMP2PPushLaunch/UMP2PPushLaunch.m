//
//  UMP2PPushLaunch.m
//  UMP2PPushLaunch
//
//  Created by Fred on 2019/3/15.
//  Copyright © 2018年 UMEye. All rights reserved.
//

#import "UMP2PPushLaunch.h"
#import <UMLaunchKit/UMLaunchKit.h>
#import <UMAccount/UMAccount.h>
#import <UserNotifications/UserNotifications.h>

@interface UMP2PPushLaunch ()<UMLauncherProtocol,UNUserNotificationCenterDelegate>

@end


@implementation UMP2PPushLaunch

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 注册推送
    [self registerRemoteNotification];
    return TRUE;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 获取设备token
    NSString *token = [self hexStringForData:deviceToken];
    NSLog(@"\n>>>[DeviceToken]:%@\n\n", token);
    [self registerClient:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"\n>>>[DeviceToken error]:%@\n\n", error);

}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler API_AVAILABLE(ios(7.0)){
    
    // 处理静默通知
    
}


#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler API_AVAILABLE(macos(10.14), ios(10.0), watchos(3.0), tvos(10.0)){
    // 前台收到推送处理
    NSDictionary *userInfo = notification.request.content.userInfo;
    if (userInfo) {
        NSLog(@"\n>>[ReceivePayload]:%@", userInfo);
    }
    
    UNNotificationPresentationOptions options;
    if (@available(iOS 14.0, *)) {
        options = UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge;
    } else {
        options = UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge;
    }
    completionHandler(options);
    
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler API_AVAILABLE(macos(10.14), ios(10.0), watchos(3.0)) API_UNAVAILABLE(tvos){
    
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {// 点击通知打开App，处理跳转对应页面
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        NSLog(@"\n>>[ReceivePayload]:%@", userInfo);
    } else if([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]){// 用户关闭通知
        
    } else {// 自定义接受按钮
        
    }
    
    completionHandler();
}

#pragma mark - other
- (NSString *)hexStringForData:(NSData *)data{
    NSUInteger len = [data length];
    char *chars = (char *)[data bytes];
    if (!data || chars == NULL) {
        return @"";
    }
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i++) {
        [hexString appendFormat:@"%0.2hhx", chars[i]];
    }
    return hexString;
}

// SDK设置sClientToken 上报deviceToken到服务器
- (void)registerClient:(NSString *)clientId {
    NSLog(@"\n>>[RegisterClient]:%@\n\n", clientId);
    [UMWebClient shareClient].sClientToken = clientId;
    // 通知用户更新推送配置 platformFlag传值：apns
    if ([[UMWebClient shareClient] isLogin]) {
        [[UMWebClient shareClient] modifyUserPushInfo:YES disableOtherUsers:YES unReadCount:0 userId:nil platformFlag:@"apns"];
    }
}

#pragma mark - Property
/** 注册远程通知 */
- (void)registerRemoteNotification {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (error) {
                NSLog(@"request authorization error: %@", error.localizedDescription);
                return;
            }
            if (granted) {
                NSLog(@"request authorization succeeded!");
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 向苹果服务器注册推送
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    } else {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}



@end

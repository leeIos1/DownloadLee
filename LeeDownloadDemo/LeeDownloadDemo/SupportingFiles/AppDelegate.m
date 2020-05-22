//
//  AppDelegate.m
//  LeeDownloadDemo
//
//  Created by 姜自立 on 2020/5/21.
//  Copyright © 2020 姜自立. All rights reserved.
//

#import "AppDelegate.h"
#import "LeeFileVC.h"
#import "LeeDownloadManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    LeeFileVC *fileVC = [[LeeFileVC alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:fileVC];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navVC;
    [self.window makeKeyAndVisible];

    return YES;
}


 


@end

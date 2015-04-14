//
//  AppDelegate.m
//  CJXMX
//
//  Created by Liu on 15/4/13.
//  Copyright (c) 2015年 AngryBear. All rights reserved.
//

#import "AppDelegate.h"
#import "MLYLittleStarVC.h"
#import "MLYFriendsVC.h"
#import "MLYDiscoveryVC.h"
#import "MLYUserInfoVC.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.tabbarController = [[RDVTabBarController alloc] init];
    
    MLYLittleStarVC *littleStarVC = [[MLYLittleStarVC alloc] init];
    
    MLYFriendsVC *friendsVC = [[MLYFriendsVC alloc] init];
    
    MLYDiscoveryVC *discoveryVC = [[MLYDiscoveryVC alloc] init];
    
    MLYUserInfoVC *userInfoVC = [[MLYUserInfoVC alloc] init];
    
    self.tabbarController.viewControllers = @[littleStarVC, friendsVC, discoveryVC, userInfoVC];
    self.window.rootViewController = self.tabbarController;
    [self customizeTabBarForController:self.tabbarController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    UIImage *unfinishedImage = imageName(@"selected_img");
    UIImage *selectImage = imageName(@"home_black");
    NSArray *tabbarSelectImages = @[@"star", @"friend", @"discover", @"me"];
    NSArray *tabbarDeselectImages = @[@"star_selected", @"friend_selected", @"discover_selected", @"me_selected"];
    NSInteger index = 0;
    for (NSInteger i = 0; i < tabBarController.viewControllers.count; i++) {
        RDVTabBarItem *item = [tabBarController.tabBar.items objectAtIndex:i];
        [item setBackgroundSelectedImage:selectImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[tabbarSelectImages objectAtIndex:i]];
        UIImage *unselectedimage = [UIImage imageNamed:[tabbarDeselectImages objectAtIndex:i]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        index++;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

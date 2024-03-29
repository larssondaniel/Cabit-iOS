//
//  AppDelegate.m
//  Cabit
//
//  Created by Daniel Larsson on 2013-11-18.
//  Copyright (c) 2013 Cabit. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworkActivityLogger.h"
#import "CocoaLumberjack.h"

// Debug levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    UIColor *pink = [UIColor colorWithRed:(118 / 255.0)
                                    green:(214 / 255.0)
                                     blue:(84 / 255.0)
                                    alpha:1.0];
    [[DDTTYLogger sharedInstance] setForegroundColor:pink
                                     backgroundColor:nil
                                             forFlag:LOG_FLAG_INFO];

#ifdef DEBUG
    DDLogInfo(@"Launching in debug mode");
#else
    DDLogWarn(@"Launching in release mode");
#endif

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[AFNetworkActivityLogger sharedLogger] startLogging];

    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
        setFont:[UIFont fontWithName:@"OpenSans" size:14]];

    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary
        dictionaryWithDictionary:
            [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:@"OpenSans" size:18]
                          forKey:NSFontAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the
    // application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down
    // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive
    // state; here you can undo many of the changes made on entering the
    // background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}

@end

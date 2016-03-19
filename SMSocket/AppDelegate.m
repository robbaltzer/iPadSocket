//
//  AppDelegate.m
//  SMSocket
//
//  Created by Rob Baltzer on 1/15/13.
//  Copyright (c) 2013 Rob Baltzer. All rights reserved.
//

#import "AppDelegate.h"
#import "AsyncSocket.h"
#import "SocketControl.h"


@implementation AppDelegate
@synthesize socketControl, trace, eaSessionController, packetHandler;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    trace = [[Trace alloc] init];   // This should be the first object to create so all the later objects can use it
    eaSessionController = [[EASessionController alloc] init];
    socketControl = [[SocketControl alloc] init];
    packetHandler = [[PacketHandler alloc] init];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    
//    eaSessionController = nil;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    // CLose EA Session here! (?)
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    eaSessionController = [[EASessionController alloc] init];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        [socketControl rxStartServer];
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

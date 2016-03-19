//
//  AppDelegate.h
//  SMSocket
//
//  Created by Rob Baltzer on 1/15/13.
//  Copyright (c) 2013 Rob Baltzer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trace.h"
#import "SendPacket.h"
#import "PacketHandler.h"
#import "EASessionController.h"

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

@class SocketControl;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    EASessionController* eaSessionController;
    Trace* trace;
    SocketControl* socketControl;
    PacketHandler* packetHandler;
}

@property (nonatomic, strong) SocketControl* socketControl;
@property (nonatomic, strong) Trace *trace;
@property (nonatomic, strong) EASessionController* eaSessionController;
@property (nonatomic, strong) PacketHandler* packetHandler;

@property (strong, nonatomic) UIWindow *window;

@end

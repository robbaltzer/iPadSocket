//
//  PacketHandler.h
//  ThunderDev
//
//  Created by Rob Baltzer on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SendPacket.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "Trace.h"
#import "MyPacket.h"
#import "PageData.h"

@class EASessionController;

typedef enum {
    NothingPending,
    AccessoryDisconnectPending,
    AccessoryConnectPending,
} AccessoryEvent;

@interface PacketHandler : NSObject {
    SendPacket* sendPacket;
    EASessionController *eaSessionController;
    Trace* trace;
    MyPacket *myPacket;
}

@property (nonatomic, strong) MyPacket *myPacket;
@end

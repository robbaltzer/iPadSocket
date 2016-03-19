//
//  SocketControl.h
//  SMSocket
//
//  Created by Rob Baltzer on 1/16/13.
//  Copyright (c) 2013 Rob Baltzer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendPacket.h"
#import "protocol_defs.h"

@class AsyncSocket;
@class Trace;

@interface SocketControl : NSObject {
    AsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;
    Trace* trace;
	BOOL isRunning;
    int port;
    SendPacket* sendPacket;
    EASessionController* eaSessionController;
}

@property (nonatomic, strong) AsyncSocket *listenSocket;
@property (nonatomic, strong) NSMutableArray *connectedSockets;
@property int port;

- (void) rxStartServer;
- (void) rxStopServer;

@end

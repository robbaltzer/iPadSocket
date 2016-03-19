//
//  PacketHandler.m
//  ThunderDev
//
//  Created by Rob Baltzer on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PacketHandler.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "EASessionController.h"
#import "AppDelegate.h"
//#import "nvram.h"   // Shared with Thunder's 8051

#define STATE_MACHINE_TICK      (100)        // Length of state machine tick in ms

// NOTE: In phIdle, "ph" = (p)acket (h)andler
typedef enum {
    phIdle,
    phConnectEventOccurred,
    phConnectEventDebounce,
    phExecuteEvent,
    phComplete,
    phError,
} PacketHandlerState;

@implementation PacketHandler
@synthesize myPacket;

- (id)init {
    self = [super init];
    if (self) {
        trace = ApplicationDelegate.trace;
        sendPacket = [[SendPacket alloc] init];
        myPacket = [[MyPacket alloc] init];
        eaSessionController = ApplicationDelegate.eaSessionController;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accessoryDataReceived:) 
                                                     name:EASessionDataReceivedNotification 
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(packetReceived:)
                                                     name:@"packetReceived"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(UIApplicationWillEnterForegroundNotification:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
       
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(UIApplicationWillTerminateNotification:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];


        [trace trace:@"PacketHandler alive"];
    }
    return self;
}

- (void) UIApplicationWillResignActiveNotification:(NSNotification *)notification
{
//    [trace trace:@"UIApplicationWillResignActiveNotification"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EASessionDataReceivedNotification object:nil];
}

- (void) UIApplicationWillEnterForegroundNotification:(NSNotification *)notification
{
//    [trace trace:@"UIApplicationWillEnterForegroundNotification"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDataReceived:)
                                                 name:EASessionDataReceivedNotification
                                               object:nil];
}

- (void) accessoryDataReceived:(NSNotification*) notification {
    NSData* tmpData = [eaSessionController readData:[eaSessionController readBytesAvailable]];
    [myPacket updateWithNSData:tmpData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"packetReceived" object:self];
}

- (void)packetReceived:(NSNotification *)notification
{
    SoundcasePacket* scPacket;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSS"];
    
    if (myPacket) {
        scPacket = (SoundcasePacket*) [myPacket.theData bytes];
//        [trace trace:FORMAT(@"Got an RX packet. Parm %d", scPacket->parameter)];
        switch(scPacket->parameter) {
            case ParmSocket:
            {
                u8 dataLen = scPacket->packet_len - PACKET_HEADER_LEN;
                PageData* pageData = [[PageData alloc] init];
                
                memcpy([pageData bytes], scPacket->bulk_data, dataLen);
                pageData.len = dataLen;
//                [trace trace:FORMAT(@"ParmSocket # bytes %d", dataLen)];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SocketDataReceived"
                                                                    object:pageData];
            }
                break;
            default:
                break;
        }
    }
}



@end

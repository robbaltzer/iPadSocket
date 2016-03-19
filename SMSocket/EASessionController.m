/*
 * Copyright 2013 by Avnera Corporation, Beaverton, Oregon.
 *
 *
 * All Rights Reserved
 *
 *
 * This file may not be modified, copied, or distributed in part or in whole
 * without prior written consent from Avnera Corporation.
 *
 *
 * AVNERA DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
 * ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL
 * AVNERA BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
 * ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
 * WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
 * ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
 * SOFTWARE.
 */

#import "EASessionController.h"
#import "AppDelegate.h"

#define PROTOCOL_STRING         @"com.avnera.sc"

NSString *EASessionDataReceivedNotification = @"EASessionDataReceivedNotification";

@implementation EASessionController
@synthesize sessionOpen = _sessionOpen;

- (id)init
{
	if((self = [super init]))
	{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(UIApplicationWillResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(UIApplicationWillEnterForegroundNotification:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [self enableConnectNotifications];
        trace = ApplicationDelegate.trace;
        _sessionOpen = NO;
        [trace trace:@"Initting EASessionController"];
        if ([self searchForAccessory]) {
            [self openSession];
        }
	}
	return self;
}

- (void) UIApplicationWillResignActiveNotification:(NSNotification *)notification
{
    [trace trace:@"UIApplicationWillResignActiveNotification"];
    [self closeSession];
    [self disableConnectNotifications];
}

- (void) UIApplicationWillEnterForegroundNotification:(NSNotification *)notification
{
    [trace trace:@"UIApplicationWillEnterForegroundNotification"];   
    [self enableConnectNotifications];
    if ([self searchForAccessory]) {
        [self openSession];
    }
}


#pragma mark EAAccessoryDelegate
- (void)accessoryDidDisconnect:(EAAccessory *)accessory
{
    [trace trace:FORMAT(@"[NOTIF] accessoryDidDisconnect id: %d",[accessory connectionID ])];
    if (_sessionOpen) [self closeSession];
}


- (void)_accessoryDidConnect:(NSNotification *)notification {
    EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    _protocolString = [PROTOCOL_STRING copy];
    _accessory = connectedAccessory;
    [trace trace:FORMAT(@"[NOTIF] _accessoryDidConnect id: %d", [_accessory connectionID])];
    [self openSession];
}

- (void)dealloc
{
    if (_sessionOpen) [self closeSession];
    _accessory = nil;
    _protocolString = nil;
    [self disableConnectNotifications];
}


// open a session with the accessory and set up the input and output stream on the default run loop
- (BOOL)openSession
{
    [_accessory setDelegate:self];
    [trace trace:FORMAT(@"Attempting to open session with _accessory %d and protocol %@",[_accessory connectionID], _protocolString)];
    _session = [[EASession alloc] initWithAccessory:_accessory forProtocol:_protocolString];

    if (_session)
    {
        [[_session inputStream] setDelegate:self];
        [[_session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session inputStream] open];

        [[_session outputStream] setDelegate:self];
        [[_session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session outputStream] open];
        _sessionOpen = YES;
        [trace trace:FORMAT(@"_session open acc id %d protocol string %@", [[_session accessory] connectionID], [_session protocolString])];
    }
    else
    {
        NSLog(@"creating session failed");
        [trace trace:@"_session failed to open"];
        _sessionOpen = NO;
    }

    return (_session != nil);
}

- (BOOL) searchForAccessory
{
    BOOL retVal = FALSE;
    NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager]
                            connectedAccessories];
    
    [trace trace:@"searchForAccessory"];
    for (EAAccessory *obj in accessories) {
        [trace trace:@"Accessory connected"];
        if ([[obj protocolStrings] containsObject:PROTOCOL_STRING]) {
            _accessory = obj;
            _protocolString = [PROTOCOL_STRING copy];
            [trace trace:FORMAT(@"Found protocol %@ for acc id: %d",PROTOCOL_STRING, [_accessory connectionID])];
            retVal = TRUE;
//            break;
        }
    }
    if (!retVal) [trace trace:@"No accessory found"];
    return retVal;
}

// close the session with the accessory.
- (void)closeSession
{
    [trace trace:FORMAT(@"closeSession acc id %d protocol string %@", [[_session accessory] connectionID], [_session protocolString])];
    [[_session inputStream] close];
    [[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session inputStream] setDelegate:nil];
    [[_session outputStream] close];
    [[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session outputStream] setDelegate:nil];

    _session = nil;
    _writeData = nil;
    _readData = nil;
    
    _sessionOpen = NO;
}

// high level write data method
- (void)writeData:(NSData *)data
{
    if (_writeData == nil) {
        _writeData = [[NSMutableData alloc] init];
    }

    [_writeData appendData:data];
    [self _writeData];
}

// high level read method 
- (NSData *)readData:(NSUInteger)bytesToRead
{
    NSData *data = nil;
    if ([_readData length] >= bytesToRead) {
        NSRange range = NSMakeRange(0, bytesToRead);
        data = [_readData subdataWithRange:range];
        [_readData replaceBytesInRange:range withBytes:NULL length:0];
    }
    return data;
}

// get number of bytes read into local buffer
- (NSUInteger)readBytesAvailable
{
    return [_readData length];
}

#pragma mark NSStreamDelegateEventExtensions

// asynchronous NSStream handleEvent method
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            [self _readData];
            break;
        case NSStreamEventHasSpaceAvailable:
            [self _writeData];
            break;
        case NSStreamEventErrorOccurred:
            break;
        case NSStreamEventEndEncountered:
            break;
        default:
            break;
    }
}

#pragma mark Internal

// low level write method - write data to the accessory while there is space available and data to write
- (void)_writeData {
    while (([[_session outputStream] hasSpaceAvailable]) && ([_writeData length] > 0))
    {
        NSInteger bytesWritten = [[_session outputStream] write:[_writeData bytes] maxLength:[_writeData length]];
        if (bytesWritten == -1)
        {
            NSLog(@"write error");
            break;
        }
        else if (bytesWritten > 0)
        {
            [_writeData replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
        }
    }
}

// low level read method - read data while there is data and space available in the input buffer
- (void)_readData {
//    [trace trace:@"_readData"];
#define EAD_INPUT_BUFFER_SIZE 128
    uint8_t buf[EAD_INPUT_BUFFER_SIZE];
    while ([[_session inputStream] hasBytesAvailable])
    {
        NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
        if (_readData == nil) {
            _readData = [[NSMutableData alloc] init];
        }
        [_readData appendBytes:(void *)buf length:bytesRead];
        //NSLog(@"read %d bytes from input stream", bytesRead);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EASessionDataReceivedNotification object:self userInfo:nil];
}


- (void) enableConnectNotifications {
    [trace trace:@"enableConnectNotifications"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
}

- (void) disableConnectNotifications {
    [trace trace:@"disableConnectNotifications"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
        [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
}

@end

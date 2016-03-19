//
//  SocketControl.m
//  SMSocket
//
//  Created by Rob Baltzer on 1/16/13.
//  Copyright (c) 2013 Rob Baltzer. All rights reserved.
//

#import "SocketControl.h"
#import "AsyncSocket.h"
#import "AppDelegate.h"
#import "SendPacket.h"

#define WELCOME_MSG  0
#define ECHO_MSG     1
#define WARNING_MSG  2

#define READ_TIMEOUT 600.0
#define READ_TIMEOUT_EXTENSION 10.0

#define MAX_OUT_BYTES_SIZE  (256)


//#define TELNET_SUPPORT  // Uncomment this if you want to use telnet instead of SMServe for debugging

#ifdef TELNET_SUPPORT
#define CRLF_TERMINATIONS
#else
#define NULL_TERMINATIONS
#endif

#define CR_BYTE     (13)
#define LF_BYTE     (10)
#define NULL_BYTE   (0)

@implementation SocketControl
@synthesize listenSocket, connectedSockets, port;

- (id)init
{
	if((self = [super init]))
	{
		listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
		connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        trace = ApplicationDelegate.trace;
        eaSessionController = ApplicationDelegate.eaSessionController;
        sendPacket = [[SendPacket alloc] init];
        // Advanced options - enable the socket to contine operations even during modal dialogs, and menu browsing
        [listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
		isRunning = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(SocketDataReceived:)
                                                     name:@"SocketDataReceived"
                                                   object:nil];
	}
	return self;
}

- (void)SocketDataReceived:(NSNotification *)notification {
    u8* bytes;
    u8 len;
    
    PageData* pageData = [notification object];
    bytes = [pageData bytes];
    len = [pageData len];
    
//    [trace trace:FORMAT(@"SocketDataRx len %d byte0 0x%x byte1 0x%x", len, bytes[0], bytes[1])];
    if (len > 253) {
        [trace trace:@"Error: Packet greater than 253 bytes"];
    }


    NSString* tmp = [[NSString alloc] initWithString:[self bytes2String:bytes : len]];
    NSData* data = [tmp dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* data2 = [data mutableCopy];

#ifdef CRLF_TERMINATIONS
    u8 tmpLf = LF_BYTE;
    u8 tmpCr = CR_BYTE;
    [data2 appendBytes: &tmpLf length:1];
    [data2 appendBytes: &tmpCr length:1];
#endif
#ifdef NULL_TERMINATIONS
    u8 tmpNull = NULL_BYTE;
    [data2 appendBytes: &tmpNull length:1];
#endif
    
    NSUInteger i;
    for(i = 0; i < [connectedSockets count]; i++)
    {
        [[connectedSockets objectAtIndex:i] writeData:data2 withTimeout:-1 tag:0];
    } 
}

- (void) rxStartServer {
    if (!isRunning){
		if(port < 0 || port > 65535)
		{
			port = 0;
		}
		
		NSError *error = nil;
		if(![listenSocket acceptOnPort:port error:&error])
		{
			[trace trace:FORMAT(@"Error starting server: %@", error)];
			return;
		}
		
		[trace trace:FORMAT(@"SM Socket started on port %hu", [listenSocket localPort])];
		isRunning = YES;
    }
    else {
        [trace trace:@"RX Server already running"];
    }
}

- (void) rxStopServer {
   
    if (isRunning) {
    // Stop accepting connections
    [listenSocket disconnect];
    
    // Stop any client connections
    NSUInteger i;
    for(i = 0; i < [connectedSockets count]; i++)
    {
        // Call disconnect on the socket,
        // which will invoke the onSocketDidDisconnect: method,
        // which will remove the socket from the list.
        [[connectedSockets objectAtIndex:i] disconnect];
    }
    
        [trace trace:@"Stopped SM Socket"];
        isRunning = false;
    }
    else {
        [trace trace:@"RX Server already stopped"];
    }
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	[trace trace:@"didAcceptNewSocket"];
    [connectedSockets addObject:newSocket];
}



- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)tport
{
	[trace trace:FORMAT(@"Accepted client %@:%hu", host, tport)];
	
	NSString *welcomeMsg = @"Welcome to SM Socket\r\n";
	[trace trace: welcomeMsg];
	
#ifdef CRLF_TERMINATIONS
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];  // delimeter for telnet, good for debug
#endif
#ifdef NULL_TERMINATIONS
    [sock readDataToData:[AsyncSocket ZeroData] withTimeout:READ_TIMEOUT tag:0];    // delimeter for logmon, smui, (Avnera tools in general)...
#endif
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //TODO: Do we need to do something here?
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    int remainder = 2;
#ifdef CRLF_TERMINATIONS
    remainder = 2;
#endif
#ifdef NULL_TERMINATIONS
    remainder = 1;
#endif
    
    
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - remainder)];
	NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];

    // Make sure we have an even number of characters
    if ([msg length] % 2 > 0) {
        [trace trace:@"(didReadData): String from SMServe did not have even number of characters"];
        goto exit;
    }
    
    if(msg)
	{
		[trace trace:FORMAT(@"In socket: %@", msg)];
	}
	else
	{
		[trace trace:@"Error converting received data into UTF-8 String"];
	}
	
    u8 outBytes[MAX_OUT_BYTES_SIZE];
    
    if (eaSessionController.sessionOpen) {
        if ([self incomingString2Bytes:msg :outBytes]) {
            [sendPacket sendDataPacket:ParmSocket : cmdSend : 0 : [msg length]/2 : outBytes];
        }
    }
    else {
        [trace trace:@"ERROR: EASession not open"];
    }
    
exit:
#ifdef CRLF_TERMINATIONS
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
#endif
#ifdef NULL_TERMINATIONS
    [sock readDataToData:[AsyncSocket ZeroData] withTimeout:READ_TIMEOUT tag:0];
#endif

}

/**
 * This method is called if a read has timed out.
 * It allows us to optionally extend the timeout.
 * We use this method to issue a warning to the user prior to disconnecting them.
 **/
- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
				   elapsed:(NSTimeInterval)elapsed
				 bytesDone:(NSUInteger)length
{
	if(elapsed <= READ_TIMEOUT)
	{
//		NSString *warningMsg = @"Are you still there?\r\n";
//		[trace trace: warningMsg];
//        NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
		
//		[sock writeData:warningData withTimeout:-1 tag:WARNING_MSG];
		
		return READ_TIMEOUT_EXTENSION;
	}
	
	return 0.0;
}


- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	[trace trace: FORMAT(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort])];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	[connectedSockets removeObject:sock];
}

// Helper functions

- (bool) incomingString2Bytes : (NSString*) inString :(u8*) outBytes
{
    // Make sure we have an even number of characters
    if ([inString length]%2 > 0) {
        [trace trace:@"(incomingString2Bytes): String from SMServe did not have even number of characters"];
        return false;
    }
    
    NSString* tmpString = [[NSString alloc] initWithString:inString];
    // Convert to uppercase
    NSString* hexString = [[NSString alloc] initWithString:[tmpString uppercaseString]];
    
    // Convert to bytes
//    [trace trace: FORMAT(@"hexString length %d", [hexString length])];
    for(int i = 0; i < [hexString length]; i += 2) {
        NSRange range = { i, 2 };
        NSString *subString = [hexString substringWithRange:range];
        unsigned value;
        [[NSScanner scannerWithString:subString] scanHexInt:&value];
        outBytes[i / 2] = (u8)value;
    }
    return true;
}

// Create hex string
- (NSString*) bytes2String :(u8*) bytes :(u8) len
{
    NSMutableString* returnString = [[NSMutableString alloc] init];
    for (int i = 0 ; i < len ; i++) {
        [returnString appendFormat:@"%02x", bytes[i]];
    }

    [trace trace:FORMAT(@"Out socket %@", returnString)];
    return (NSString*) returnString;
}

@end

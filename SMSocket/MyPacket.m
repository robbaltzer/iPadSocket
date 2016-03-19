/*
 * Copyright 2012 by Avnera Corporation, Beaverton, Oregon.
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

#import "MyPacket.h"
#import "AppDelegate.h"

@implementation MyPacket
@synthesize theData;

- (id)init
{
    SoundcasePacket packet;
    
    self = [super init];
    if (self) {
        trace = ApplicationDelegate.trace;
        // Initialization code here
        memset((void*) &packet, 0, sizeof(SoundcasePacket));
        packet.start_byte = SC_START_BYTE;
        packet.packet_len = PACKET_HEADER_LEN;
        packet.packet_total = 1;
        packet.packet_number = 1;
        theData = [[NSMutableData alloc] initWithBytes:&packet length:PACKET_HEADER_LEN];
    }
    return self;
}

- (id) initWithNSData: (NSData*) initData {
    SoundcasePacket* packet;
    
    self = [super init];
    if (self) {
        // Initialization code here
        theData = [[NSMutableData alloc] initWithBytes:[initData bytes] length:[initData length]];
        packet = (SoundcasePacket*) [theData bytes];
        if (packet->start_byte != SC_START_BYTE) {
            //[myTraceController trace:@"(err) Bad start byte"]; todo: error message
            return 0;
        }
        
    }
    return self;
}

// todo: probably can get rid of this...
- (void) updateWithNSData: (NSData*) updateData {
    [theData setLength:0];
    [theData appendData:updateData];
}

- (void) updateWithNSMutableData: (NSMutableData*) updateData {
    [theData setLength:0];
    [theData appendData:updateData];
}

- (void) createSimplePacket: (SoundSkinParameter_t) parameter : (Command_t) cmd : (s16) value{
    SoundcasePacket* packet;

    packet = (SoundcasePacket*) [theData mutableBytes];
    packet->parameter = parameter;
    packet->command = cmd;   
    packet->value = value;   
}

- (void) createDataPacket: (SoundSkinParameter_t) parameter : (Command_t) cmd : (s16) value : (u16) len :(u8*) data {
    SoundcasePacket* packet;
    
    packet = (SoundcasePacket*) [theData mutableBytes];
    packet->parameter = parameter;
    packet->command = cmd;   
    packet->value = value;
    packet->packet_len += len;
//    [trace trace:FORMAT(@"packet->packet_len %d", packet->packet_len)];
    [theData appendBytes:data length:len];
}

@end




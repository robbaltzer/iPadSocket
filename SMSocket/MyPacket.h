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

#import <Foundation/Foundation.h>
#import "protocol_defs.h"
#import "Trace.h"

@interface MyPacket : NSObject {
    NSMutableData* theData;
    Trace* trace;
}

@property (nonatomic, strong) NSMutableData* theData;

- (id) initWithNSData: (NSData*) initData;      // Use this if not already alloc'd
- (void) updateWithNSData: (NSData*) updateData;  // Use this if already created with init
- (void) updateWithNSMutableData: (NSMutableData*) updateData;  // Use this if already created with init
- (void) createSimplePacket: (SoundSkinParameter_t) parameter : (Command_t) cmd : (s16) value;
- (void) createDataPacket: (SoundSkinParameter_t) parameter : (Command_t) cmd : (s16) value : (u16) len :(u8*) data;
@end

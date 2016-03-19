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

#import "SendPacket.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "EASessionController.h"
#import "AppDelegate.h"

@implementation SendPacket
@synthesize _eaSessionController;

- (id)init {
    self = [super init];
    if (self) {
        _eaSessionController = ApplicationDelegate.eaSessionController;
    }
    return self;
}

- (void)sendSimplePacket: (SoundSkinParameter_t) parameter : (Command_t) cmd : (s16) value {
    MyPacket *thePacket = [[MyPacket alloc] init];
    
    [thePacket createSimplePacket :parameter :cmd :value];
    [_eaSessionController writeData:thePacket.theData];
}

- (void)sendDataPacket: (SoundSkinParameter_t) parameter : (Command_t) cmd : (s16) value : (u16) len : (u8*) data {
    MyPacket *thePacket = [[MyPacket alloc] init];
    
    [thePacket createDataPacket :parameter :cmd :value :len :data];
    [_eaSessionController writeData:thePacket.theData];
}

@end

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

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "Trace.h"

extern NSString *EASessionDataReceivedNotification;

// NOTE: EADSessionController is not threadsafe, calling methods from different threads will lead to unpredictable results
@interface EASessionController : NSObject <EAAccessoryDelegate, NSStreamDelegate> {
    EAAccessory *_accessory;
    EASession *_session;
    NSString *_protocolString;

    NSMutableData *_writeData;
    NSMutableData *_readData;
    Trace* trace;
    BOOL sessionOpen;
}

- (void)writeData:(NSData *)data;
- (NSUInteger)readBytesAvailable;
- (NSData *)readData:(NSUInteger)bytesToRead;

@property BOOL sessionOpen;
@end

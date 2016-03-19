//
//  PageData.h
//  SoundSkin
//
//  Created by Rob Baltzer on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "protocol_defs.h"

// Object class for storing 256 bytes of data
@interface PageData : NSObject {
    u8 data[256];
    int len;
}
@property u8* bytes;
@property int len;
@end


//
//  PageData.m
//  SoundSkin
//
//  Created by Rob Baltzer on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PageData.h"

@implementation PageData
@synthesize bytes, len;;
- (id) init {
    self = [super init];
    if (self) {
        len = -1;   // Invalid len
        bytes = data;
    }
    return self;
}
@end

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

#import "Trace.h"

@implementation Trace
@synthesize textView = _textView;
@synthesize dataCollectionMode;

- (id)init
{
    self = [super init];
    if (self) {
        textViewText = [[NSMutableString alloc] initWithFormat:@""];
        // Initialization code here.
    }
    self.dataCollectionMode = FALSE;
    return self;
}


-(void) clear {
    textViewText = [[NSMutableString alloc] initWithFormat:@""];
    [self update];
}



- (void) trace: (NSString*) theString {
    if (dataCollectionMode) return;

    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"[MM-dd hh:mm:ss:SSS a] "];
    NSString *dateString = [dateFormat stringFromDate:today];
    NSMutableString* tmp1 = [[NSMutableString alloc] initWithString: dateString];
    [tmp1 appendString: theString];
    NSString * tempString = [[NSString alloc] initWithFormat:@"%@\n", tmp1];
    textViewText = (NSMutableString*) [textViewText stringByAppendingString:tempString];
    [self update];
}

- (void) traceBulkData: (int) count : (u8*) bytes {
    if (dataCollectionMode) return;
    int i = 0;
    NSMutableString* printString = [[NSMutableString alloc] init];
    while (count-- > 0) {
        [printString appendFormat:@"%02X ", bytes[i++]];
        if ((i%8) == 0) {
            [printString appendString:@" "];
        } 
        if ((i%16) == 0) {
            [printString appendString:@"\r\n"];
        }      
    }
    [self trace : printString];
}

// Trace in order to copy to excel and do X/Y plot
- (void) traceData: (NSString*) theFormat : (uint32_t) theTime : (uint32_t) theValue{
    NSString * tempString = [[NSString alloc] initWithFormat:theFormat, theTime, theValue];
    
    textViewText = (NSMutableString*) [textViewText stringByAppendingString:tempString];
    [self update];
}

- (void) traceString: (NSString*) theFormat : (NSString*) theString{
    if (dataCollectionMode) return;
    NSString * tempString = [[NSString alloc] initWithFormat:theFormat, theString];
    [self trace : tempString];
}

- (void) update {
    if (_textView) {
        _textView.text = textViewText;  
        CGPoint bottomOffset = CGPointMake(0, [_textView contentSize].height - _textView.frame.size.height + 20);
    
        if (bottomOffset.y > 0)
            [_textView setContentOffset: bottomOffset animated: YES];
    }
}

@end

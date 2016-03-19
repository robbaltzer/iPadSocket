//
//  ViewController.h
//  SMSocket
//
//  Created by Rob Baltzer on 1/15/13.
//  Copyright (c) 2013 Rob Baltzer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trace.h"
#import "SocketControl.h"

@interface ViewController : UIViewController {
    SocketControl* socketControl;
    Trace* trace;
}

@property (weak, nonatomic) IBOutlet UILabel *labelRevisionNumber;
@property (weak, nonatomic) IBOutlet UITextField *textPort;
@property (weak, nonatomic) IBOutlet UILabel *labelIPAddress;
@property (weak, nonatomic) IBOutlet UITextView *textViewTrace1;
- (IBAction)buttonStartRXServer:(id)sender;
- (IBAction)buttonStopRXServer:(id)sender;
- (IBAction)buttonClear:(id)sender;

@end

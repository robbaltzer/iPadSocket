//
//  ViewController.m
//  SMSocket
//
//  Created by Rob Baltzer on 1/15/13.
//  Copyright (c) 2013 Rob Baltzer. All rights reserved.
//

#import "ViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize labelRevisionNumber;

- (void)viewDidLoad
{
    [super viewDidLoad];
    trace = ApplicationDelegate.trace;
    socketControl = ApplicationDelegate.socketControl;
    
    [trace setTextView: self.textViewTrace1];
    [trace clear];
    [trace update];
    [trace trace:@"Trace up and running"];
    [self.labelIPAddress setText:[self getIPAddress]];
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    [labelRevisionNumber setText:appVersion];
    [socketControl setPort:[self.textPort.text integerValue]];
    [socketControl rxStartServer];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return NO;
    }
    return YES;
}

// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

- (IBAction)buttonStartRXServer:(id)sender {
    [self.labelIPAddress setText:[self getIPAddress]];
    [socketControl setPort:[self.textPort.text integerValue]];
    [socketControl rxStartServer];
}

- (IBAction)buttonStopRXServer:(id)sender {
    [self.labelIPAddress setText:[self getIPAddress]];
    [socketControl rxStopServer];
}

- (IBAction)buttonClear:(id)sender {
    [self.labelIPAddress setText:[self getIPAddress]];
    [trace clear];
}

- (void)viewDidUnload
{
    [self setLabelRevisionNumber:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end

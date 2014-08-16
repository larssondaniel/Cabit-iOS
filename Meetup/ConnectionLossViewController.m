//
//  ConnectionLossViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-08-13.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "ConnectionLossViewController.h"
#import "Reachability.h"
#import "MainViewController.h"

#import <Foundation/Foundation.h>

@interface ConnectionLossViewController ()
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic) Reachability *hostReachability;

@end

@implementation ConnectionLossViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.messageLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    NSString *remoteHostName = @"www.apple.com";
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
}

- (IBAction)retry {
    NetworkStatus netStatus = [self.hostReachability currentReachabilityStatus];
    if (!netStatus == NotReachable) {
        NSLog(@"Seems fine");
        MainViewController *mainViewController = (MainViewController *)self.parentViewController;
        [self viewWillDisappear:YES];
        [mainViewController hideConnectionLossView];
    }
}

@end
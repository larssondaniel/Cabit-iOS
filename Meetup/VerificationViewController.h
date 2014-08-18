//
//  TutorialViewController.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-06-05.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookingHTTPClient.h"

@interface VerificationViewController
    : UIViewController<UITextFieldDelegate, BookingHTTPClientDelegate>

- (void)setMessage:(NSString *)message;

@end

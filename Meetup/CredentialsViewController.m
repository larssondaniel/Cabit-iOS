//
//  CredentialsViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-05-07.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "CredentialsViewController.h"
#import "MainViewController.h"
#import "CAKeyframeAnimation+AHEasing.h"

@interface CredentialsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *bigLabel;
@property (strong, nonatomic) IBOutlet UILabel *smallLabel;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *phoneField;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;

@end

@implementation CredentialsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.nameField setValue:[UIColor colorWithWhite:0.85 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    [self.phoneField setValue:[UIColor colorWithWhite:0.85 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    [self.continueButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:22]];
}

- (IBAction)clickedContinue {
    MainViewController *mainViewController = (MainViewController *)self.parentViewController;
    [mainViewController didFinishEnteringCredentials];
}

- (void)beginAnimations {
    CAAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:ExponentialEaseOut fromPoint:CGPointMake(self.bigLabel.center.x, self.bigLabel.center.y) toPoint:CGPointMake(self.bigLabel.center.x, self.bigLabel.center.y + 120)];
    animation.duration = 0.6;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.bigLabel.layer addAnimation:animation forKey:@"easing"];

    CAAnimation *animation_smallLabel = [CAKeyframeAnimation animationWithKeyPath:@"position" function:ExponentialEaseOut fromPoint:CGPointMake(self.smallLabel.center.x, self.smallLabel.center.y) toPoint:CGPointMake(self.smallLabel.center.x, self.smallLabel.center.y + 120)];
    animation_smallLabel.duration = 0.6;
    animation_smallLabel.fillMode = kCAFillModeForwards;
    animation_smallLabel.removedOnCompletion = NO;

    [self.smallLabel.layer addAnimation:animation_smallLabel forKey:@"easing"];
}

- (void)saveCredentials {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.nameField.text forKey:@"Name"];
    [defaults setObject:self.phoneField.text forKey:@"PhoneNumber"];
    [defaults synchronize];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
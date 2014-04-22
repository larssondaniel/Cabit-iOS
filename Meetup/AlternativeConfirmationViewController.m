//
//  AlternativeConfirmationViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-04-18.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "AlternativeConfirmationViewController.h"
#import "BBCyclingLabel.h"
#import "UIImage+animatedGIF.h"

@interface AlternativeConfirmationViewController ()

@property (nonatomic) BBCyclingLabel *label;
@property (strong, nonatomic) IBOutlet UIImageView *gifView;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIView *pickUpView;
@property (strong, nonatomic) IBOutlet UIView *destinationView;
@property (strong, nonatomic) IBOutlet UILabel *pickupStaticLabel;
@property (strong, nonatomic) IBOutlet UILabel *destinationStaticLabel;
@property (strong, nonatomic) IBOutlet UIButton *pickupLabel;
@property (strong, nonatomic) IBOutlet UIButton *destinationLabel;
@property (strong, nonatomic) IBOutlet UIView *statusView;
@property (strong, nonatomic) IBOutlet UIImageView *dot1;
@property (strong, nonatomic) IBOutlet UIImageView *dot2;
@property (strong, nonatomic) IBOutlet UIImageView *dot3;
@property (strong, nonatomic) IBOutlet UIImageView *dot4;
@property (strong, nonatomic) IBOutlet UIImageView *dot5;

@end

@implementation AlternativeConfirmationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.pickupLabel.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    [self.destinationLabel.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    [self.pickUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bottomView"]]];
    [self.destinationView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bottomView"]]];
    [self.pickupStaticLabel setFont:[UIFont fontWithName:@"OpenSans" size:11]];
    [self.destinationStaticLabel setFont:[UIFont fontWithName:@"OpenSans" size:11]];
    [self.cancelButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blueButton"]]];

    CGRect labelFrame = CGRectMake(0, 70, 320, 40);
    
    self.label = [[BBCyclingLabel alloc] initWithFrame:labelFrame];
    [self.label setFont:[UIFont fontWithName:@"OpenSans" size:28]];
    [self.label setTextColor:[UIColor whiteColor]];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.label];
    self.label.transitionEffect = BBCyclingLabelTransitionEffectCrossFade;
    self.label.transitionDuration = 0.3;
    [self.label setText:@"Letar efter taxibilar" animated:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(firstAnimation)
                                   userInfo:nil
                                    repeats:NO];

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"loading" withExtension:@"gif"];
    self.gifView.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];

    [NSTimer scheduledTimerWithTimeInterval:0.2
                                     target:self
                                   selector:@selector(animateDot:)
                                   userInfo:self.dot1
                                    repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:0.25
                                     target:self
                                   selector:@selector(animateDot:)
                                   userInfo:self.dot2
                                    repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:0.3
                                     target:self
                                   selector:@selector(animateDot:)
                                   userInfo:self.dot3
                                    repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:0.35
                                     target:self
                                   selector:@selector(animateDot:)
                                   userInfo:self.dot4
                                    repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4
                                     target:self
                                   selector:@selector(animateDot:)
                                   userInfo:self.dot5
                                    repeats:NO];
}

- (void)animateDot:(NSTimer *)timer
{
    UIImageView *imageView = timer.userInfo;
    [UIView animateWithDuration:0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGAffineTransform move = CGAffineTransformMakeTranslation(160, 0);
                         imageView.transform = move;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)firstAnimation
{
    [self.label setText:@"Körning accepterad" animated:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.statusView.backgroundColor = [UIColor colorWithRed:0.9843 green:0.8118 blue:0.6275 alpha:1];
    }];
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(secondAnimation)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)secondAnimation
{
    [self.label setText:@"Taxi på väg" animated:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.statusView.backgroundColor = [UIColor colorWithRed:0.7059 green:0.7961 blue:0.7294 alpha:1];
    }];
    [self.cancelButton setTitle:@"AVBOKA" forState:UIControlStateNormal];
    self.navigationItem.title = @"Bokning genomförd";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

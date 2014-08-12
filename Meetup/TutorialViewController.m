//
//  TutorialViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-06-05.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "TutorialViewController.h"
#import "MainViewController.h"

@interface TutorialViewController ()
@property (strong, nonatomic) IBOutlet UILabel *topLabel;

@property (strong, nonatomic) IBOutlet UIView *firstView;
@property (strong, nonatomic) IBOutlet UIView *secondView;
@property (strong, nonatomic) IBOutlet UIView *thirdView;
@property (strong, nonatomic) IBOutlet UIView *fourthView;

@property (strong, nonatomic) IBOutlet UILabel *firstBold;
@property (strong, nonatomic) IBOutlet UILabel *secondBold;
@property (strong, nonatomic) IBOutlet UILabel *thirdBold;
@property (strong, nonatomic) IBOutlet UILabel *fourthBold;
@property (strong, nonatomic) IBOutlet UILabel *firstRegular;
@property (strong, nonatomic) IBOutlet UILabel *secondRegular;
@property (strong, nonatomic) IBOutlet UILabel *thirdRegular;
@property (strong, nonatomic) IBOutlet UILabel *fourthRegular;
@property (nonatomic, strong) MainViewController *mainViewController;
@property (strong, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.topLabel setFont:[UIFont fontWithName:@"OpenSans-Light" size:30]];
    [self.firstBold setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:17]];
    [self.secondBold setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:17]];
    [self.thirdBold setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:17]];
    [self.fourthBold setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:17]];
    [self.firstRegular setFont:[UIFont fontWithName:@"OpenSans-Light" size:14]];
    [self.secondRegular setFont:[UIFont fontWithName:@"OpenSans-Light" size:14]];
    [self.thirdRegular setFont:[UIFont fontWithName:@"OpenSans-Light" size:14]];
    [self.fourthRegular setFont:[UIFont fontWithName:@"OpenSans-Light" size:14]];
    [self.okButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];



    self.mainViewController = (MainViewController *)self.parentViewController;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"blurBackground.jpg"];
    imageView.alpha = 0.25;
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
}

- (void)beginAnimations {
    self.firstView.alpha = 0.0;
    self.secondView.alpha = 0.0;
    self.thirdView.alpha = 0.0;
    self.fourthView.alpha = 0.0;

    CGAffineTransform initialTranslation = CGAffineTransformMakeTranslation(-20, 0);
    self.firstView.transform = initialTranslation;
    self.secondView.transform = initialTranslation;
    self.thirdView.transform = initialTranslation;
    self.fourthView.transform = initialTranslation;
    
    CGAffineTransform firstTranslation = CGAffineTransformTranslate(self.firstView.transform, 20, 0);
    CGAffineTransform secondTranslation = CGAffineTransformTranslate(self.secondView.transform, 20, 0);
    CGAffineTransform thirdTranslation = CGAffineTransformTranslate(self.thirdView.transform, 20, 0);
    CGAffineTransform fourthTranslation = CGAffineTransformTranslate(self.fourthView.transform, 20, 0);

    [UIView animateKeyframesWithDuration:0.2 delay:0 options:0 animations:^{
        self.firstView.alpha = 1.0;
        self.firstView.transform = firstTranslation;
    } completion:^(BOOL finished) {}];
    
    [UIView animateKeyframesWithDuration:0.2 delay:0.1 options:0 animations:^{
        self.secondView.alpha = 1.0;
        self.secondView.transform = secondTranslation;
    } completion:^(BOOL finished) {}];
    
    [UIView animateKeyframesWithDuration:0.2 delay:0.2 options:0 animations:^{
        self.thirdView.alpha = 1.0;
        self.thirdView.transform = thirdTranslation;
    } completion:^(BOOL finished) {}];
    
    [UIView animateKeyframesWithDuration:0.2 delay:0.3 options:0 animations:^{
        self.fourthView.alpha = 1.0;
        self.fourthView.transform = fourthTranslation;
    } completion:^(BOOL finished) {}];
}

- (IBAction)clickedContinue:(UIButton *)sender {
    CGAffineTransform translation = CGAffineTransformMakeTranslation(0, 80);
    [UIView animateKeyframesWithDuration:0.2 delay:0 options:0 animations:^{
        sender.transform = translation;
    } completion:^(BOOL finished) {}];
    MainViewController *mainViewController = (MainViewController *)self.parentViewController;
    [mainViewController hideTutorialView];
}

@end

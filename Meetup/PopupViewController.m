//
//  PopupViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-08-29.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "MainViewController.h"
#import "PopupViewController.h"

@interface PopupViewController ()
@property(strong, nonatomic) IBOutlet UITextField *messageTextField;
@property(strong, nonatomic) IBOutlet UILabel *fromTextField;
@property(strong, nonatomic) IBOutlet UILabel *destinationTextField;

@end

@implementation PopupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setOrigin:(NSString *)origin andDestination:(NSString *)destination {
    self.fromTextField.text = origin;
    self.destinationTextField.text = destination;
}

- (IBAction)clickedClose {
    MainViewController *mainViewController =
        (MainViewController *)self.parentViewController;
    [self viewWillDisappear:YES];
    [mainViewController hidePopupView];
}

- (IBAction)clickedMakeReservation {
    MainViewController *mainViewController =
        (MainViewController *)self.parentViewController;
    [self viewWillDisappear:YES];
    if (![self.messageTextField.text isEqualToString:@""])
        [mainViewController
            makeConfirmationWithMessage:self.messageTextField.text];
    else
        [mainViewController makeConfirmationWithMessage:@""];
    [mainViewController hidePopupView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

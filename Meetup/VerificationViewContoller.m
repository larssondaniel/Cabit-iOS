//
//  TutorialViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-06-05.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "VerificationViewController.h"
#import "MainViewController.h"
#import "APLKeyboardControls.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "BookingHTTPClient.h"
#import "NBAsYouTypeFormatter.h"
#import "SettingsHelper.h"

#define IS_IPHONE_5                                                           \
    (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < \
     DBL_EPSILON)

@interface VerificationViewController ()

@property(nonatomic, strong) MainViewController *mainViewController;
@property(strong, nonatomic) IBOutlet UILabel *inputBox1;
@property(strong, nonatomic) IBOutlet UILabel *inputBox2;
@property(strong, nonatomic) IBOutlet UILabel *inputBox3;
@property(strong, nonatomic) IBOutlet UILabel *inputBox4;
@property(strong, nonatomic) IBOutlet UITextField *invisInputField;
@property(strong, nonatomic) NSArray *inputBoxes;
@property(strong, nonatomic) IBOutlet UIView *uiContainer;
@property(strong, nonatomic) IBOutlet UIView *rightContainer;
@property(strong, nonatomic) APLKeyboardControls *keyboardControls;
@property(strong, nonatomic) IBOutlet UITextField *nameTF;
@property(strong, nonatomic) IBOutlet UITextField *phoneTF;
@property(nonatomic) bool forceKeyboard;
@property(strong, nonatomic) IBOutlet UILabel *phoneLBL;
@property(strong, nonatomic) IBOutlet UILabel *messageLBL;
@property(nonatomic, strong) NSString *verificationCode;
@property(nonatomic, strong) NSString *currentPhoneNumber;

@property(nonatomic, strong) NBAsYouTypeFormatter *numberFormatter;
@property(strong, nonatomic) IBOutlet UILabel *secondMessageLBL;
@property(strong, nonatomic) IBOutlet UILabel *nameLBL;
@property(strong, nonatomic) IBOutlet UIButton *sendBTN;
@property(strong, nonatomic) IBOutlet UILabel *disclaimerLBL;
@property(strong, nonatomic) IBOutlet UIButton *verifyLaterBTN;
@property(strong, nonatomic) IBOutlet UILabel *firstLBL;
@property(strong, nonatomic) IBOutlet UILabel *secondLBL;
@property(strong, nonatomic) IBOutlet UIButton *editPhoneBTN;

@end

@implementation VerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.messageLBL setFont:[UIFont fontWithName:@"OpenSans-Light" size:30]];
    [self.secondMessageLBL setFont:[UIFont fontWithName:@"OpenSans" size:11]];
    [self.nameLBL setFont:[UIFont fontWithName:@"OpenSans" size:11]];
    [self.nameTF setFont:[UIFont fontWithName:@"OpenSans" size:15]];
    [self.phoneLBL setFont:[UIFont fontWithName:@"OpenSans" size:11]];
    [self.phoneTF setFont:[UIFont fontWithName:@"OpenSans" size:15]];
    [self.sendBTN.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    [self.disclaimerLBL setFont:[UIFont fontWithName:@"OpenSans" size:11]];
    [self.nameLBL setFont:[UIFont fontWithName:@"OpenSans" size:11]];
    [self.inputBox1 setFont:[UIFont fontWithName:@"OpenSans" size:40]];
    [self.inputBox2 setFont:[UIFont fontWithName:@"OpenSans" size:40]];
    [self.inputBox3 setFont:[UIFont fontWithName:@"OpenSans" size:40]];
    [self.inputBox4 setFont:[UIFont fontWithName:@"OpenSans" size:40]];
    [self.firstLBL setFont:[UIFont fontWithName:@"OpenSans" size:13]];
    [self.secondLBL setFont:[UIFont fontWithName:@"OpenSans" size:13]];
    [self.phoneLBL setFont:[UIFont fontWithName:@"OpenSans" size:20]];
    [self.editPhoneBTN.titleLabel
        setFont:[UIFont fontWithName:@"OpenSans" size:13]];

    self.mainViewController = (MainViewController *)self.parentViewController;

    UIImageView *imageView =
        [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"blurBackground.jpg"];
    imageView.alpha = 0.25;
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];

    NSArray *inputChain = @[ self.nameTF, self.phoneTF ];
    self.keyboardControls =
        [[APLKeyboardControls alloc] initWithInputFields:inputChain];
    self.keyboardControls.hasPreviousNext = YES;
    [self.keyboardControls.doneButton setTitle:@"Ok"];

    self.phoneTF.delegate = self;
    self.invisInputField.delegate = self;
    self.inputBoxes =
        @[ self.inputBox1, self.inputBox2, self.inputBox3, self.inputBox4 ];

    //[self.nameTF becomeFirstResponder];
    self.numberFormatter =
        [[NBAsYouTypeFormatter alloc] initWithRegionCode:@"SE"];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:UIKeyboardWillShowNotification
                object:nil];
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:UIKeyboardWillHideNotification
                object:nil];
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    if ([textField isEqual:self.invisInputField]) {
        if (range.location > 3) return NO;

        UILabel *label = [self.inputBoxes objectAtIndex:range.location];

        if (range.length == 0)
            label.text = string;
        else
            label.text = @"-";

        // All digits entered
        if (range.location == 3) {
            NSString *enteredCode = [NSString
                stringWithFormat:@"%@%@%@%@", self.inputBox1.text,
                                 self.inputBox2.text, self.inputBox3.text,
                                 self.inputBox4.text];
            if ([enteredCode isEqualToString:self.verificationCode]) {
                [[SettingsHelper sharedSettingsHelper]
                    storeName:self.nameTF.text];
                [[SettingsHelper sharedSettingsHelper]
                    storePhoneNumber:self.phoneTF.text];
                MainViewController *mainViewController =
                    (MainViewController *)self.parentViewController;
                [self viewWillDisappear:YES];
                [mainViewController hideVerificationView];
            }
            return YES;
        }
    } else if ([textField isEqual:self.phoneTF]) {
        if (range.location > 12) return NO;
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UITextRange *newRange = [textField textRangeFromPosition:0 toPosition:0];
    [textField setSelectedTextRange:newRange];
}

- (void)saveCredentials {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.nameTF.text forKey:@"name"];
    [defaults setObject:self.phoneTF.text forKey:@"phoneNumber"];
    [defaults synchronize];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.forceKeyboard) [self.view endEditing:YES];
}

- (IBAction)verifyLater {
    MainViewController *mainViewController =
        (MainViewController *)self.parentViewController;
    [mainViewController hideVerificationView];
}

- (void)setMessage:(NSString *)message {
    self.messageLBL.text = message;
}

- (IBAction)clickedSend {
    [[BookingHTTPClient sharedBookingHTTPClient] setDelegate:self];

    self.phoneLBL.text = self.phoneTF.text;
    [[BookingHTTPClient sharedBookingHTTPClient]
        getPhoneNumberVerificationWithNumber:self.phoneTF.text];
    CGAffineTransform containerTranslation =
        CGAffineTransformTranslate(self.uiContainer.transform, -320, 0);
    CGAffineTransform rightContainerTranslation =
        CGAffineTransformTranslate(self.rightContainer.transform, -320, 0);

    [UIView animateKeyframesWithDuration:0.2
        delay:0
        options:0
        animations:^{
            self.uiContainer.transform = containerTranslation;
            self.rightContainer.transform = rightContainerTranslation;
        }
        completion:^(BOOL finished) {
            CGAffineTransform box1Translation =
                CGAffineTransformTranslate(self.inputBox1.transform, -320, 0);
            CGAffineTransform box2Translation =
                CGAffineTransformTranslate(self.inputBox2.transform, -320, 0);
            CGAffineTransform box3Translation =
                CGAffineTransformTranslate(self.inputBox3.transform, -320, 0);
            CGAffineTransform box4Translation =
                CGAffineTransformTranslate(self.inputBox4.transform, -320, 0);
            [UIView animateKeyframesWithDuration:0.2
                delay:0.1
                options:0
                animations:^{ self.inputBox1.transform = box1Translation; }
                completion:^(BOOL finished) {}];
            [UIView animateKeyframesWithDuration:0.2
                delay:0.2
                options:0
                animations:^{ self.inputBox2.transform = box2Translation; }
                completion:^(BOOL finished) {}];
            [UIView animateKeyframesWithDuration:0.2
                delay:0.3
                options:0
                animations:^{ self.inputBox3.transform = box3Translation; }
                completion:^(BOOL finished) {}];
            [UIView animateKeyframesWithDuration:0.2
                delay:0.4
                options:0
                animations:^{ self.inputBox4.transform = box4Translation; }
                completion:^(BOOL finished) {
                    CGAffineTransform translation;
                    if (IS_IPHONE_5)
                        translation = CGAffineTransformTranslate(
                            self.uiContainer.transform, 0, 20);
                    else
                        translation = CGAffineTransformTranslate(
                            self.uiContainer.transform, 0, 100);

                    [UIView animateKeyframesWithDuration:0.1
                        delay:0
                        options:0
                        animations:^{
                            self.uiContainer.transform = translation;
                        }
                        completion:^(BOOL finished) {}];
                }];
        }];

    [self.invisInputField becomeFirstResponder];
    self.forceKeyboard = YES;
}

- (void)setFontFamily:(NSString *)fontFamily
              forView:(UIView *)view
          andSubViews:(BOOL)isSubViews {
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *lbl = (UILabel *)view;
        [lbl setFont:[UIFont fontWithName:fontFamily
                                     size:[[lbl font] pointSize]]];
    }

    if (isSubViews) {
        for (UIView *sview in view.subviews) {
            [self setFontFamily:fontFamily forView:sview andSubViews:YES];
        }
    }
}

#pragma mark - keyboard movements

- (void)keyboardWillShow:(NSNotification *)notification {
    CGAffineTransform translation;
    if (IS_IPHONE_5)
        translation =
            CGAffineTransformTranslate(self.uiContainer.transform, 0, -20);
    else
        translation =
            CGAffineTransformTranslate(self.uiContainer.transform, 0, -100);
    [UIView animateKeyframesWithDuration:0.2
        delay:0
        options:0
        animations:^{ self.uiContainer.transform = translation; }
        completion:^(BOOL finished) {}];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGAffineTransform translation;
    if (IS_IPHONE_5)
        translation =
            CGAffineTransformTranslate(self.uiContainer.transform, 0, 20);
    else
        translation =
            CGAffineTransformTranslate(self.uiContainer.transform, 0, 100);

    [UIView animateKeyframesWithDuration:0.2
        delay:0
        options:0
        animations:^{ self.uiContainer.transform = translation; }
        completion:^(BOOL finished) {}];
}

#pragma mark - booking http client delegate

- (void)bookingHTTPClient:(BookingHTTPClient *)client
    didRecieveVerificationCode:(NSString *)code {
    self.verificationCode = code;
}

- (IBAction)formatPhoneNumber:(id)sender forEvent:(UIEvent *)event {
    if (self.phoneTF.text.length > self.currentPhoneNumber.length) {
        [self.phoneTF
            setText:[self.numberFormatter
                        inputDigit:[self.phoneTF.text
                                       substringFromIndex:
                                           self.phoneTF.text.length - 1]]];
    } else {
        [self.phoneTF setText:[self.numberFormatter removeLastDigit]];
    }
    self.currentPhoneNumber = self.phoneTF.text;
}

- (IBAction)changePhoneNumber {
    CGAffineTransform containerTranslation =
        CGAffineTransformTranslate(self.uiContainer.transform, 320, 0);
    CGAffineTransform rightContainerTranslation =
        CGAffineTransformTranslate(self.rightContainer.transform, 320, 0);

    CGAffineTransform box1Translation =
        CGAffineTransformTranslate(self.inputBox1.transform, 320, 0);
    CGAffineTransform box2Translation =
        CGAffineTransformTranslate(self.inputBox2.transform, 320, 0);
    CGAffineTransform box3Translation =
        CGAffineTransformTranslate(self.inputBox3.transform, 320, 0);
    CGAffineTransform box4Translation =
        CGAffineTransformTranslate(self.inputBox4.transform, 320, 0);
    [UIView animateKeyframesWithDuration:0.2
        delay:0.1
        options:0
        animations:^{ self.inputBox4.transform = box4Translation; }
        completion:^(BOOL finished) {}];
    [UIView animateKeyframesWithDuration:0.2
        delay:0.2
        options:0
        animations:^{ self.inputBox3.transform = box3Translation; }
        completion:^(BOOL finished) {}];
    [UIView animateKeyframesWithDuration:0.2
        delay:0.3
        options:0
        animations:^{ self.inputBox2.transform = box2Translation; }
        completion:^(BOOL finished) {}];
    [UIView animateKeyframesWithDuration:0.2
        delay:0.4
        options:0
        animations:^{ self.inputBox1.transform = box1Translation; }
        completion:^(BOOL finished) {
            self.phoneLBL.text = @"";
            [UIView animateKeyframesWithDuration:0.2
                delay:0
                options:0
                animations:^{
                    self.uiContainer.transform = containerTranslation;
                    self.rightContainer.transform = rightContainerTranslation;
                }
                completion:^(BOOL finished) {
                    [self.phoneTF becomeFirstResponder];
                    self.forceKeyboard = YES;
                }];
        }];
}

@end

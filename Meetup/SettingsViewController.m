//
//  SettingsViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-03-02.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsHelper.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load credentials
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.nameTextField setText:[defaults objectForKey:@"name"]];
    [self.phoneTextField setText:[defaults objectForKey:@"phoneNumber"]];
    NSLog(@"Reading name: %@", [defaults objectForKey:@"name"]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 4;
        default:
            return 0;
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[SettingsHelper sharedSettingsHelper] storeName:self.nameTextField.text];
    [[SettingsHelper sharedSettingsHelper] storePhoneNumber:self.phoneTextField.text];
    [super viewWillDisappear:animated];
}

@end

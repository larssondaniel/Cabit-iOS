//
//  SettingsViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-03-02.
//  Copyright (c) 2014 Cabit. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsHelper.h"
#import "MainViewController.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *homeAddressTextField;
@property (strong, nonatomic) IBOutlet UILabel *pushLabel;
@property (strong, nonatomic) IBOutlet UILabel *pushFooterLabel;
@property (strong, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"blurBackground.jpg"];
    imageView.alpha = 0.25;
    [self.view addSubview:imageView];
    
    // Load credentials
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.nameTextField setText:[defaults objectForKey:@"name"]];
    [self.phoneTextField setText:[defaults objectForKey:@"phoneNumber"]];
    
    NSData *hej = [defaults objectForKey:@"homeAddress"];
    NSString *strData = [[NSString alloc]initWithData:hej encoding:NSUTF8StringEncoding];
    NSLog(@"%@", strData);
    
    @try {
        NSLog(@"%@", [NSKeyedUnarchiver unarchiveObjectWithData:hej]);
    }
    @catch (NSException *exception) {
        NSLog(@"Went wrong");
    }
    @finally {
        
    }
    
    //if (hej != nil)
        //[self.homeAddressTextField setText:[NSKeyedUnarchiver unarchiveObjectWithData:hej]];
    
    [self.nameTextField setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    [self.phoneTextField setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    [self.homeAddressTextField setFont:[UIFont fontWithName:@"OpenSans" size:16]];

    [self.pushLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    [self.pushFooterLabel setFont:[UIFont fontWithName:@"OpenSans" size:12]];
    [self.okButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    
    [self.nameTextField setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [self.phoneTextField setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [self.homeAddressTextField setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.4];
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
            return 1;
        default:
            return 0;
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"View will dissappear");
    [[SettingsHelper sharedSettingsHelper] storeName:self.nameTextField.text];
    [[SettingsHelper sharedSettingsHelper] storePhoneNumber:self.phoneTextField.text];
    if (self.homeAddressTextField.text) {
        NSLog(@"Got here");
        [self issueLocalSearchLookup:self.homeAddressTextField.text];
    }
    
    [super viewWillDisappear:animated];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    if (section == 0)
        label.frame = CGRectMake(20, 24, tableView.bounds.size.width, 20);
    else
        label.frame = CGRectMake(20, 8, tableView.bounds.size.width, 20);
    //label.frame = CGRectMake(20, 18, tableView.bounds.size.width, 20);

    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"OpenSans" size:17];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

- (IBAction)clickedOk {
    MainViewController *mainViewController = (MainViewController *)self.parentViewController;
    [self viewWillDisappear:YES];
    [mainViewController hideSettingsView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)issueLocalSearchLookup:(NSString *)searchString
{
    SPGooglePlacesAutocompleteQuery *query = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:@"AIzaSyDxTyIXSAktcdcT8_l9AdjiUem8--zxw2Y"];
    query.input = searchString; // search key word
    query.location = self.userLocation;  // user's current location
    query.radius = 100.0;   // search addresses close to user
    query.language = @"se"; // optional
    query.types = SPPlaceTypeGeocode; // Only return geocoding (address) results.
    NSLog(@"Still in the game");
    [query fetchPlaces:^(NSArray *places, NSError *error) {
        NSLog(@"First place goes to %@", places.firstObject);
        [[SettingsHelper sharedSettingsHelper] storeHomeAddress:places.firstObject];
    }];
}

@end

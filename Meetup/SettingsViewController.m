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
    NSLog(@"Reading name: %@", [defaults objectForKey:@"name"]);
    
    
    [self.nameTextField setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    [self.phoneTextField setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    [self.pushLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    [self.pushFooterLabel setFont:[UIFont fontWithName:@"OpenSans" size:12]];
    [self.okButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    
    [self.nameTextField setValue:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255.0/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    [self.phoneTextField setValue:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255.0/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.4];
    //self.tableView.rowHeight = 45;

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
    [[SettingsHelper sharedSettingsHelper] storeName:self.nameTextField.text];
    [[SettingsHelper sharedSettingsHelper] storePhoneNumber:self.phoneTextField.text];
    [super viewWillDisappear:animated];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 18, tableView.bounds.size.width, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    //label.shadowColor = [UIColor colorWithWhite:0 alpha:0.44];
    //label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont fontWithName:@"OpenSans" size:17];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
    
    /*
    float width = tableView.bounds.size.width;
    int fontSize = 18;
    int padding = 10;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, fontSize)];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    view.userInteractionEnabled = YES;
    view.tag = section;
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(padding, 2, width - padding, fontSize)];
    label.text = sectionTitle;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    //label.shadowColor = [UIColor darkGrayColor];
    //label.shadowOffset = CGSizeMake(0,1);
    label.font = [UIFont fontWithName:@"OpenSans" size:fontSize];
    
    [view addSubview:label];
    
    return view;
     */
}

- (IBAction)clickedOk {
    MainViewController *mainViewController = (MainViewController *)self.parentViewController;
    [mainViewController hideSettingsView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

//
//  SettingsViewController.m
//  Meetup
//
//  Created by Daniel Larsson on 2014-02-14.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "SettingsViewController.h"
#import "PBFlatRoundedImageView.h"
#import <QuartzCore/QuartzCore.h>


@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 6;
        default:
            return 0;
            break;
    }
}

-(void)configureCell:(PBFlatGroupedStyleCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSString *text = @"";
    
    switch (section) {
        case 0:
            text = @"Storbil (4+ personer)";
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    text = @"Taxi Göteborg";
                    break;
                case 1:
                    text = @"Minitaxi";
                    break;
                case 2:
                    text = @"Taxi 020";
                    break;
                case 3:
                    text = @"Taxi Kurir";
                    break;
                case 4:
                    text = @"Easy Cab";
                    break;
                case 5:
                    text = @"City Cab";
                    break;
            }
    }
    
    [cell.textLabel setText:text];
    
    //[cell setIconImage:[[self exampleIcons] objectAtIndex:index]];
    [cell setCellAccessoryView:[self exampleAccessoryViewForIndexPath:indexPath]];
    
    if (section == 2) {
        
        switch (indexPath.row) {
            case 0: {
                [cell setIconImageView:[PBFlatRoundedImageView contactImageViewWithImage:[UIImage imageNamed:@"js"]]];
                break;
            }
            case 1: {
                
                [cell setIconImageView:[PBFlatRoundedImageView contactImageViewWithImage:[UIImage imageNamed:@"tl"]]];
                break;
            }
            case 2: {
                
                [cell setIconImageView:[PBFlatRoundedImageView contactImageViewWithImage:[UIImage imageNamed:@"cn"]]];
                break;
            }
            default:
                break;
        }
        
    }
    
}
 
- (UIView *)exampleAccessoryViewForIndexPath:(NSIndexPath *)indexPath {
    
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];

    [mySwitch setBackgroundColor:[UIColor clearColor]];
    //mySwitch.onTintColor = [UIColor colorWithRed:67 green:67 blue:67 alpha:1];
    [mySwitch setOnTintColor:[UIColor colorWithHue:0 saturation:0 brightness:0.26 alpha:1]];

    /*
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setTextColor:[UIColor darkGrayColor]];
    [label setFont:[[[PBFlatSettings sharedInstance] font] fontWithSize:12.0f]];
    [label setBackgroundColor:[UIColor clearColor]];
     */
    
    switch (indexPath.section) {
        case 0:
            [mySwitch setOn:NO animated:YES];
            return mySwitch;
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [mySwitch setOn:YES animated:YES];
                    return mySwitch;
                    break;
                case 1:
                    [mySwitch setOn:YES animated:YES];
                    return mySwitch;
                    break;
                case 2:
                    [mySwitch setOn:NO animated:YES];
                    return mySwitch;
                    break;
                case 3:
                    [mySwitch setOn:YES animated:YES];
                    return mySwitch;
                    break;
                case 4:
                    [mySwitch setOn:NO animated:YES];
                    return mySwitch;
                    break;
                case 5:
                    [mySwitch setOn:NO animated:YES];
                    return mySwitch;
                    break;
            }
    }
    return nil;
}

@end

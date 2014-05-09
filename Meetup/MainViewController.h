//
//  MainViewController.h
//  Cabit
//
//  Created by Daniel Larsson on 2013-11-18.
//  Copyright (c) 2013 Cabit. All rights reserved.
//

#import "SearchPickupViewController.h"
#import "SearchDestinationViewController.h"
#import "CredentialsViewController.h"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MainViewController : UIViewController <MKMapViewDelegate, UIToolbarDelegate, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (void)didFinishEnteringCredentials;
- (void)hideSettingsView;

@end

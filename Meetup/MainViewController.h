//
//  MainViewController.h
//  Cabit
//
//  Created by Daniel Larsson on 2013-11-18.
//  Copyright (c) 2013 Cabit. All rights reserved.
//

#import "SearchPickupViewController.h"
#import "SearchDestinationViewController.h"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MainViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, UIToolbarDelegate, SearchPickupDelegate, SearchDestinationDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UIButton *locateButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *locateIndicator;

@end

//
//  ViewController.h
//  Meetup
//
//  Created by Daniel Larsson on 2013-11-18.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import "SearchLocationViewController.h"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, UIToolbarDelegate, SearchLocationDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UIButton *locateButton;
@property (strong, nonatomic) IBOutlet UIView *destionationView;
@property (strong, nonatomic) IBOutlet UIButton *destinationButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *locateIndicator;

@end

//
//  ConfirmationViewController.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-01-26.
//  Copyright (c) 2014 Cabit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "ADDropDownMenuView.h"
#import "DialController.h"
#import "PickupAnnotation.h"
#import "BookingHTTPClient.h"
#import "SPGooglePlacesAutocompletePlace.h"

@interface ConfirmationViewController : UIViewController <ADDropDownMenuDelegate, MKMapViewDelegate, BookingHTTPClientDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKMapItem *pickup;
@property (nonatomic, strong) MKMapItem *destination;
@property (nonatomic, strong) MKPointAnnotation *destinationAnnotation;
@property (nonatomic, strong) PickupAnnotation *pickupAnnotation;

@end

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

@interface ConfirmationViewController : UIViewController <ADDropDownMenuDelegate, MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKMapItem *pickupMapItem;
@property (nonatomic, strong) MKMapItem *destinationMapItem;
@property (nonatomic, strong) MKPointAnnotation *destinationAnnotation;
@property (nonatomic, strong) MKPointAnnotation *pickupAnnotation;

@end

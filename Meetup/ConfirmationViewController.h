//
//  ConfirmationViewController.h
//  Meetup
//
//  Created by Daniel Larsson on 2014-01-26.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "ADDropDownMenuView.h"

@interface ConfirmationViewController : UIViewController <ADDropDownMenuDelegate, MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

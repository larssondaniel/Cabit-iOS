//
//  MainViewController.h
//  Cabit
//
//  Created by Daniel Larsson on 2013-11-18.
//  Copyright (c) 2013 Cabit. All rights reserved.
//

#import "BookingHTTPClient.h"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MainViewController
    : UIViewController<MKMapViewDelegate, UIToolbarDelegate,
                       BookingHTTPClientDelegate>

@property(strong, nonatomic) IBOutlet MKMapView *mapView;
@property(strong, nonatomic) UISearchDisplayController *searchController;

- (void)showSearchView;
- (void)hideSearchView;
- (void)hideSettingsView;
- (void)hideTutorialView;
- (void)hideVerificationView;
- (void)hideConnectionLossView;
- (void)showConnectionLossView;
- (void)didFinishSearchWithAdress:(MKMapItem *)mapItem;

@end

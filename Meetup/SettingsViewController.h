//
//  SettingsViewController.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-03-02.
//  Copyright (c) 2014 Cabit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPGooglePlacesAutocompleteQuery.h"
#import <MapKit/MapKit.h>

@interface SettingsViewController : UITableViewController<UITextFieldDelegate>

@property(nonatomic) CLLocationCoordinate2D userLocation;

@end

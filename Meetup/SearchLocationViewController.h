//
//  SearchLocationViewController.h
//  Meetup
//
//  Created by Daniel Larsson on 2013-12-04.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class SearchLocationViewController;

@protocol SearchLocationDelegate <NSObject>
- (void)addItemViewController:(SearchLocationViewController *)controller didFinishEnteringItem:(MKMapItem *)item;
@end

@interface SearchLocationViewController : UIViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <SearchLocationDelegate> delegate;
@property (strong, nonatomic) CLLocation *location;

@end

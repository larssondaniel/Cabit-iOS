//
//  SearchPickupViewController.h
//  Meetup
//
//  Created by Daniel Larsson on 2013-12-04.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class SearchPickupViewController;

@protocol SearchPickupDelegate <NSObject>
- (void)addItemViewController:(SearchPickupViewController *)controller didFinishEnteringPickupLocation:(MKMapItem *)item;
@end

@interface SearchPickupViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <SearchPickupDelegate> delegate;
@property (strong, nonatomic) CLLocation *location;

@end

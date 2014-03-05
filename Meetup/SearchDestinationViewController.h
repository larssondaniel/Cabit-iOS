//
//  SearchDestinationViewController.h
//  Cabit
//
//  Created by Daniel Larsson on 2013-12-28.
//  Copyright (c) 2013 Cabit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class SearchDestinationViewController;

@protocol SearchDestinationDelegate <NSObject>
- (void)addItemViewController:(SearchDestinationViewController *)controller didFinishEnteringDestination:(MKMapItem *)item;
@end

@interface SearchDestinationViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <SearchDestinationDelegate> delegate;
@property (strong, nonatomic) CLLocation *location;

@end

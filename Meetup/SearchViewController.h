//
//  SearchViewController.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-05-10.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SearchViewController
    : UIViewController<CLLocationManagerDelegate, UISearchBarDelegate,
                       UISearchDisplayDelegate>

@property(nonatomic, strong) NSMutableArray *places;

- (void)setActiveWithLabel:(NSString *)label
           andUserLocation:(CLLocationCoordinate2D)location;

@end

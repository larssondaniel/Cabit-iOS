//
//  RouteAnnotation.h
//  Meetup
//
//  Created by Daniel Larsson on 2014-01-08.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RouteAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

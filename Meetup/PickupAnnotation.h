//
//  PickupAnnotation.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-04-23.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PickupAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location;

@end

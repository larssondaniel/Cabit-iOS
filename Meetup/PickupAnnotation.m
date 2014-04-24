//
//  PickupAnnotation.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-04-23.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "PickupAnnotation.h"

@implementation PickupAnnotation

- (id)initWithCoordinates:(CLLocationCoordinate2D)location
{
    self = [super init];
    if (self != nil) {
        self.coordinate = location;
    }
    return self;
}

@end

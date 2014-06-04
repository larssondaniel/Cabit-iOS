//
//  MapAnnotation.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-05-26.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

@synthesize coordinate=_coordinate;
@synthesize typeOfAnnotation;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    
    if (self != nil)
    {
        _coordinate = coordinate;
    }
    
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

@end

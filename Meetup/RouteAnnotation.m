//
//  RouteAnnotation.m
//  Meetup
//
//  Created by Daniel Larsson on 2014-01-08.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "RouteAnnotation.h"

@implementation RouteAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        self.coordinate = coordinate;
    }
    return self;
}


@end

//
//  MapTileOverlay.m
//  Meetup
//
//  Created by Daniel Larsson on 2013-11-28.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import "MapTileOverlay.h"

#import <MapKit/MapKit.h>

@implementation MapTileOverlay

@synthesize boundingMapRect;
@synthesize coordinate;

-(id)init {
    self = [super init];
    if(self) {
        boundingMapRect = MKMapRectWorld;

        coordinate = MKCoordinateForMapPoint(MKMapPointMake(boundingMapRect.origin.x + boundingMapRect.size.width/2, boundingMapRect.origin.y + boundingMapRect.size.height/2));
    }
    return self;
}
@end

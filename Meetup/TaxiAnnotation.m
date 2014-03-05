//
//  TaxiAnnotation.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-02-18.
//  Copyright (c) 2014 Cabit. All rights reserved.
//

#import "TaxiAnnotation.h"

@implementation TaxiAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        self.coordinate = coordinate;
    }
    return self;
}

- (MKMapItem*)mapItem {
    MKMapItem *mapItem = [[MKMapItem alloc] init];
    mapItem.name = self.title;
    
    return mapItem;
}

@end

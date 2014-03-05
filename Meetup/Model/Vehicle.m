//
//  TaxiGoteborgVehicle.m
//  Cabit
//
//  Created by Daniel Larsson on 2013-11-23.
//  Copyright (c) 2013 Cabit. All rights reserved.
//

#import "Vehicle.h"

@implementation Vehicle

@synthesize title;

- (id)initWithCarID:(NSString *)vehicleID andCoordinate:(CLLocationCoordinate2D)coordinate;
 {
    if ((self = [super init])) {
        self.vehicleID = vehicleID;
        self.coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return @"";
}

- (NSString *)subtitle {
    return @"Available: ";
}

//- (CLLocationCoordinate2D)coordinate {
//    return self.coordinate;
//}

- (MKMapItem*)mapItem {
    MKMapItem *mapItem = [[MKMapItem alloc] init];
    mapItem.name = self.title;
    
    return mapItem;
}

@end

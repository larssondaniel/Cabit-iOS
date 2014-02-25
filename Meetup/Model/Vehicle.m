//
//  TaxiGoteborgVehicle.m
//  Meetup
//
//  Created by Daniel Larsson on 2013-11-23.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import "Vehicle.h"

@implementation Vehicle

@synthesize title;

- (id)initWithCompany:(Company *)company andCarID:(NSString *)vehicleID andCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        self.company = company;
        self.vehicleID = vehicleID;
        self.coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return self.company.name;
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

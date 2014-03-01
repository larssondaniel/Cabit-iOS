//
//  TaxiGoteborgVehicle.h
//  Meetup
//
//  Created by Daniel Larsson on 2013-11-23.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Vehicle : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSInteger *seats;
@property (nonatomic) NSString *vehicleID;

- (id)initWithCarID:(NSString *)vehicleID andCoordinate:(CLLocationCoordinate2D)coordinate;

@end

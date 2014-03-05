//
//  TaxiAnnotation.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-02-18.
//  Copyright (c) 2014 Cabit. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface TaxiAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

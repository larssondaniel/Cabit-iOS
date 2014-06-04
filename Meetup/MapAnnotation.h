//
//  MapAnnotation.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-05-26.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define PICKUP_ANNOTATION @"PICKUP_ANNOTATION"
#define DESTINATION_ANNOTATION @"DESTINATION_ANNOTATION"

@interface MapAnnotation : NSObject <MKAnnotation> {
    
    CLLocationCoordinate2D _coordinate;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@property(nonatomic, strong) NSString *typeOfAnnotation;

@end

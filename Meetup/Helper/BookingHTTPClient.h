//
//  BookingHTTPClient.h
//  Cabit
//
//  Created by Daniel Larsson on 2014-05-06.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "AFHTTPSessionManager.h"

#import <MapKit/MapKit.h>

@protocol BookingHTTPClientDelegate;

@interface BookingHTTPClient : AFHTTPSessionManager
@property (nonatomic, weak) id<BookingHTTPClientDelegate>delegate;

+ (BookingHTTPClient *)sharedBookingHTTPClient;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)requestReservationWithOrigin:(CLLocation *)origin andDestination:(CLLocation *)destination;

@end

@protocol BookingHTTPClientDelegate <NSObject>
@optional
-(void)bookingHTTPClient:(BookingHTTPClient *)client didBeginReservation:(id)reservation;
-(void)bookingHTTPClient:(BookingHTTPClient *)client didFailWithError:(NSError *)error;
@end
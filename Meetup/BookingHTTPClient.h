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
@property(nonatomic, weak) id<BookingHTTPClientDelegate> delegate;

+ (BookingHTTPClient *)sharedBookingHTTPClient;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)requestReservationWithParameters:(NSMutableDictionary *)parameters;
- (void)getPhoneNumberVerificationWithNumber:(NSString *)number;
- (void)getPriceFrom:(CLLocationCoordinate2D)origin
                  to:(CLLocationCoordinate2D)destination;
- (void)getStatusForReservation:(NSString *)reservationId;
- (void)validateAddress:(MKPlacemark *)address isOrigin:(BOOL)isOrigin;

@end

@protocol BookingHTTPClientDelegate<NSObject>
@optional
- (void)bookingHTTPClient:(BookingHTTPClient *)client
      didBeginReservation:(id)reservation;
- (void)bookingHTTPClient:(BookingHTTPClient *)client
         didFailWithError:(NSError *)error;
- (void)bookingHTTPClient:(BookingHTTPClient *)client
    didRecieveVerificationCode:(NSString *)code;
- (void)bookingHTTPClient:(BookingHTTPClient *)client
          didReceivePrice:(NSString *)price;
- (void)bookingHTTPClient:(BookingHTTPClient *)client
          didUpdateStatus:(NSString *)status
              withVehicle:(NSString *)vehicle;
- (void)bookingHTTPClient:(BookingHTTPClient *)client
         didVerifyAddress:(CLLocationCoordinate2D)address
              withResults:(BOOL)validity;
- (void)bookingHTTPClient:(BookingHTTPClient *)client
       didValidateAddress:(MKPlacemark *)address
               withResult:(NSString *)result
                forOrigin:(BOOL)origin;

@end
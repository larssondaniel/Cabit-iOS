//
//  BookingHTTPClient.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-05-06.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "BookingHTTPClient.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "CocoaLumberjack.h"

// Debug levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation BookingHTTPClient

+ (BookingHTTPClient *)sharedBookingHTTPClient {
    static BookingHTTPClient *_sharedBookingHTTPClient = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedBookingHTTPClient =
            [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    });

    return _sharedBookingHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];

    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)requestReservationWithParameters:(NSMutableDictionary *)parameters {
    NSLog(@"Parameters are %@", parameters);
    [self POST:@"bookings"
        parameters:parameters
        success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([self.delegate
                    respondsToSelector:@selector(bookingHTTPClient:
                                               didBeginReservation:)]) {
                NSLog(@"Request finished");
                [self.delegate
                      bookingHTTPClient:self
                    didBeginReservation:[responseObject valueForKey:@"_id"]];
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Request with error: \n\n%@", error);
            if ([self.delegate
                    respondsToSelector:@selector(bookingHTTPClient:
                                                  didFailWithError:)]) {
                [self.delegate bookingHTTPClient:self didFailWithError:error];
            }
        }];
}

- (void)getPhoneNumberVerificationWithNumber:(NSString *)number {
    if ([number hasPrefix:@"0"]) number = [number substringFromIndex:1];

    number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];

    [self
        GET:[NSString stringWithFormat:@"%@validate/46%@", self.baseURL, number]
        parameters:nil
        success:^(NSURLSessionDataTask *task, id responseObject) {
            DDLogInfo(@"Received verification code: %@",
                      [responseObject valueForKey:@"code"]);
            NSString *code = [responseObject valueForKey:@"code"];
            if ([self.delegate
                    respondsToSelector:@selector(bookingHTTPClient:
                                           didRecieveVerificationCode:)]) {
                [self.delegate bookingHTTPClient:self
                      didRecieveVerificationCode:code];
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Failed to post with task %@ and failure %@", task, error);
        }];
}

- (void)getStatusForReservation:(NSString *)reservationId {
    NSString *lol = [NSString
        stringWithFormat:@"%@bookings/%@", self.baseURL, reservationId];
    NSLog(@"%@", lol);
    [self GET:[NSString stringWithFormat:@"%@bookings/%@", self.baseURL,
                                         reservationId]
        parameters:nil
        success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"Resonse is %@", responseObject);
            NSString *status = [responseObject valueForKey:@"status"];
            if ([self.delegate
                    respondsToSelector:@selector(bookingHTTPClient:
                                                   didUpdateStatus:)]) {
                [self.delegate bookingHTTPClient:self didUpdateStatus:status];
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Failed to post with task %@ and failure %@", task, error);
        }];
}

- (void)getPriceFrom:(CLLocationCoordinate2D)origin
                  to:(CLLocationCoordinate2D)destination {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    parameters[@"fromLat"] = [NSString stringWithFormat:@"%f", origin.latitude];
    parameters[@"fromLong"] =
        [NSString stringWithFormat:@"%f", origin.longitude];
    parameters[@"toLat"] =
        [NSString stringWithFormat:@"%f", destination.latitude];
    parameters[@"toLong"] =
        [NSString stringWithFormat:@"%f", destination.longitude];
    parameters[@"provider"] = @"TAXINET";
    parameters[@"toLong"] =
        [NSString stringWithFormat:@"%f", destination.longitude];
    NSDateFormatter *dateformate = [[NSDateFormatter alloc] init];
    [dateformate setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    date = [date dateByAddingTimeInterval:300];
    NSString *date_string = [dateformate stringFromDate:date];
    parameters[@"pickupTime"] = [NSString stringWithFormat:@"%@", date_string];

    DDLogVerbose(@"Posting to /price with args: %@", parameters);

    [self POST:[NSString stringWithFormat:@"%@price", self.baseURL]
        parameters:parameters
        success:^(NSURLSessionDataTask *task, id responseObject) {
            DDLogInfo(@"Received price: %@",
                      [responseObject valueForKey:@"fixedPrice"]);
            [self.delegate
                bookingHTTPClient:self
                  didReceivePrice:[[responseObject
                                      valueForKey:@"fixedPrice"] stringValue]];
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Request is: \n\n%@",
                  task.currentRequest.allHTTPHeaderFields);
            if ([self.delegate
                    respondsToSelector:@selector(bookingHTTPClient:
                                                  didFailWithError:)]) {
                [self.delegate bookingHTTPClient:self didFailWithError:error];
            }
        }];
}

@end

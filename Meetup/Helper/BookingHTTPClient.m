//
//  BookingHTTPClient.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-05-06.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "BookingHTTPClient.h"

// static NSString * const WorldWeatherOnlineAPIKey = @"PASTE YOUR API KEY HERE";
static NSString * const BaseURLString = @"http://cabit.nodejitsu.com/";

@implementation BookingHTTPClient

+ (BookingHTTPClient *)sharedBookingHTTPClient
{
    static BookingHTTPClient *_sharedBookingHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedBookingHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:BaseURLString]];
    });
    
    return _sharedBookingHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)requestReservationWithOrigin:(CLLocation *)origin andDestination:(CLLocation *)destination
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"origin"] = [NSString stringWithFormat:@"%f,%f",origin.coordinate.latitude,origin.coordinate.longitude];
    parameters[@"destination"] = [NSString stringWithFormat:@"%f,%f",destination.coordinate.latitude,destination.coordinate.longitude];
    // parameters[@"format"] = @"json";
    // parameters[@"key"] = WorldWeatherOnlineAPIKey;
    
    [self POST:@"booking" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(bookingHTTPClient:didBeginReservation:)]) {
            [self.delegate bookingHTTPClient:self didBeginReservation:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Request is: \n\n%@", task.currentRequest.allHTTPHeaderFields);
        if ([self.delegate respondsToSelector:@selector(bookingHTTPClient:didFailWithError:)]) {
            [self.delegate bookingHTTPClient:self didFailWithError:error];
        }
    }];
}

@end

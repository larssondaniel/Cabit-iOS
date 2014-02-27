//
//  ConfirmationViewController.m
//  Meetup
//
//  Created by Daniel Larsson on 2014-01-26.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "ADDropDownMenuView.h"
#import "ADDropDownMenuItemView.h"
#import "TaxiAnnotation.h"
#import "RouteAnnotation.h"
#import "Vehicle.h"

#import <CoreLocation/CoreLocation.h>

@interface ConfirmationViewController ()

@property (nonatomic, strong) MKPointAnnotation *taxiAnnotation;
@property (nonatomic, retain) CLLocation *initialLocation;

@end

@implementation ConfirmationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mapView setDelegate:self];
    
    self.pickupAnnotation = [[MKPointAnnotation alloc] init];
    self.destinationAnnotation = [[MKPointAnnotation alloc] init];
    
    [self.pickupAnnotation setCoordinate:self.pickupMapItem.placemark.coordinate];
    [self.destinationAnnotation setCoordinate:self.destinationMapItem.placemark.coordinate];
    
    //[self.mapView addAnnotation:self.destinationAnnotation];
    //[self.mapView addAnnotation:self.pickupAnnotation];
    
    [self.navigationController.navigationBar.backItem setTitle:@"Tillbaka"];
    
    self.taxiAnnotation = [[MKPointAnnotation alloc] init];
    
    ADDropDownMenuItemView *item = [[ADDropDownMenuItemView alloc] initWithSize: CGSizeMake(320, 44)];
    item.titleLabel.text = @"Beräknas vara framme om 12 minuter";
    
    //[self generateRoute];
    
    /*
    ADDropDownMenuItemView *item2 = [[ADDropDownMenuItemView alloc] initWithSize: CGSizeMake(320, 44)];
    item2.titleLabel.text = @"Taxi Göteborg";
    
    ADDropDownMenuItemView *item3 = [[ADDropDownMenuItemView alloc] initWithSize: CGSizeMake(320, 44)];
    item3.titleLabel.text = @"Registreringsnummer: ABC-123";
     */
    
    ADDropDownMenuView *dropDownMenuView = [[ADDropDownMenuView alloc] initAtOrigin:CGPointMake(0, 64)
                                                                     withItemsViews:@[item]];
    dropDownMenuView.delegate = self;
    //[self.view addSubview: dropDownMenuView];
    
    // [dropDownMenuView expand];
    
    [self displayTaxiPosition];
}

- (void)displayTaxiPosition
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 57.697107;
    coordinate.longitude = 11.970205;
    
    self.taxiAnnotation.coordinate = coordinate;
    [self.taxiAnnotation setTitle:@"Taxi Göteborg"];
    [self.taxiAnnotation setSubtitle:@"ABC-123"];
    [self.mapView addAnnotation:self.taxiAnnotation];
    [self.mapView selectAnnotation:self.taxiAnnotation animated:YES];
    [self fitRegionToRoute];
}

- (void) fitRegionToRoute {
    MKMapRect zoomRect = MKMapRectNull;

    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    double inset = -zoomRect.size.width * 1;
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        static NSString *identifier = @"TaxiAnnotation";
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            [annotationView setImage:[UIImage imageNamed:@"taxiAnnotation2"]];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}

# pragma mark Directions

- (void)generateRoute {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    if (self.pickupMapItem)
        request.source = self.pickupMapItem;
    
    request.destination = self.destinationMapItem;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"Error is %@", error);
             // Handle Error
         } else {
             [self showRoute:response];
         }
     }];
}

- (void)showRoute:(MKDirectionsResponse *)response {
    [self.mapView removeOverlays:self.mapView.overlays];
    for (MKRoute *route in response.routes)
    {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        // MKMapPoint middlePoint = route.polyline.points[route.polyline.pointCount/2];
        // [self createAndAddAnnotationForCoordinate:MKCoordinateForMapPoint(middlePoint)];
    }
    [self fitRegionToRoute];
}

-(void) createAndAddAnnotationForCoordinate: (CLLocationCoordinate2D) coordinate {
    RouteAnnotation* annotation= [[RouteAnnotation alloc] init];
    annotation.coordinate = coordinate;
    
    [self.mapView addAnnotation: annotation];
}

@end

//
//  ConfirmationViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-01-26.
//  Copyright (c) 2014 Cabit. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "TaxiAnnotation.h"
#import "Vehicle.h"
#import "AnimatedCircleView.h"
#import "DialController.h"
#import "UIView+Glow.h"
#import "DACircularProgressView.h"

#import <CoreLocation/CoreLocation.h>

@interface ConfirmationViewController ()

@property (nonatomic, strong) MKPointAnnotation *taxiAnnotation;
@property (nonatomic, retain) CLLocation *initialLocation;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *plateLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeStaticLabel;
@property (strong, nonatomic) IBOutlet UILabel *plateStaticLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *minLabel;
@property (strong, nonatomic) AnimatedCircleView *circleView;
@property (strong, nonatomic) IBOutlet UILabel *companyStaticLabel;

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
    
    [self.bottomView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"resultBottomView"]]];
    [self.cancelButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blueButton"]]];

    [self.timeLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    [self.timeStaticLabel setFont:[UIFont fontWithName:@"OpenSans" size:10]];
    [self.plateLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    [self.plateStaticLabel setFont:[UIFont fontWithName:@"OpenSans" size:10]];
    [self.companyStaticLabel setFont:[UIFont fontWithName:@"OpenSans" size:10]];
    [self.minLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    [self.cancelButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];

    //[self.mapView addAnnotation:self.destinationAnnotation];
    //[self.mapView addAnnotation:self.pickupAnnotation];
    
    [self.navigationController.navigationBar.backItem setTitle:@"Tillbaka"];
    
    self.taxiAnnotation = [[MKPointAnnotation alloc] init];
    
    [self displayTaxiPosition];
    [self addCircle];

    dc = [[DialController alloc] initWithDialFrame:CGRectMake(110, 31, 30, 28) strings:[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20", nil]];
    //[self.bottomView addSubview:dc.view];
    [dc setDelegate:self];
    
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                           selector:@selector(switchTime:) userInfo:nil repeats:NO];
    NSTimer *timer2;
    timer2 = [NSTimer scheduledTimerWithTimeInterval:5 target:self
                                           selector:@selector(switchTime2:) userInfo:nil repeats:NO];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillResign)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidBecomeActive)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
}

- (void)applicationWillResign
{
    NSLog(@"About to lose focus");
    [self.circleView stop];
}

- (void)applicationDidBecomeActive
{
    NSLog(@"Got it again");
    [self.circleView start];
}

- (void)switchTime:(NSTimer *)incomingTimer
{
    [dc spinToIndex:10];
}

- (void)switchTime2:(NSTimer *)incomingTimer
{
    [dc spinToIndex:9];
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
            [annotationView setImage:[UIImage imageNamed:@"cabIcon"]];
            annotationView.enabled = YES;
            annotationView.canShowCallout = NO;
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

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    NSLog(@"Overlay");
    self.circleView = [[AnimatedCircleView alloc] initWithCircle:(MKCircle *)overlay];
    return self.circleView;
}

-(void)addCircle{
    CLLocationCoordinate2D location;
    location = self.taxiAnnotation.coordinate;
    
    //add overlay
    [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:location radius:500]];
    
    //zoom into the location with the defined circle at the middle
    [self zoomInto:location distance:(500 * 4.0) animated:YES];
}

- (void)zoomInto:(CLLocationCoordinate2D)zoomLocation distance:(CGFloat)distance animated:(BOOL)animated{
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, distance, distance);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:animated];
}

- (void)dialController:(DialController *)dial didSnapToString:(NSString *)string
{
    
}

- (void)dialControllerDidSpin:(DialController *)controller
{
    
}

@end

//
//  ViewController.m
//  Meetup
//
//  Created by Daniel Larsson on 2013-11-18.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import "ViewController.h"
#import "Vehicle.h"
#import "MapTileOverlay.h"
#import "MapTileOverlayView.h"
#import "SIAlertView.h"
#import "RouteAnnotation.h"
#import "CalloutView.h"
#import "ConfirmationViewController.h"
#import "TWMessageBarManager.h"

#import <CoreLocation/CoreLocation.h>

@interface ViewController ()

@property (nonatomic, strong) MKPointAnnotation *destinationAnnotation;
@property (nonatomic, strong) MKPointAnnotation *pickupAnnotation;
@property (nonatomic, strong) MKMapItem *pickupMapItem;
@property (nonatomic, strong) MKMapItem *destinationMapItem;

@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (strong, nonatomic) IBOutlet UIButton *searchPickupButton;
@property (strong, nonatomic) IBOutlet UIButton *searchDestinationButton;

@property (nonatomic, strong) SIAlertView *searchingAlertView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    
    [self.mapView setDelegate:self];
    [self.mapView addSubview:self.searchView];
    [self.mapView addSubview:self.destionationView];
    //[self.mapView addOverlay:[[MapTileOverlay alloc] init]];
    
    self.pickupAnnotation = [[MKPointAnnotation alloc] init];
    self.destinationAnnotation = [[MKPointAnnotation alloc] init];
    
    self.searchPickupButton.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    self.searchPickupButton.titleLabel.minimumScaleFactor = 0.4;
    self.searchDestinationButton.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    self.searchDestinationButton.titleLabel.minimumScaleFactor = 0.4;
    
    // Reverse geolocate
    self.geoCoder = [[CLGeocoder alloc] init];

    // Press gesture recognizer for pin drop
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:lpgr];
    
    [self plotTaxiLocations];
}

- (IBAction)clickedLocate
{
    [self zoomToUserLocation];
    [self calculateLocationAddress];
}

- (void)calculateLocationAddress
{
    [self.geoCoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
        // NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        
        NSLog(@"Adress you are at: %@", [placemark.addressDictionary valueForKey:@"Name"]);
        
        [self.searchPickupButton setTitle:[placemark.addressDictionary valueForKey:@"Name"] forState:UIControlStateNormal];
        [self.locateIndicator stopAnimating];
    }];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    [self setPickupLocation:touchMapCoordinate];
}

- (void)setPickupLocation:(CLLocationCoordinate2D)location
{
    self.pickupAnnotation.coordinate = location;
    [self.mapView addAnnotation:self.pickupAnnotation];
    if (self.destinationMapItem)
        [self generateRoute];
}

- (void)setDestination:(CLLocationCoordinate2D)location
{
    self.destinationAnnotation.coordinate = location;
    [self.mapView addAnnotation:self.destinationAnnotation];
    [self generateRoute];
}

- (void)zoomToUserLocation
{
    if (!self.mapView.userLocation)
        return;
    
    MKCoordinateRegion region;
    region.center = self.mapView.userLocation.location.coordinate;
    
    // Region to show when user clicks locate
    region.span = MKCoordinateSpanMake(0.01, 0.01);
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!self.initialLocation)
    {
        [self calculateLocationAddress];
        self.initialLocation = userLocation.location;
        
        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        
        // Region to show when app is loaded
        region.span = MKCoordinateSpanMake(0.04, 0.04);
        
        region = [mapView regionThatFits:region];
        [mapView setRegion:region animated:YES];
        // Set initial pickup location to current position
        //[self setPickupLocation:self.mapView.userLocation.location.coordinate];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[Vehicle class]]) {
        static NSString *identifier = @"TaxiLocation";
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            //Company *company = ((Vehicle *)annotation).company;
            //if ([company.name isEqualToString:@"Taxi Göteborg"]) {
            //    annotationView.image = [UIImage imageNamed:@"taxiKurirNy"];
            //} else if ([company.name isEqualToString:@"Taxi kurir"])
            //    annotationView.image = [UIImage imageNamed:@"taxiKurirNy"];
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    else if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        static NSString *identifier = @"RouteAnnotation";
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.image = nil;
            annotationView.canShowCallout = YES;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
        
    }
    /*else if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        static NSString *identifier = @"UserLocation";
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.draggable = YES;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;*/
    //}
    
    return nil;
}

/*
-(MKOverlayView*)mapView:(MKMapView*)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MapTileOverlay class]]) {
        //return [[MapTileOverlayView alloc] initWithOverlay:overlay];
    }
    return nil;
}
 */

- (void)plotTaxiLocations
{
    Company *taxiGoteborg = [[Company alloc] initWithName:@"Taxi Göteborg"];
    Company *taxiKurir = [[Company alloc] initWithName:@"Taxi kurir"];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 57.69426;
    coordinate.longitude = 11.97587;
    Vehicle *annotation1 = [[Vehicle alloc] initWithCompany:taxiGoteborg andCarID:@"1" andCoordinate:coordinate];
    [_mapView addAnnotation:annotation1];
    
    coordinate.latitude = 57.696396;
    coordinate.longitude = 11.986084;
    Vehicle *annotation2 = [[Vehicle alloc] initWithCompany:taxiGoteborg andCarID:@"2" andCoordinate:coordinate];
    [_mapView addAnnotation:annotation2];
    
    coordinate.latitude = 57.691141;
    coordinate.longitude = 11.992865;
    Vehicle *annotation3 = [[Vehicle alloc] initWithCompany:taxiKurir andCarID:@"3" andCoordinate:coordinate];
    [_mapView addAnnotation:annotation3];
    
    coordinate.latitude = 57.689948;
    coordinate.longitude = 11.973295;
    Vehicle *annotation4 = [[Vehicle alloc] initWithCompany:taxiKurir andCarID:@"4" andCoordinate:coordinate];
    [_mapView addAnnotation:annotation4];
    
    coordinate.latitude = 57.678845;
    coordinate.longitude = 11.994066;
    Vehicle *annotation5 = [[Vehicle alloc] initWithCompany:taxiGoteborg andCarID:@"5" andCoordinate:coordinate];
    [_mapView addAnnotation:annotation5];
    
    coordinate.latitude = 57.683494;
    coordinate.longitude = 11.961365;
    Vehicle *annotation6 = [[Vehicle alloc] initWithCompany:taxiGoteborg andCarID:@"6" andCoordinate:coordinate];
    [_mapView addAnnotation:annotation6];
    
    coordinate.latitude = 57.686057;
    coordinate.longitude = 11.954005;
    Vehicle *annotation7 = [[Vehicle alloc] initWithCompany:taxiKurir andCarID:@"7" andCoordinate:coordinate];
    [_mapView addAnnotation:annotation7];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"choosePickupLocation"]){
        SearchPickupViewController *controller = (SearchPickupViewController *)segue.destinationViewController;
        controller.delegate = self;
        controller.location = self.mapView.userLocation.location;
    } else if([segue.identifier isEqualToString:@"chooseDestination"]){
        SearchDestinationViewController *controller = (SearchDestinationViewController *)segue.destinationViewController;
        controller.delegate = self;
        controller.location = self.mapView.userLocation.location;
    } else if([segue.identifier isEqualToString:@"displayConfirmation"]){
        //ConfirmationViewController *controller = (ConfirmationViewController *)segue.destinationViewController;
    }
}

- (void)addItemViewController:(SearchPickupViewController *)controller didFinishEnteringPickupLocation:(MKMapItem *)item {
    [self setPickupMapItem:item];
    [self setPickupLocation:item.placemark.location.coordinate];
    [self.searchPickupButton setTitle:item.name forState:UIControlStateNormal];
}

- (void)addItemViewController:(SearchDestinationViewController *)controller didFinishEnteringDestination:(MKMapItem *)item {
    [self setDestinationMapItem:item];
    [self setDestination:item.placemark.location.coordinate];
    [self.searchDestinationButton setTitle:item.name forState:UIControlStateNormal];
}

# pragma mark Directions

- (void)generateRoute {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    //request.source = [MKMapItem mapItemForCurrentLocation];
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    NSLog(@"Pickup item is %@", self.pickupMapItem);
    
    if (self.pickupMapItem) {
        request.source = self.pickupMapItem;
    }
    
    request.destination = self.destinationMapItem;
    // request.requestsAlternateRoutes = YES;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    
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
        MKMapPoint middlePoint = route.polyline.points[route.polyline.pointCount/2];
        [self createAndAddAnnotationForCoordinate:MKCoordinateForMapPoint(middlePoint)];
        //NSLog(@"x = %f", middlePoint.x);
        //NSLog(@"y = %f", middlePoint.y);
    }
    [self fitRegionToRoute];
    //[self showRouteCallout];
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
                                           selector:@selector(showFirstAlertView) userInfo:nil repeats:NO];
    
    //[self showFirstAlertView];
}

- (void)showRouteCallout {
    for (MKAnnotationView *av in self.mapView.annotations)
    {
        if ([av isKindOfClass:[RouteAnnotation class]]) {
            [self.mapView selectAnnotation:av animated:NO];
            // [self.mapView selectAnnotation:av.annotation animated:NO];
            //Setting animated to YES for the user location
            //gives strange results so setting it to NO.
            return;
        }
    }
}

-(void) createAndAddAnnotationForCoordinate: (CLLocationCoordinate2D) coordinate {
    RouteAnnotation* annotation= [[RouteAnnotation alloc] init];
    annotation.coordinate = coordinate;
    
    [self.mapView addAnnotation: annotation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if([view.annotation isKindOfClass:[RouteAnnotation class]]) {
        CalloutView *calloutView = (CalloutView *)[[[NSBundle mainBundle] loadNibNamed:@"CalloutView" owner:self options:nil] objectAtIndex:0];
        CGRect calloutViewFrame = calloutView.frame;
        calloutViewFrame.origin = CGPointMake(0, -calloutViewFrame.size.height);
        calloutView.frame = calloutViewFrame;
        [calloutView setBackgroundColor:[UIColor clearColor]];
        //[calloutView.calloutLabel setText:[(myAnnotation*)[view annotation] title]];
        [view addSubview:calloutView];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.alpha = 0.7;
    renderer.lineWidth = 4.0;
    
    return renderer;
}

- (void) fitRegionToRoute {
    MKMapRect zoomRect = MKMapRectNull;
    NSArray *routeAnnotations = [[NSArray alloc] init];
    
    routeAnnotations = [routeAnnotations arrayByAddingObject:self.pickupAnnotation];
    routeAnnotations = [routeAnnotations arrayByAddingObject:self.destinationAnnotation];
    for (id <MKAnnotation> annotation in routeAnnotations) {
        
        // TODO: WHEN PICKUP IS NOT SET, USE USER LOCATION INSTEAD
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    double inset = -zoomRect.size.width * 1;
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
}

- (void) showFirstAlertView {
    
    // Check if pickup adress is far away, in that case print the distance from the user (for security)
    
    NSString *message = [NSString stringWithFormat:@"Vill du boka en taxi från %@ till %@?", [[self.searchPickupButton titleLabel] text], [[self.searchDestinationButton titleLabel] text]];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Bekräfta" andMessage:message];
    
    [alertView addButtonWithTitle:@"Ja, boka!"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [self showSecondAlertView];
                              //[alert setMessage:@"Letar efter närmsta taxibil. Detta kan ta ett par minuter"];
                          }];
    [alertView addButtonWithTitle:@"Avbryt"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              NSLog(@"Button2 Clicked");
                          }];
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
    };
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
}

- (void) showSecondAlertView {
    NSString *message = [NSString stringWithFormat:@"Din förfrågan skickas just nu till taxibilar i närheten, detta kan ta ett par minuter."];
    self.searchingAlertView = [[SIAlertView alloc] initWithTitle:@"Var god vänta" andMessage:message];
    
    NSTimer *timer;
    //timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self
    //                                       selector:@selector(updateActivityIndicator:) userInfo:alertView repeats:YES];
    
    NSTimer *timer2;
    timer2 = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self
                                            selector:@selector(findTaxi:) userInfo:nil repeats:NO];
    
    [self.searchingAlertView addButtonWithTitle:@"Avbryt"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              [timer invalidate];
                          }];
    
    self.searchingAlertView.willShowHandler = ^(SIAlertView *alertView) {
    };
    self.searchingAlertView.didShowHandler = ^(SIAlertView *alertView) {
    };
    self.searchingAlertView.willDismissHandler = ^(SIAlertView *alertView) {
    };
    self.searchingAlertView.didDismissHandler = ^(SIAlertView *alertView) {
        [timer invalidate];
    };
    
    self.searchingAlertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [self.searchingAlertView show];
}

/*
- (void) showThirdAlertView {
    NSString *message = [NSString stringWithFormat:@"Registreringnummer: ABC 123\n Från: %@\nTill: %@\n\nFörväntad ankomsttid: 10 min", [[self.searchPickupButton titleLabel] text], [[self.searchDestinationButton titleLabel] text]];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Göteborgstaxi är på väg" andMessage:message];
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
    };
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
}
*/

- (void) updateActivityIndicator:(NSTimer *)incomingTimer
{
    if ([incomingTimer userInfo] != nil) {
        if ([[[incomingTimer userInfo] message] length] <= 30) {
            [[incomingTimer userInfo] setMessage:[[[incomingTimer userInfo] message] stringByAppendingString:@"."]];
        }
        else {
            [[incomingTimer userInfo] setMessage:[[[incomingTimer userInfo] message]stringByReplacingCharactersInRange:(NSRange){27, 3} withString:@""]];
        }
    }
}

- (void) findTaxi:(NSTimer *)incomingTimer {
    [self.searchingAlertView dismissAnimated:YES];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Bokning genomförd!"
                                                   description:@"En taxi är på väg."
                                                          type:TWMessageBarMessageTypeSuccess];
    [self performSegueWithIdentifier: @"displayConfirmation" sender: self];
}

@end

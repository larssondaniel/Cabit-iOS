//
//  MainViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2013-11-18.
//  Copyright (c) 2013 Cabit. All rights reserved.
//

#import "MainViewController.h"
#import "Vehicle.h"
#import "SIAlertView.h"
#import "ConfirmationViewController.h"
#import "TWMessageBarManager.h"
#import "UIView+Glow.h"
#import "CAKeyframeAnimation+AHEasing.h"

#import <CoreLocation/CoreLocation.h>

@interface MainViewController ()

@property (nonatomic, strong) MKPointAnnotation *destinationAnnotation;
@property (nonatomic, strong) MKPointAnnotation *pickupAnnotation;
@property (nonatomic, strong) MKMapItem *pickupMapItem;
@property (nonatomic, strong) MKMapItem *destinationMapItem;

@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (strong, nonatomic) IBOutlet UIButton *searchPickupButton;
@property (strong, nonatomic) IBOutlet UIButton *searchDestinationButton;

@property (nonatomic, strong) SIAlertView *searchingAlertView;
@property (strong, nonatomic) IBOutlet UIView *numberOfCabsView;
@property (strong, nonatomic) IBOutlet UIButton *bouncingCone;
@property (strong, nonatomic) IBOutlet UIView *animatedBottomView;
@property (strong, nonatomic) IBOutlet UIView *pickupView;
@property (strong, nonatomic) IBOutlet UIView *destinationView;
@property (strong, nonatomic) IBOutlet UIButton *pickupLabel;
@property (strong, nonatomic) IBOutlet UILabel *pickupStaticLabel;
@property (strong, nonatomic) IBOutlet UIView *pickupViewWithImage;
@property (strong, nonatomic) IBOutlet UIView *destinationViewWithImage;
@property (strong, nonatomic) IBOutlet UILabel *destinationStaticLabel;
@property (strong, nonatomic) IBOutlet UIButton *destinationLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *locateIndicator;

@property (nonatomic) bool isShowingDestinaion;
@property (nonatomic) bool shouldAnimateBottomView;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapView setDelegate:self];
    [self.mapView addSubview:self.searchView];
    [self.mapView addSubview:self.numberOfCabsView];
    
    self.shouldAnimateBottomView = NO;
    
    self.pickupAnnotation = [[MKPointAnnotation alloc] init];
    self.destinationAnnotation = [[MKPointAnnotation alloc] init];
    
    self.searchPickupButton.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    self.searchPickupButton.titleLabel.minimumScaleFactor = 0.4;
    self.searchDestinationButton.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    self.searchDestinationButton.titleLabel.minimumScaleFactor = 0.4;
    
    // Reverse geolocate
    self.geoCoder = [[CLGeocoder alloc] init];

    //NSTimer *bounceTimer;
    //bounceTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
    //                                      selector:@selector(bounce) userInfo:nil repeats:YES];
    
    [self.pickupView startGlowingWithColor:[self.searchDestinationButton backgroundColor] intensity:0.7];
    
    [self.animatedBottomView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bottomGradient"]]];
    [self.pickupViewWithImage setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bottomView"]]];
    [self.destinationViewWithImage setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bottomView"]]];
    [self.pickupView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bottomView"]]];
    [self.destinationView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bottomView"]]];
    [self.searchDestinationButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blueButton"]]];
    [self setIsShowingDestinaion:NO];
    [self.pickupLabel.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    [self.pickupStaticLabel setFont:[UIFont fontWithName:@"OpenSans" size:11]];
    
    [self.destinationLabel.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    [self.destinationStaticLabel setFont:[UIFont fontWithName:@"OpenSans" size:11]];
    
    [self.searchDestinationButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"OpenSans" size:21],
      NSFontAttributeName, nil]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.shouldAnimateBottomView)
        [self animateBottomView];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.mapView.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.mapView.delegate = nil;
}

- (void)setInitialPickupAddress
{
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    [self setPickupMapItem:currentLocation];
    [self setPickupLocation:currentLocation.placemark.location.coordinate];
    [self.pickupLabel setTitle:currentLocation.name forState:UIControlStateNormal];
}

- (IBAction)clickedLocate
{
    CLLocationCoordinate2D myCoord = {self.mapView.userLocation.location.coordinate.latitude,self.mapView.userLocation.location.coordinate.longitude};
    [self setPickupLocation:myCoord];
    [self zoomToUserLocation];
    [self calculateLocationAddress];
}

- (void)calculateLocationAddress
{
    [self.geoCoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
        // NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        
        [self.pickupLabel setTitle:[placemark.addressDictionary valueForKey:@"Name"] forState:UIControlStateNormal];
        [self.locateIndicator stopAnimating];
        [self setPickupMapItem:[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:placemark]]];
        [self setPickupLocation:placemark.location.coordinate];
    }];
}

- (void)setPickupLocation:(CLLocationCoordinate2D)location
{
    self.pickupAnnotation.coordinate = location;
    //[self.mapView addAnnotation:self.pickupAnnotation];
    if (self.destinationMapItem)
        [self generateRoute];
}

- (void)setDestination:(CLLocationCoordinate2D)location
{
    self.destinationAnnotation.coordinate = location;
    NSLog(@"Adding destination annotation");
    [self.mapView addAnnotation:self.destinationAnnotation];
    [self generateRoute];
    [self fitRegionToRoute];
}

- (void)zoomToUserLocation
{
    if (!self.mapView.userLocation)
        return;
    
    if (!self.mapView.userLocation.location)
        NSLog(@"Location not obtained just yet");
        return;
    
    NSTimeInterval locationAgeInSeconds =
    [[NSDate date] timeIntervalSinceDate:self.mapView.userLocation.location.timestamp];
    if (locationAgeInSeconds > 300)  //adjust max age as needed
    {
        NSLog(@"location data is too old");
        return;
    }
    
    if (!CLLocationCoordinate2DIsValid(self.mapView.userLocation.coordinate))
    {
        NSLog(@"userlocation coordinate is invalid");
        return;
    }
    
    //MKCoordinateRegion region;
    //region.center = self.mapView.userLocation.location.coordinate;

    // Region to show when user clicks locate
    //region.span = MKCoordinateSpanMake(0.01, 0.01);
    //region = [self.mapView regionThatFits:region];
    //[self.mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"1");
    if (!self.initialLocation)
    {
        NSLog(@"2");
        MKCoordinateRegion region;
        NSLog(@"3");
        region.center = userLocation.coordinate;
        NSLog(@"4");
        // Region to show when app is loaded
        region.span = MKCoordinateSpanMake(0.04, 0.04);
        NSLog(@"5");
        region = [mapView regionThatFits:region];
        NSLog(@"6");
        
        if (!CLLocationCoordinate2DIsValid(userLocation.coordinate)) {
            //do nothing, invalid regions
            NSLog(@"co-ord fail");
        } else if (region.span.latitudeDelta <= 0.0 || region.span.longitudeDelta <= 0.0) {
            NSLog(@"invalid reg");
        } else {
            [self calculateLocationAddress];
            self.initialLocation = userLocation.location;
            [mapView setRegion:region animated:YES];
            NSLog(@"7");
            // Set initial pickup location to current position
            //[self setPickupLocation:self.mapView.userLocation.location.coordinate];
        }
    }
}

/*
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"WE FUCKING GOT HERE");
    if (![annotation isKindOfClass:[MKUserLocation class]]) {
        NSLog(@"AND HERE");
        static NSString *identifier = @"TaxiLocation";
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            [annotationView setImage:[UIImage imageNamed:@"pin"]];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}
*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"choosePickupLocation"]){
        SearchPickupViewController *controller = (SearchPickupViewController *)segue.destinationViewController;
        controller.delegate = self;
        controller.location = self.mapView.userLocation.location;
    } else if([segue.identifier isEqualToString:@"chooseDestination"]){
        SearchDestinationViewController *controller = (SearchDestinationViewController *)segue.destinationViewController;
        controller.delegate = self;
        controller.location = self.mapView.userLocation.location;
        if (!self.pickupAnnotation) {
            self.pickupAnnotation = [[MKPointAnnotation alloc] init];
            CLLocationCoordinate2D myCoord = {self.mapView.userLocation.location.coordinate.latitude,self.mapView.userLocation.location.coordinate.longitude};
            [self setPickupLocation:myCoord];
        }
    } else if([segue.identifier isEqualToString:@"displayConfirmation"]){
        ConfirmationViewController *controller = (ConfirmationViewController *)segue.destinationViewController;
        controller.pickupMapItem = self.pickupMapItem;
        controller.destinationMapItem = self.destinationMapItem;
        controller.pickupAnnotation = self.pickupAnnotation;
        controller.destinationAnnotation = self.destinationAnnotation;
    }
}

- (void)addItemViewController:(SearchPickupViewController *)controller didFinishEnteringPickupLocation:(MKMapItem *)item {
    [self setPickupMapItem:item];
    [self setPickupLocation:item.placemark.location.coordinate];
    [self.pickupLabel setTitle:item.name forState:UIControlStateNormal];
}

- (void)addItemViewController:(SearchDestinationViewController *)controller didFinishEnteringDestination:(MKMapItem *)item {
    [self setDestinationMapItem:item];
    [self setDestination:item.placemark.location.coordinate];
    [self.destinationLabel setTitle:item.name forState:UIControlStateNormal];
    self.shouldAnimateBottomView = YES;
}

# pragma mark Directions

- (void)generateRoute {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];

    if (self.pickupMapItem) {
    //    request.source = self.pickupMapItem;
    }
    
    request.destination = self.destinationMapItem;
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
    
    MKPointAnnotation *userAnnotation = [[MKPointAnnotation alloc] init];
    [userAnnotation setCoordinate:self.mapView.userLocation.coordinate];
    routeAnnotations = [routeAnnotations arrayByAddingObject:self.mapView.userLocation];
    routeAnnotations = [routeAnnotations arrayByAddingObject:self.pickupAnnotation];
    if (self.destinationAnnotation)
        routeAnnotations = [routeAnnotations arrayByAddingObject:self.destinationAnnotation];
    for (id <MKAnnotation> annotation in routeAnnotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    double inset = -zoomRect.size.width * 1;
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
    NSLog(@"This just happened");
}

/*
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
*/

- (void) showAlertView {
    NSString *message = [NSString stringWithFormat:@"Din förfrågan skickas just nu till taxibilar i närheten, detta kan ta ett par minuter."];
    self.searchingAlertView = [[SIAlertView alloc] initWithTitle:@"Var god vänta" andMessage:message];
    
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self
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

#pragma Animation

- (CAKeyframeAnimation *)dockBounceAnimationWithIconHeight:(CGFloat)iconHeight
{
	CGFloat factors[32] = {0, 32, 60, 83, 100, 114, 124, 128, 128, 124, 114, 100, 83, 60, 32,
        0, 24, 42, 54, 62, 64, 62, 54, 42, 24, 0, 18, 28, 32, 28, 18, 0};
    
	NSMutableArray *values = [NSMutableArray array];
    
	for (int i=0; i<32; i++)
	{
		CGFloat positionOffset = factors[i]/128.0f * iconHeight;
        
		CATransform3D transform = CATransform3DMakeTranslation(-positionOffset, 0, 0);
		[values addObject:[NSValue valueWithCATransform3D:transform]];
	}
    
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	animation.repeatCount = 1;
	animation.duration = 32.0f/30.0f;
	animation.fillMode = kCAFillModeForwards;
	animation.values = values;
	animation.removedOnCompletion = YES; // final stage is equal to starting stage
	animation.autoreverses = NO;
    
	return animation;
}

- (void)bounce
{
	CAKeyframeAnimation *animation = [self dockBounceAnimationWithIconHeight:20];
	[self.bouncingCone.layer addAnimation:animation forKey:@"jumping"];
}

- (IBAction)clickedChooseDestination:(id)sender {
    if (!self.isShowingDestinaion) {
        [self performSegueWithIdentifier:@"chooseDestination" sender:self];
    } else {
        [self showAlertView];
    }
}

- (void)animateBottomView
{
    [self setIsShowingDestinaion:YES];
    [self.destinationView startGlowingWithColor:[self.searchDestinationButton backgroundColor] intensity:0.7];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -140);
    //[UIView animateWithDuration:0.3
    //                 animations:^{
    //                     self.animatedBottomView.transform = transform;
    //                 }];
    [self.searchDestinationButton setTitle:@"BOKA" forState:UIControlStateNormal];
    [self.pickupView stopGlowing];
    [self.pickupLabel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    CALayer *layer = self.animatedBottomView.layer;
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.200] forKey:kCATransactionAnimationDuration];
    
    CAAnimation *chase = [CAKeyframeAnimation animationWithKeyPath:@"position"
                                                          function:ExponentialEaseIn
                                                         fromPoint:self.animatedBottomView.center
                                                           toPoint:CGPointMake(self.animatedBottomView.center.x, self.animatedBottomView.center.y-70)];
    [chase setDelegate:self];
    [layer addAnimation:chase forKey:@"position"];
    
    [CATransaction commit];
    [self.animatedBottomView setCenter:CGPointMake(self.animatedBottomView.center.x, self.animatedBottomView.center.y-70)];
    self.shouldAnimateBottomView = NO;
}

@end

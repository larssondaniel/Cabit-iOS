//
//  MainViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2013-11-18.
//  Copyright (c) 2013 Cabit. All rights reserved.
//

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

#import "MainViewController.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "FXBlurView.h"
#import "CredentialsViewController.h"
#import "SettingsViewController.h"
#import "SearchViewController.h"
#import "SPGooglePlacesAutocomplete.h"
#import "CSAnimation.h"
#import "MapAnnotation.h"

#import <CoreLocation/CoreLocation.h>

@interface MainViewController ()

@property (nonatomic, strong) MapAnnotation *destinationAnnotation;
@property (nonatomic, strong) MapAnnotation *pickupAnnotation;
@property (nonatomic, strong) MKMapItem *pickupMapItem;
@property (nonatomic, strong) MKMapItem *destinationMapItem;

@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, strong) CLGeocoder *geoCoder;

@property (strong, nonatomic) IBOutlet UIView *animatedBottomView;
@property (strong, nonatomic) IBOutlet UIButton *pickupLabel;
@property (strong, nonatomic) IBOutlet UILabel *pickupStaticLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewTopConstraint;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *destinationActivityIndicator;

@property (nonatomic) bool shouldAnimateBottomView;
@property (nonatomic, strong) UIToolbar *tintView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UILabel *searchLabel;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) MKLocalSearchRequest *localSearchRequest;
@property (strong, nonatomic) MKLocalSearch *localSearch;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIView *credentialsContainer;
@property (strong, nonatomic) IBOutlet UIView *settingsContainer;
@property (strong, nonatomic) IBOutlet UIView *searchContainer;
@property (nonatomic) bool isSearchingForPickup;




@property (strong, nonatomic) IBOutlet UIView *destinationView;
@property (strong, nonatomic) IBOutlet UIView *pickupView;
@property (strong, nonatomic) IBOutlet UIImageView *destinationArrow;
@property (strong, nonatomic) IBOutlet UIButton *destinationButton;
@property (strong, nonatomic) IBOutlet UIButton *pickupButton;
@property (strong, nonatomic) IBOutlet UILabel *destinationStaticLabel;
@property (strong, nonatomic) IBOutlet UIImageView *pickupArrow;

@property (strong, nonatomic) IBOutlet UIView *additionalInfoView;

@property (strong, nonatomic) IBOutlet UILabel *travelTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UIButton *makeReservationButton;
@property (strong, nonatomic) IBOutlet UIView *timerView;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIButton *toggleInformationButton;
@property (nonatomic) BOOL isShowingAddresses;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIView *addressToolbar;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapView setDelegate:self];
    self.data = [[NSMutableArray alloc] init];
    
    self.additionalInfoView.hidden = YES;
    self.timerView.hidden = YES;
    
    // Reverse geolocate
    self.geoCoder = [[CLGeocoder alloc] init];
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 138)];
    [self.addressToolbar addSubview:self.toolbar];
    
    UIToolbar *toolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 68)];
    [self.additionalInfoView addSubview:toolbar2];
    
    UIToolbar *toolbar3 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 85)];
    [self.timerView addSubview:toolbar3];
    
    for (UIView *subview in self.additionalInfoView.subviews) {
        if (!([subview isKindOfClass:[UIToolbar class]]))
            [self.additionalInfoView bringSubviewToFront:subview];
    }
    
    for (UIView *subview in self.timerView.subviews) {
        if (!([subview isKindOfClass:[UIToolbar class]]))
            [self.timerView bringSubviewToFront:subview];
    }
    
    [self.view bringSubviewToFront:self.pickupView];
    [self.view bringSubviewToFront:self.destinationView];
    [self.view bringSubviewToFront:self.additionalInfoView];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"OpenSans" size:21],
      NSFontAttributeName, nil]];
    
    //[self setFontFamily:@"OpenSans" forView:self.view andSubViews:YES];
    
    // In order to animate it later
    self.tintView = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    self.tintView.barTintColor = [UIColor colorWithRed:0.196 green:0.235 blue:0.313 alpha:0.6];
    self.tintView.autoresizingMask = self.view.autoresizingMask;
    self.tintView.alpha = 0.0;
    [self.view addSubview:self.tintView];
    
    self.credentialsContainer.alpha = 0.0;

    [self.travelTimeLabel setAttributedText:[self attributedFontForValue:@"12" andUnit:@"min"]];
    [self.priceLabel setAttributedText:[self attributedFontForValue:@"240" andUnit:@"sek"]];
    
    [self.destinationStaticLabel setFont:[UIFont fontWithName:@"OpenSans" size:12]];

    [self.pickupButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:20]];
    [self.destinationButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:20]];

    //[self showCredentialsView];
}

- (NSAttributedString *)attributedFontForValue:(NSString *)value andUnit:(NSString *)unit
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];
    UIFont *largeFont = [UIFont fontWithName:@"OpenSans" size:40];
    UIFont *smallFont = [UIFont fontWithName:@"OpenSans-Light" size:20];
    UIColor *color = [UIColor colorWithRed:46.0f/255.0f green:67.0f/255.0f blue:89.0f/255.0f alpha:1];
    NSDictionary *largeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                largeFont, NSFontAttributeName,
                                color, NSForegroundColorAttributeName,
                                nil];
    NSDictionary *smallAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     smallFont, NSFontAttributeName,
                                     color, NSForegroundColorAttributeName,
                                     nil];

    NSAttributedString *subString = [[NSAttributedString alloc] initWithString:value attributes:largeAttributes];
    [string appendAttributedString:subString];
    subString = [[NSAttributedString alloc] initWithString:unit attributes:smallAttributes];
    [string appendAttributedString:subString];
    return string;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self hideSearchView];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.mapView.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.mapView.delegate = nil;
}

-(void)setFontFamily:(NSString*)fontFamily forView:(UIView*)view andSubViews:(BOOL)isSubViews
{
    if ([view isKindOfClass:[UILabel class]])
    {
        UILabel *lbl = (UILabel *)view;
        [lbl setFont:[UIFont fontWithName:fontFamily size:[[lbl font] pointSize]]];
    }
    
    if (isSubViews)
    {
        for (UIView *sview in view.subviews)
        {
            [self setFontFamily:fontFamily forView:sview andSubViews:YES];
        }
    }
}

/*
 *  Not used at the moment. Is needed if there should be a locate button after the user changes to another origin adress.
 */
- (IBAction)clickedLocate
{
    CLLocationCoordinate2D myCoord = {self.mapView.userLocation.location.coordinate.latitude,self.mapView.userLocation.location.coordinate.longitude};
    [self setPickupLocation:myCoord];
    [self zoomToUserLocation];
    [self calculateUserAddress];
}

- (void)calculateUserAddress
{
    [self.activityIndicator startAnimating];
    [self.geoCoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSString *parsedAddress = [self parseAddress:[placemark.addressDictionary valueForKey:@"Name"]];
        [self.pickupButton setTitle:parsedAddress forState:UIControlStateNormal];
        [self.activityIndicator stopAnimating];
        [self setPickupMapItem:[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:placemark]]];
        [self setPickupLocation:placemark.location.coordinate];
        [self animateBottomView];
    }];
}

- (void)calculatePinAddressForLocation:(CLLocation *)location andPinType:(NSString *)pinType
{
    if ([pinType isEqualToString:PICKUP_ANNOTATION]) {
        [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *parsedAddress = [self parseAddress:[placemark.addressDictionary valueForKey:@"Name"]];
            [self.pickupButton setTitle:parsedAddress forState:UIControlStateNormal];
            [self setPickupMapItem:[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:placemark]]];
            [self setPickupLocation:placemark.location.coordinate];
        }];
    } else if ([pinType isEqualToString:DESTINATION_ANNOTATION]) {
        [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *parsedAddress = [self parseAddress:[placemark.addressDictionary valueForKey:@"Name"]];
            [self.destinationButton setTitle:parsedAddress forState:UIControlStateNormal];
            [self setDestinationMapItem:[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:placemark]]];
            [self setDestination:placemark.location.coordinate];
        }];
    }
}

- (void)setPickupLocation:(CLLocationCoordinate2D)location
{
    if (!self.pickupAnnotation)
        self.pickupAnnotation = [[MapAnnotation alloc] init];
    self.pickupAnnotation.typeOfAnnotation = PICKUP_ANNOTATION;
    self.pickupAnnotation.coordinate = location;
    [self.mapView addAnnotation:self.pickupAnnotation];
    [self zoomToLocation:PICKUP_ANNOTATION];
    
    if (self.destinationMapItem) {
        [self generateRoute];
        //[self fitRegionToRoute];
    }
}

- (void)setDestination:(CLLocationCoordinate2D)location
{
    if (!self.destinationAnnotation)
        self.destinationAnnotation = [[MapAnnotation alloc] init];
    self.destinationAnnotation.typeOfAnnotation = DESTINATION_ANNOTATION;
    self.destinationAnnotation.coordinate = location;
    [self.mapView addAnnotation:self.destinationAnnotation];
    [self zoomToLocation:DESTINATION_ANNOTATION];
    
    [self generateRoute];
    //[self fitRegionToRoute];
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
    if (locationAgeInSeconds > 300)
    {
        NSLog(@"Location data is too old");
        return;
    }
    
    if (!CLLocationCoordinate2DIsValid(self.mapView.userLocation.coordinate))
    {
        NSLog(@"userlocation coordinate is invalid");
        return;
    }
    
    MKCoordinateRegion region;
    region.center = self.mapView.userLocation.location.coordinate;

    region.span = MKCoordinateSpanMake(0.01, 0.01);
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

- (void)zoomToLocation:(NSString *)locationType
{
    NSLog(@"ZoOOoming");
    //MKCoordinateRegion region;
    MKMapPoint annotationPoint;
    if ([locationType isEqualToString:PICKUP_ANNOTATION]) {
        //region.center = self.pickupAnnotation.coordinate;
        annotationPoint = MKMapPointForCoordinate(self.pickupAnnotation.coordinate);
    } else if ([locationType isEqualToString:DESTINATION_ANNOTATION]) {
        //region.center = self.destinationAnnotation.coordinate;
        annotationPoint = MKMapPointForCoordinate(self.destinationAnnotation.coordinate);
    }
    //region.span = MKCoordinateSpanMake(0.01, 0.01);
    //region = [self.mapView regionThatFits:region];
    
    MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 1, 1);

    double inset = -zoomRect.size.width * 1;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(40, 40, 450, 40);
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) edgePadding:edgeInsets animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!self.initialLocation)
    {
        MKCoordinateRegion region;
        region.center = userLocation.coordinate;
        // Region to show when app is loaded
        region.span = MKCoordinateSpanMake(0.04, 0.04);
        region = [mapView regionThatFits:region];
        
        if (!CLLocationCoordinate2DIsValid(userLocation.coordinate)) {
            //do nothing, invalid regions
            NSLog(@"Invalid regions");
        } else if (region.span.latitudeDelta <= 0.0 || region.span.longitudeDelta <= 0.0) {
            NSLog(@"Invalid regions");
        } else {
            [self calculateUserAddress];
            self.initialLocation = userLocation.location;
            [mapView setRegion:region animated:YES];
            // Set initial pickup location to current position
            //[self setPickupLocation:self.mapView.userLocation.location.coordinate];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation
{
    MKAnnotationView *customAnnotationView;
    if ([annotation isKindOfClass:[MapAnnotation class]] ){
        MapAnnotation *theAnnotation = (MapAnnotation*)annotation;
        customAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        [customAnnotationView setDraggable:YES];
        [customAnnotationView setCanShowCallout:NO];
        UIImage *pinImage = nil;
        if ([[theAnnotation typeOfAnnotation] isEqualToString:PICKUP_ANNOTATION]) {
            pinImage = [UIImage imageNamed:@"green_pin"];
        } else {
            pinImage = [UIImage imageNamed:@"green_pin"];
        }
        //[customAnnotationView setImage:pinImage];
    } else {
        return nil;
    }
    
    return customAnnotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        MapAnnotation *theAnnotation = (MapAnnotation*)annotationView.annotation;
        if ([theAnnotation.typeOfAnnotation isEqualToString:PICKUP_ANNOTATION]) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:theAnnotation.coordinate.latitude longitude:theAnnotation.coordinate.longitude];
            [self calculatePinAddressForLocation:location andPinType:PICKUP_ANNOTATION];
        } else if ([theAnnotation.typeOfAnnotation isEqualToString:DESTINATION_ANNOTATION]) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:theAnnotation.coordinate.latitude longitude:theAnnotation.coordinate.longitude];
            [self calculatePinAddressForLocation:location andPinType:DESTINATION_ANNOTATION];
        }
    }
}

# pragma mark Directions

- (void)generateRoute {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];

    if (self.pickupMapItem) {
        request.source = self.pickupMapItem;
    }
    
    request.destination = self.destinationMapItem;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"Error is %@", error);
             // Handle error
         } else {
             [self showRoute:response];
         }
     }];
}

- (void)showRoute:(MKDirectionsResponse *)response {
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        [self.mapView removeOverlays:self.mapView.overlays];
        for (MKRoute *route in response.routes)
        {
            [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        }
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView transitionWithView:self.additionalInfoView
                      duration:0.4
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^{
                        //  Set the new image
                        //  Since its done in animation block, the change will be animated
                        self.additionalInfoView.hidden = NO;
                    } completion:^(BOOL finished) {
                        //  Do whatever when the animation is finished
                    }];

    /*
    //self.additionalInfoView.transform = CGAffineTransformMakeTranslation(0, 100);
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        self.additionalInfoView.transform = CGAffineTransformMakeTranslation(0, -300);
    } completion:^(BOOL finished) { }];
     */
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
    //routeAnnotations = [routeAnnotations arrayByAddingObject:self.mapView.userLocation];
    routeAnnotations = [routeAnnotations arrayByAddingObject:self.destinationAnnotation];
    routeAnnotations = [routeAnnotations arrayByAddingObject:self.pickupAnnotation];
    
    for (id <MKAnnotation> annotation in routeAnnotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    double inset = -zoomRect.size.width * 1;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(40, 40, 250, 40);
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) edgePadding:edgeInsets animated:YES];
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

- (void)animateBottomView
{
    CAAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:ExponentialEaseOut fromPoint:CGPointMake(self.animatedBottomView.center.x, self.animatedBottomView.center.y) toPoint:CGPointMake(self.animatedBottomView.center.x, self.animatedBottomView.center.y - 60)];
    animation.duration = 1;
    [self.animatedBottomView.layer addAnimation:animation forKey:@"easing"];
    [self.animatedBottomView setCenter:CGPointMake(self.animatedBottomView.center.x, self.animatedBottomView.center.y - 60)];
    [self.animatedBottomView setFrame:CGRectMake(0, 370, 320, 120)];
    [self.bottomViewTopConstraint setConstant:370];
    [self.view layoutIfNeeded];

    self.shouldAnimateBottomView = NO;
}

- (IBAction)showPickupSearchView {
    self.isSearchingForPickup = YES;
    [self showSearchView];
}

- (IBAction)showDestinationSearchView {
    self.isSearchingForPickup = NO;
    [self showSearchView];
}

#pragma credentials

- (void)showCredentialsView {
    [self.view bringSubviewToFront:self.credentialsContainer];
    [UIView animateWithDuration:0.4 animations:^{
        self.credentialsContainer.alpha = 1.0;
        self.tintView.alpha = 0.97;
        self.animatedBottomView.alpha = 0.0;
    }];
    CredentialsViewController *credentialsViewController = (CredentialsViewController *)self.childViewControllers[0];
    [credentialsViewController beginAnimations];
}

- (void)didFinishEnteringCredentials {
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.animatedBottomView.alpha = 1.0;
        self.tintView.alpha = 0.0;
        [self.credentialsContainer setAlpha:0.0];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

#pragma settings

- (void)hideSettingsView {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.15 animations:^(void) {
        
        self.navigationController.navigationBar.alpha = 1.0;

        self.animatedBottomView.alpha = 1.0;
        self.settingsContainer.alpha = 0.0;
        self.tintView.alpha = 0.0;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (IBAction)showSettingsView {
    [self.view bringSubviewToFront:self.settingsContainer];
    SettingsViewController *settingsViewController = (SettingsViewController *)self.childViewControllers[1];
    [settingsViewController setUserLocation:self.mapView.userLocation.location.coordinate];
    [UIView animateWithDuration:0.15 animations:^{
        
        self.navigationController.navigationBar.alpha = 0.0;
        
        self.settingsContainer.alpha = 1.0;
        self.tintView.alpha = 1.0;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

#pragma search

- (void)showSearchView {
    [self.view bringSubviewToFront:self.searchContainer];
    [UIView animateWithDuration:0.15 animations:^{
        self.searchContainer.alpha = 1.0;
        self.tintView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        self.tintView.alpha = 0.97;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    SearchViewController *searchViewController = (SearchViewController *)self.childViewControllers[2];
    if (self.isSearchingForPickup)
        [searchViewController setActiveWithLabel:@"Upphämtning" andUserLocation:self.mapView.userLocation.coordinate];
    else
        [searchViewController setActiveWithLabel:@"Destination" andUserLocation:self.mapView.userLocation.coordinate];
}

- (void)hideSearchView {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.15 animations:^(void) {
        self.tintView.alpha = 0.0;
        self.searchContainer.alpha = 0.0;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)didFinishSearchWithAdress:(SPGooglePlacesAutocompletePlace *)mapItem
{
    NSString *parsedAddress = [self parseAddress:mapItem.name];

    if (self.isSearchingForPickup) {
        [mapItem resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
            MKPlacemark *mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:mkPlacemark];
            [self setPickupMapItem:mapItem];
            [self setPickupLocation:placemark.location.coordinate];
        }];
        [self.pickupButton setTitle:parsedAddress forState:UIControlStateNormal];
    } else {
        [self.destinationActivityIndicator startAnimating];
        [mapItem resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
            MKPlacemark *mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:mkPlacemark];
            [self setDestinationMapItem:mapItem];
            [self setDestination:placemark.location.coordinate];
            [self.destinationActivityIndicator stopAnimating];
        }];
        [self.destinationButton setTitle:parsedAddress forState:UIControlStateNormal];
    }
}

- (NSString *)parseAddress:(NSString *)address {
    NSArray *addressComponents = [address componentsSeparatedByString:@","];
    NSString *parsedAddress = [NSString stringWithFormat:@"%@", [addressComponents objectAtIndex:0]];
    return parsedAddress;
}

- (IBAction)didBeginTouchAtPickupButton {
    [self performPopAnimationOnView:self.pickupArrow duration:0.3 delay:0];
}

- (IBAction)didBeginTouchAtDestinationButton {
    [self performPopAnimationOnView:self.destinationArrow duration:0.3 delay:0];
}

- (void)performShakeAnimationOnView:(UIView *)view duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay {
    // Start
    view.transform = CGAffineTransformMakeTranslation(0, 0);
    [UIView animateKeyframesWithDuration:duration/5 delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(14, 0);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/5 delay:0 options:0 animations:^{
            // End
            view.transform = CGAffineTransformMakeTranslation(-14, 0);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/5 delay:0 options:0 animations:^{
                // End
                view.transform = CGAffineTransformMakeTranslation(7, 0);
            } completion:^(BOOL finished) {
                [UIView animateKeyframesWithDuration:duration/5 delay:0 options:0 animations:^{
                    // End
                    view.transform = CGAffineTransformMakeTranslation(-7, 0);
                } completion:^(BOOL finished) {
                    [UIView animateKeyframesWithDuration:duration/5 delay:0 options:0 animations:^{
                        // End
                        view.transform = CGAffineTransformMakeTranslation(0, 0);
                    } completion:^(BOOL finished) {
                        // End
                    }];
                }];
            }];
        }];
    }];
}

- (void)performSlideRightAnimationOnView:(UIView *)view duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay {
    // Start
    view.transform = CGAffineTransformMakeTranslation(0, 0);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(100, 0);
    } completion:^(BOOL finished) { }];
}

- (void)performPopAnimationOnView:(UIView *)view duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay {
    // Start
    view.transform = CGAffineTransformMakeScale(1, 1);
    CGRectApplyAffineTransform(view.frame, CGAffineTransformMakeScale(1, 1));
    [UIView animateKeyframesWithDuration:duration/3 delay:delay options:0 animations:^{
        // End
        CGRectApplyAffineTransform(view.frame, CGAffineTransformMakeScale(1.2, 1.2));
        view.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
            // End
            view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
                // End
                view.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
}

- (IBAction)clickedDestination {
    self.isSearchingForPickup = NO;
    [self showSearchView];
}
- (IBAction)clickedPickup {
    self.isSearchingForPickup = YES;
    [self showSearchView];
}

- (IBAction)clickedContinue {
    if (!(self.pickupMapItem && self.destinationMapItem)) {
        [self performShakeAnimationOnView:self.destinationStaticLabel duration:0.3 delay:0];
    } else {
        [self animateButtonsToLeft:1];
        [UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
            self.destinationArrow.transform = CGAffineTransformTranslate(self.destinationArrow.transform, 100, 0);
            self.pickupArrow.transform = CGAffineTransformTranslate(self.pickupArrow.transform, 100, 0);
        } completion:^(BOOL finished) {
            self.destinationButton.enabled = NO;
            self.pickupButton.enabled = NO;
        }];
        [self fitRegionToRoute];
    }
}

- (IBAction)clickedMakeReservation:(id)sender {
    [self animateButtonsToLeft:1];
    
    for (id<MKAnnotation> annotation in self.mapView.annotations){
        MKAnnotationView* view = [self.mapView viewForAnnotation: annotation];
        if (view){
            [view setDraggable:NO];
        }
    }
    
    [UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
        self.toolbar.transform = CGAffineTransformMakeTranslation(0, 134);
        self.additionalInfoView.transform = CGAffineTransformMakeTranslation(0, 134);
        self.pickupView.transform = CGAffineTransformMakeTranslation(0, 134);
        self.destinationView.transform = CGAffineTransformMakeTranslation(0, 134);
    } completion:^(BOOL finished) {
        self.isShowingAddresses = NO;
        self.destinationArrow.hidden = YES;
        self.pickupArrow.hidden = YES;
        [UIView transitionWithView:self.timerView
                          duration:0.25
                           options:UIViewAnimationOptionTransitionFlipFromBottom
                        animations:^{
                            self.timerView.hidden = NO;
                            self.toggleInformationButton.hidden = NO;
                        } completion:^(BOOL finished) {
                        }];
    }];
    
    [self zoomToLocation:PICKUP_ANNOTATION];
}

- (IBAction)toggleInformation {
    if (self.isShowingAddresses) {
        [UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
            CGAffineTransform rotation2 = CGAffineTransformRotate(self.toggleInformationButton.transform, DEGREES_TO_RADIANS(1080));
            CGAffineTransform translation2 = CGAffineTransformMakeTranslation(0, 134);
            self.toggleInformationButton.transform = CGAffineTransformConcat(rotation2, translation2);
            [self.toggleInformationButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];

            self.toolbar.transform = CGAffineTransformTranslate(self.toolbar.transform, 0, 134);
            self.additionalInfoView.transform = CGAffineTransformTranslate(self.additionalInfoView.transform, 0, 134);
            self.pickupView.transform = CGAffineTransformTranslate(self.pickupView.transform, 0, 134);
            self.destinationView.transform = CGAffineTransformTranslate(self.destinationView.transform, 0, 134);
            self.timerView.transform = CGAffineTransformTranslate(self.timerView.transform, 0, 134);
        } completion:^(BOOL finished) {
            self.isShowingAddresses = NO;
        }];
    } else {
        [UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
            CGAffineTransform rotation = CGAffineTransformRotate(self.toggleInformationButton.transform, DEGREES_TO_RADIANS(1080));
            CGAffineTransform translation = CGAffineTransformTranslate(self.toggleInformationButton.transform, 0, -134);
            self.toggleInformationButton.transform = CGAffineTransformConcat(rotation, translation);
            [self.toggleInformationButton setImage:[UIImage imageNamed:@"minus"] forState:UIControlStateNormal];
            
            self.toolbar.transform = CGAffineTransformTranslate(self.toolbar.transform, 0, -134);
            self.additionalInfoView.transform = CGAffineTransformTranslate(self.additionalInfoView.transform, 0, -134);
            self.pickupView.transform = CGAffineTransformTranslate(self.pickupView.transform, 0, -134);
            self.destinationView.transform = CGAffineTransformTranslate(self.destinationView.transform, 0, -134);
            self.timerView.transform = CGAffineTransformTranslate(self.timerView.transform, 0, -134);
        } completion:^(BOOL finished) {
            self.isShowingAddresses = YES;
        }];
    }
}

- (void)animateButtonsToLeft:(int)steps {
    [self.view bringSubviewToFront:self.makeReservationButton];
    [self.view bringSubviewToFront:self.editButton];
    [self.view bringSubviewToFront:self.cancelButton];
    [self.view bringSubviewToFront:self.continueButton];
    [self.view bringSubviewToFront:self.searchContainer];
    [self.view bringSubviewToFront:self.settingsContainer];
    
    [UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
        self.continueButton.transform = CGAffineTransformTranslate(self.continueButton.transform, steps * (-320), 0);
        self.makeReservationButton.transform = CGAffineTransformTranslate(self.makeReservationButton.transform, steps * (-320), 0);
        self.cancelButton.transform = CGAffineTransformTranslate(self.cancelButton.transform, steps * (-320), 0);
        self.editButton.transform = CGAffineTransformTranslate(self.editButton.transform, steps * (-320), 0);
    } completion:^(BOOL finished) {
    }];
}

- (void)animateButtonsToRight:(int)steps {
    [self.view bringSubviewToFront:self.makeReservationButton];
    [self.view bringSubviewToFront:self.editButton];
    [self.view bringSubviewToFront:self.cancelButton];
    [self.view bringSubviewToFront:self.continueButton];
    [self.view bringSubviewToFront:self.searchContainer];
    [self.view bringSubviewToFront:self.settingsContainer];

    [UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
        self.continueButton.transform = CGAffineTransformTranslate(self.continueButton.transform, steps * 320, 0);
        self.makeReservationButton.transform = CGAffineTransformTranslate(self.makeReservationButton.transform, steps * 320, 0);
        self.cancelButton.transform = CGAffineTransformTranslate(self.cancelButton.transform, steps * 320, 0);
        self.editButton.transform = CGAffineTransformTranslate(self.editButton.transform, steps * 320, 0);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)clickedEdit:(id)sender {
    [self animateButtonsToRight:1];
    
    for (id<MKAnnotation> annotation in self.mapView.annotations){
        MKAnnotationView* view = [self.mapView viewForAnnotation: annotation];
        if (view){
            [view setDraggable:YES];
        }
    }
    
    [UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
        self.destinationArrow.transform = CGAffineTransformTranslate(self.destinationArrow.transform, -100, 0);
        self.pickupArrow.transform = CGAffineTransformTranslate(self.pickupArrow.transform, -100, 0);
    } completion:^(BOOL finished) {
        self.destinationButton.enabled = YES;
        self.pickupButton.enabled = YES;
    }];
    
}

- (IBAction)clickedCancel:(id)sender {
    [self animateButtonsToRight:2];
    
    for (id<MKAnnotation> annotation in self.mapView.annotations){
        MKAnnotationView* view = [self.mapView viewForAnnotation: annotation];
        if (view){
            [view setDraggable:YES];
        }
    }
    
    if (self.isShowingAddresses)
        [self toggleInformation];
    
    [UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
        
        self.toolbar.transform = CGAffineTransformTranslate(self.toolbar.transform, 0, -134);
        self.additionalInfoView.transform = CGAffineTransformTranslate(self.additionalInfoView.transform, 0, -134);
        self.pickupView.transform = CGAffineTransformTranslate(self.pickupView.transform, 0, -134);
        self.destinationView.transform = CGAffineTransformTranslate(self.destinationView.transform, 0, -134);
        self.isShowingAddresses = NO;
        self.destinationArrow.hidden = NO;
        self.pickupArrow.hidden = NO;
        self.timerView.hidden = YES;
        self.toggleInformationButton.hidden = YES;
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
            self.destinationArrow.transform = CGAffineTransformTranslate(self.destinationArrow.transform, -100, 0);
            self.pickupArrow.transform = CGAffineTransformTranslate(self.pickupArrow.transform, -100, 0);
        } completion:^(BOOL finished) {
            self.destinationButton.enabled = YES;
            self.pickupButton.enabled = YES;
        }];
    }];
    
    [self fitRegionToRoute];
}

@end

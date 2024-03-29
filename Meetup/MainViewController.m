//
//  MainViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2013-11-18.
//  Copyright (c) 2013 Cabit. All rights reserved.
//

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
#define IS_OS_8_OR_LATER \
    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPHONE_5                                                           \
    (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < \
     DBL_EPSILON)

#import "MainViewController.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "SettingsViewController.h"
#import "SearchViewController.h"
#import "SPGooglePlacesAutocomplete.h"
#import "MapAnnotation.h"
#import "TutorialViewController.h"
#import "DACircularProgressView.h"
#import "SettingsHelper.h"
#import "Reachability.h"
#import "VerificationViewController.h"
#import "KLCPopup.h"
#import "PopupViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@interface MainViewController ()

@property(nonatomic, strong) MapAnnotation *destinationAnnotation;
@property(nonatomic, strong) MapAnnotation *pickupAnnotation;
@property(nonatomic, strong) MKMapItem *pickupMapItem;
@property(nonatomic, strong) MKMapItem *destinationMapItem;

@property(nonatomic, retain) CLLocation *initialLocation;
@property(nonatomic, strong) CLGeocoder *geoCoder;

@property(strong, nonatomic) IBOutlet UIButton *continueButton;
@property(strong, nonatomic)
    IBOutlet UIActivityIndicatorView *activityIndicator;
@property(strong, nonatomic)
    IBOutlet UIActivityIndicatorView *destinationActivityIndicator;

@property(nonatomic) bool shouldAnimateBottomView;
@property(nonatomic, strong) UIToolbar *tintView;
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UILabel *searchLabel;
@property(strong, nonatomic) NSMutableArray *data;
@property(strong, nonatomic) MKLocalSearchRequest *localSearchRequest;
@property(strong, nonatomic) MKLocalSearch *localSearch;
@property(strong, nonatomic) IBOutlet UIButton *menuButton;
@property(strong, nonatomic) IBOutlet UIView *credentialsContainer;
@property(strong, nonatomic) IBOutlet UIView *settingsContainer;
@property(strong, nonatomic) IBOutlet UIView *searchContainer;
@property(strong, nonatomic) IBOutlet UIView *tutorialContainer;
@property(nonatomic) bool isSearchingForPickup;
@property(strong, nonatomic) IBOutlet UIView *verificationsContainer1;

@property(strong, nonatomic) IBOutlet UIView *destinationView;
@property(strong, nonatomic) IBOutlet UIView *pickupView;
@property(strong, nonatomic) IBOutlet UIImageView *destinationArrow;
@property(strong, nonatomic) IBOutlet UIButton *destinationButton;
@property(strong, nonatomic) IBOutlet UIButton *pickupButton;
@property(strong, nonatomic) IBOutlet UILabel *destinationStaticLabel;
@property(strong, nonatomic) IBOutlet UIImageView *pickupArrow;

@property(strong, nonatomic) IBOutlet UIView *additionalInfoView;

@property(strong, nonatomic) IBOutlet UILabel *travelTimeLabel;
@property(strong, nonatomic) IBOutlet UILabel *priceLabel;
@property(strong, nonatomic) UIToolbar *toolbar;
@property(nonatomic) BOOL isShowingAddresses;
@property(strong, nonatomic) IBOutlet UIView *addressToolbar;
@property(strong, nonatomic) NSTimer *timer;

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(strong, nonatomic) IBOutlet UIView *statusView;
@property(strong, nonatomic) IBOutlet UILabel *statusLabel;
@property(strong, nonatomic) IBOutlet UIView *connection_loss_container;
@property(nonatomic) Reachability *hostReachability;
@property(nonatomic, strong) NSString *reservationId;
@property(nonatomic, strong) NSTimer *updateTimer;
@property(nonatomic, strong) NSTimer *updateTimerAfterwards;
@property(strong, nonatomic) IBOutlet UIView *popupContainer;
@property(strong, nonatomic) KLCPopup *popup;
@property(strong, nonatomic) NSString *message;
@property(strong, nonatomic) PopupViewController *popupViewController;
@property(strong, nonatomic) NSString *vehicleNbr;
@property(strong, nonatomic) UIView *popupContainer2;
@property(nonatomic) BOOL haveRecievedPrice;
@property(nonatomic) BOOL isValidOrigin;
@property(nonatomic) BOOL isValidDestination;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isValidOrigin = NO;
    self.isValidDestination = NO;
    self.haveRecievedPrice = NO;
    [[BookingHTTPClient sharedBookingHTTPClient] setDelegate:self];
    [self.mapView setDelegate:self];
    self.data = [[NSMutableArray alloc] init];

    self.additionalInfoView.hidden = YES;

    self.geoCoder = [[CLGeocoder alloc] init];
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 118)];
    [self.addressToolbar addSubview:self.toolbar];

    UIToolbar *toolbar2 =
        [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 68)];
    [self.additionalInfoView addSubview:toolbar2];

    for (UIView *subview in self.additionalInfoView.subviews) {
        if (!([subview isKindOfClass:[UIToolbar class]]))
            [self.additionalInfoView bringSubviewToFront:subview];
    }

    [self.view bringSubviewToFront:self.pickupView];
    [self.view bringSubviewToFront:self.destinationView];
    [self.view bringSubviewToFront:self.additionalInfoView];

    [self.navigationController.navigationBar setTitleTextAttributes:@{
            [UIFont fontWithName : @"OpenSans" size : 21] : NSFontAttributeName
    }];

    self.tintView = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    self.tintView.barTintColor =
        [UIColor colorWithRed:0.196 green:0.235 blue:0.313 alpha:0.6];
    self.tintView.autoresizingMask = self.view.autoresizingMask;
    self.tintView.alpha = 0.0;
    [self.view addSubview:self.tintView];

    self.credentialsContainer.alpha = 0.0;
    self.tutorialContainer.alpha = 0.0;
    self.verificationsContainer1.alpha = 0.0;
    self.connection_loss_container.alpha = 0.0;

    [self.destinationStaticLabel
        setFont:[UIFont fontWithName:@"OpenSans" size:12]];

    [self.pickupButton.titleLabel
        setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    [self.destinationButton.titleLabel
        setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    [self.statusLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];

    self.tintView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;

    if (![[SettingsHelper sharedSettingsHelper] checkVerifiedUser])
        [self showVerificationViewReoccuring:NO];

    [NSTimer
        scheduledTimerWithTimeInterval:1
                                target:self
                              selector:@selector(didBeginTouchAtPickupButton)
                              userInfo:nil
                               repeats:NO];
    [NSTimer
        scheduledTimerWithTimeInterval:1.2
                                target:self
                              selector:@selector(
                                           didBeginTouchAtDestinationButton)
                              userInfo:nil
                               repeats:NO];

    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification
     is posted, the method reachabilityChanged will be called.
     */
    /*[[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(reachabilityChanged:)
               name:kReachabilityChangedNotification
             object:nil];
*/

    self.popup = [KLCPopup popupWithContentView:self.popupContainer
                                       showType:KLCPopupShowTypeBounceIn
                                    dismissType:KLCPopupDismissTypeBounceOut
                                       maskType:KLCPopupMaskTypeDimmed
                       dismissOnBackgroundTouch:NO
                          dismissOnContentTouch:NO];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (NSAttributedString *)attributedFontForValue:(NSString *)value
                                       andUnit:(NSString *)unit {
    NSMutableAttributedString *string =
        [[NSMutableAttributedString alloc] initWithString:@""];
    UIFont *largeFont = [UIFont fontWithName:@"OpenSans-Light" size:36];
    UIFont *smallFont = [UIFont fontWithName:@"OpenSans" size:16];
    UIColor *color = [UIColor colorWithRed:69.0f / 255.0f
                                     green:77.0f / 255.0f
                                      blue:95.0f / 255.0f
                                     alpha:1];

    NSDictionary *largeAttributes = @{
        NSFontAttributeName : largeFont,
        NSForegroundColorAttributeName : color
    };
    NSDictionary *smallAttributes = @{
        NSFontAttributeName : smallFont,
        NSForegroundColorAttributeName : color
    };

    NSAttributedString *subString =
        [[NSAttributedString alloc] initWithString:value
                                        attributes:largeAttributes];
    [string appendAttributedString:subString];
    NSAttributedString *subString2 =
        [[NSAttributedString alloc] initWithString:unit
                                        attributes:smallAttributes];
    [string appendAttributedString:subString2];
    return string;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self hideSearchView];
}

- (void)viewWillAppear:(BOOL)animated {
    self.mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.mapView.delegate = nil;
}

/*
 *  Not used at the moment. Is needed if there should be a locate button after
 * the user changes to another origin adress.
 */
- (IBAction)clickedLocate {
    CLLocationCoordinate2D myCoord = {
        self.mapView.userLocation.location.coordinate.latitude,
        self.mapView.userLocation.location.coordinate.longitude};
    [self setPickupLocation:myCoord];
    [self zoomToUserLocation];
    [self calculateUserAddress];
}

- (void)calculateUserAddress {
    [self.activityIndicator startAnimating];
    [self.geoCoder
        reverseGeocodeLocation:self.mapView.userLocation.location
             completionHandler:^(NSArray *placemarks, NSError *error) {
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 NSString *parsedAddress =
                     [self parseAddress:[placemark.addressDictionary
                                            valueForKey:@"Name"]];
                 [self.pickupButton setTitle:parsedAddress
                                    forState:UIControlStateNormal];
                 [self.activityIndicator stopAnimating];
                 [self setPickupMapItem:
                           [[MKMapItem alloc]
                               initWithPlacemark:
                                   [[MKPlacemark alloc]
                                       initWithPlacemark:placemark]]];
                 [self setPickupLocation:placemark.location.coordinate];
             }];
}

- (void)calculatePinAddressForLocation:(CLLocation *)location
                            andPinType:(NSString *)pinType {
    if ([pinType isEqualToString:PICKUP_ANNOTATION]) {
        [self.geoCoder
            reverseGeocodeLocation:location
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     CLPlacemark *placemark = [placemarks objectAtIndex:0];
                     NSString *parsedAddress =
                         [self parseAddress:[placemark.addressDictionary
                                                valueForKey:@"Name"]];
                     [self.pickupButton setTitle:parsedAddress
                                        forState:UIControlStateNormal];
                     [self setPickupMapItem:
                               [[MKMapItem alloc]
                                   initWithPlacemark:
                                       [[MKPlacemark alloc]
                                           initWithPlacemark:placemark]]];
                     [self setPickupLocation:placemark.location.coordinate];
                 }];
    } else if ([pinType isEqualToString:DESTINATION_ANNOTATION]) {
        [self.geoCoder
            reverseGeocodeLocation:location
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     CLPlacemark *placemark = [placemarks objectAtIndex:0];
                     NSString *parsedAddress =
                         [self parseAddress:[placemark.addressDictionary
                                                valueForKey:@"Name"]];
                     [self.destinationButton setTitle:parsedAddress
                                             forState:UIControlStateNormal];
                     [self setDestinationMapItem:
                               [[MKMapItem alloc]
                                   initWithPlacemark:
                                       [[MKPlacemark alloc]
                                           initWithPlacemark:placemark]]];
                     [self setDestination:placemark.location.coordinate];
                 }];
    }
}

- (void)setPickupLocation:(CLLocationCoordinate2D)location {
    if (!self.pickupAnnotation)
        self.pickupAnnotation = [[MapAnnotation alloc] init];
    self.pickupAnnotation.typeOfAnnotation = PICKUP_ANNOTATION;
    self.pickupAnnotation.coordinate = location;
    [self.mapView addAnnotation:self.pickupAnnotation];
    [self zoomToLocation:PICKUP_ANNOTATION];

    if (self.destinationMapItem) {
        [self generateRoute];
        [[BookingHTTPClient sharedBookingHTTPClient]
            getPriceFrom:self.pickupMapItem.placemark.coordinate
                      to:self.destinationMapItem.placemark.coordinate];
        [self.priceLabel
            setAttributedText:
                [self attributedFontForValue:@"" andUnit:@"Beräknar pris..."]];
    }
}

- (void)setDestination:(CLLocationCoordinate2D)location {
    if (!self.destinationAnnotation)
        self.destinationAnnotation = [[MapAnnotation alloc] init];
    self.destinationAnnotation.typeOfAnnotation = DESTINATION_ANNOTATION;
    self.destinationAnnotation.coordinate = location;
    [self.mapView addAnnotation:self.destinationAnnotation];
    [self zoomToLocation:DESTINATION_ANNOTATION];

    [self generateRoute];
    [[BookingHTTPClient sharedBookingHTTPClient]
        getPriceFrom:self.pickupMapItem.placemark.coordinate
                  to:self.destinationMapItem.placemark.coordinate];
    [self.priceLabel
        setAttributedText:[self attributedFontForValue:@""
                                               andUnit:@"Beräknar pris..."]];
}

- (void)zoomToUserLocation {
    if (!self.mapView.userLocation) return;

    if (!self.mapView.userLocation.location)
        NSLog(@"Location not obtained just yet");
    return;

    NSTimeInterval locationAgeInSeconds = [[NSDate date]
        timeIntervalSinceDate:self.mapView.userLocation.location.timestamp];
    if (locationAgeInSeconds > 300) {
        NSLog(@"Location data is too old");
        return;
    }

    if (!CLLocationCoordinate2DIsValid(self.mapView.userLocation.coordinate)) {
        NSLog(@"userlocation coordinate is invalid");
        return;
    }

    MKCoordinateRegion region;
    region.center = self.mapView.userLocation.location.coordinate;

    region.span = MKCoordinateSpanMake(0.01, 0.01);
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

- (void)zoomToLocation:(NSString *)locationType {
    // MKCoordinateRegion region;
    MKMapPoint annotationPoint;
    if ([locationType isEqualToString:PICKUP_ANNOTATION]) {
        // region.center = self.pickupAnnotation.coordinate;
        annotationPoint =
            MKMapPointForCoordinate(self.pickupAnnotation.coordinate);
    } else if ([locationType isEqualToString:DESTINATION_ANNOTATION]) {
        // region.center = self.destinationAnnotation.coordinate;
        annotationPoint =
            MKMapPointForCoordinate(self.destinationAnnotation.coordinate);
    }
    // region.span = MKCoordinateSpanMake(0.01, 0.01);
    // region = [self.mapView regionThatFits:region];

    MKMapRect zoomRect =
        MKMapRectMake(annotationPoint.x, annotationPoint.y, 1, 1);

    double inset = -zoomRect.size.width * 1;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(40, 40, 450, 40);
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset)
                        edgePadding:edgeInsets
                           animated:YES];
}

- (void)mapView:(MKMapView *)mapView
    didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.initialLocation) {
        MKCoordinateRegion region;
        region.center = userLocation.coordinate;
        // Region to show when app is loaded
        region.span = MKCoordinateSpanMake(0.04, 0.04);
        region = [mapView regionThatFits:region];

        if (!CLLocationCoordinate2DIsValid(userLocation.coordinate)) {
            // do nothing, invalid regions
            NSLog(@"Invalid regions");
        } else if (region.span.latitudeDelta <= 0.0 ||
                   region.span.longitudeDelta <= 0.0) {
            NSLog(@"Invalid regions");
        } else {
            [self calculateUserAddress];
            self.initialLocation = userLocation.location;
            [mapView setRegion:region animated:YES];
            // Set initial pickup location to current position
            //[self
            // setPickupLocation:self.mapView.userLocation.location.coordinate];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id)annotation {
    MKAnnotationView *customAnnotationView;
    if ([annotation isKindOfClass:[MapAnnotation class]]) {
        MapAnnotation *theAnnotation = (MapAnnotation *)annotation;
        customAnnotationView =
            [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                            reuseIdentifier:nil];
        [customAnnotationView setDraggable:YES];
        [customAnnotationView setCanShowCallout:NO];
        UIImage *pinImage = nil;
        if ([[theAnnotation typeOfAnnotation]
                isEqualToString:PICKUP_ANNOTATION]) {
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

- (void)mapView:(MKMapView *)mapView
        annotationView:(MKAnnotationView *)annotationView
    didChangeDragState:(MKAnnotationViewDragState)newState
          fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        MapAnnotation *theAnnotation =
            (MapAnnotation *)annotationView.annotation;
        if ([theAnnotation.typeOfAnnotation
                isEqualToString:PICKUP_ANNOTATION]) {
            CLLocation *location = [[CLLocation alloc]
                initWithLatitude:theAnnotation.coordinate.latitude
                       longitude:theAnnotation.coordinate.longitude];
            [self calculatePinAddressForLocation:location
                                      andPinType:PICKUP_ANNOTATION];
        } else if ([theAnnotation.typeOfAnnotation
                       isEqualToString:DESTINATION_ANNOTATION]) {
            CLLocation *location = [[CLLocation alloc]
                initWithLatitude:theAnnotation.coordinate.latitude
                       longitude:theAnnotation.coordinate.longitude];
            [self calculatePinAddressForLocation:location
                                      andPinType:DESTINATION_ANNOTATION];
        }
    }
}

#pragma mark Directions

- (void)generateRoute {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];

    if (self.pickupMapItem) {
        request.source = self.pickupMapItem;
    }

    request.destination = self.destinationMapItem;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

    [directions
        calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *
                                                       response,
                                                   NSError *error) {
            if (error) {
                NSLog(@"Error is %@", error);
                // Handle error
            } else {
                NSTimeInterval expectedTravelTime =
                    [response.routes[0] expectedTravelTime];
                int minutes = floor(expectedTravelTime / 60);
                self.travelTimeLabel.attributedText = [self
                    attributedFontForValue:[NSString
                                               stringWithFormat:@"%d", minutes]
                                   andUnit:@"min"];
                [self showRoute:response];
            }
        }];
}

- (void)showRoute:(MKDirectionsResponse *)response {
    [UIView animateKeyframesWithDuration:0.5
        delay:0
        options:0
        animations:^{
            [self.mapView removeOverlays:self.mapView.overlays];

            // TODO: is this right?
            for (MKRoute *route in response.routes) {
                [self.mapView addOverlay:route.polyline
                                   level:MKOverlayLevelAboveRoads];
            }
        }
        completion:^(BOOL finished) {}];

    [UIView transitionWithView:self.additionalInfoView
        duration:0.4
        options:UIViewAnimationOptionTransitionFlipFromBottom
        animations:^{
            //  Set the new image
            //  Since its done in animation block, the change will be animated
            self.additionalInfoView.hidden = NO;
        }
        completion:^(BOOL finished) {
                       //  Do whatever when the animation is finished
                   }];

    /*
    //self.additionalInfoView.transform = CGAffineTransformMakeTranslation(0,
    100);
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        self.additionalInfoView.transform = CGAffineTransformMakeTranslation(0,
    -300);
    } completion:^(BOOL finished) { }];
     */
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.alpha = 0.7;
    renderer.lineWidth = 4.0;

    return renderer;
}

- (void)fitRegionToRoute {
    MKMapRect zoomRect = MKMapRectNull;
    NSArray *routeAnnotations = [[NSArray alloc] init];

    MKPointAnnotation *userAnnotation = [[MKPointAnnotation alloc] init];
    [userAnnotation setCoordinate:self.mapView.userLocation.coordinate];
    // routeAnnotations = [routeAnnotations
    // arrayByAddingObject:self.mapView.userLocation];
    routeAnnotations =
        [routeAnnotations arrayByAddingObject:self.destinationAnnotation];
    routeAnnotations =
        [routeAnnotations arrayByAddingObject:self.pickupAnnotation];

    for (id<MKAnnotation> annotation in routeAnnotations) {
        MKMapPoint annotationPoint =
            MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect =
            MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    double inset = -zoomRect.size.width * 1;
    UIEdgeInsets edgeInsets;
    if (IS_IPHONE_5)
        edgeInsets = UIEdgeInsetsMake(40, 40, 250, 40);
    else
        edgeInsets = UIEdgeInsetsMake(40, 40, 450, 40);

    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset)
                        edgePadding:edgeInsets
                           animated:YES];
}

#pragma Animation

- (CAKeyframeAnimation *)dockBounceAnimationWithIconHeight:(CGFloat)iconHeight {
    CGFloat factors[32] = {0,   32, 60, 83, 100, 114, 124, 128, 128, 124, 114,
                           100, 83, 60, 32, 0,   24,  42,  54,  62,  64,  62,
                           54,  42, 24, 0,  18,  28,  32,  28,  18,  0};

    NSMutableArray *values = [NSMutableArray array];

    for (int i = 0; i < 32; i++) {
        CGFloat positionOffset = factors[i] / 128.0f * iconHeight;

        CATransform3D transform =
            CATransform3DMakeTranslation(-positionOffset, 0, 0);
        [values addObject:[NSValue valueWithCATransform3D:transform]];
    }

    CAKeyframeAnimation *animation =
        [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.repeatCount = 1;
    animation.duration = 32.0f / 30.0f;
    animation.fillMode = kCAFillModeForwards;
    animation.values = values;
    animation.removedOnCompletion =
        YES;  // final stage is equal to starting stage
    animation.autoreverses = NO;

    return animation;
}

- (IBAction)showPickupSearchView {
    self.isSearchingForPickup = YES;
    [self showSearchView];
}

- (IBAction)showDestinationSearchView {
    self.isSearchingForPickup = NO;
    [self showSearchView];
}

#pragma settings

- (void)hideSettingsView {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.15
                     animations:^(void) {

                         self.navigationController.navigationBar.alpha = 1.0;

                         self.settingsContainer.alpha = 0.0;
                         self.tintView.alpha = 0.0;
                         [[UIApplication sharedApplication]
                             setStatusBarStyle:UIStatusBarStyleDefault];
                     }];
}

- (IBAction)showSettingsView {
    [self.view bringSubviewToFront:self.settingsContainer];
    SettingsViewController *settingsViewController =
        (SettingsViewController *)self.childViewControllers[2];
    [settingsViewController
        setUserLocation:self.mapView.userLocation.location.coordinate];
    [UIView animateWithDuration:0.15
                     animations:^{

                         self.navigationController.navigationBar.alpha = 0.0;
                         self.settingsContainer.alpha = 1.0;
                         self.tintView.alpha = 1.0;
                         [[UIApplication sharedApplication]
                             setStatusBarStyle:UIStatusBarStyleLightContent];
                     }];
}

#pragma tutorial

- (void)hideTutorialView {
    [UIView animateWithDuration:0.15
                     animations:^(void) {
                         [[UIApplication sharedApplication]
                             setStatusBarHidden:NO
                                  withAnimation:UIStatusBarAnimationSlide];
                         self.tutorialContainer.alpha = 0.0;
                         self.tintView.alpha = 0.0;
                     }];
}

- (IBAction)showTutorialView {
    TutorialViewController *viewController =
        (TutorialViewController *)self.childViewControllers[3];
    [viewController beginAnimations];

    [self.view bringSubviewToFront:self.tutorialContainer];
    [UIView animateWithDuration:0.15
                     animations:^{
                         [[UIApplication sharedApplication]
                             setStatusBarHidden:YES
                                  withAnimation:UIStatusBarAnimationSlide];

                         self.navigationController.navigationBar.alpha = 0.0;
                         self.tutorialContainer.alpha = 1.0;
                         self.tintView.alpha = 1.0;
                     }];
}

#pragma connection_loss

- (void)hideConnectionLossView {
    [UIView animateWithDuration:0.15
                     animations:^(void) {
                         [[UIApplication sharedApplication]
                             setStatusBarHidden:NO
                                  withAnimation:UIStatusBarAnimationSlide];
                         self.connection_loss_container.alpha = 0.0;
                         self.tintView.alpha = 0.0;
                     }];
}

- (IBAction)showConnectionLossView {
    [self.view bringSubviewToFront:self.connection_loss_container];
    [UIView animateWithDuration:0.15
                     animations:^{
                         [[UIApplication sharedApplication]
                             setStatusBarHidden:YES
                                  withAnimation:UIStatusBarAnimationSlide];

                         self.navigationController.navigationBar.alpha = 0.0;
                         self.connection_loss_container.alpha = 1.0;
                         self.tintView.alpha = 1.0;
                     }];
}

#pragma verification

- (IBAction)showVerificationViewReoccuring:(bool)reoccuring {
    VerificationViewController *viewController =
        (VerificationViewController *)self.childViewControllers[0];
    if (reoccuring) {
        [viewController setMessage:@"Snart där..."];
    }
    [self.view bringSubviewToFront:self.verificationsContainer1];
    [UIView animateWithDuration:0.15
                     animations:^{
                         [[UIApplication sharedApplication]
                             setStatusBarHidden:YES
                                  withAnimation:UIStatusBarAnimationSlide];

                         self.navigationController.navigationBar.alpha = 0.0;
                         self.verificationsContainer1.alpha = 1.0;
                         self.tintView.alpha = 1.0;
                     }];
}

- (void)hideVerificationView {
    [self.view endEditing:YES];

    if ([self isFirstRun]) {
        [UIView animateWithDuration:0.15
                         animations:^(void) {
                             self.verificationsContainer1.alpha = 0.0;
                             [[UIApplication sharedApplication]
                                 setStatusBarStyle:UIStatusBarStyleDefault];
                         }];
        if (IS_IPHONE_5) [self showTutorialView];
    } else {
        [UIView animateWithDuration:0.15
                         animations:^(void) {
                             self.verificationsContainer1.alpha = 0.0;
                             self.tintView.alpha = 0.0;
                             [[UIApplication sharedApplication]
                                 setStatusBarStyle:UIStatusBarStyleDefault];
                         }];
    }
}

#pragma search

- (void)showSearchView {
    [self.view bringSubviewToFront:self.searchContainer];
    [UIView animateWithDuration:0.15
                     animations:^{
                         self.searchContainer.alpha = 1.0;
                         self.tintView.alpha = 0.97;
                         [[UIApplication sharedApplication]
                             setStatusBarStyle:UIStatusBarStyleLightContent];
                     }];
    SearchViewController *searchViewController =
        (SearchViewController *)self.childViewControllers[2];
    if (self.isSearchingForPickup)
        [searchViewController
            setActiveWithLabel:@"Upphämtning"
               andUserLocation:self.mapView.userLocation.coordinate];
    else
        [searchViewController
            setActiveWithLabel:@"Destination"
               andUserLocation:self.mapView.userLocation.coordinate];
}

- (void)hideSearchView {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.15
                     animations:^(void) {
                         self.tintView.alpha = 0.0;
                         self.searchContainer.alpha = 0.0;
                         [[UIApplication sharedApplication]
                             setStatusBarStyle:UIStatusBarStyleDefault];
                     }];
}

- (void)didFinishSearchWithAdress:(SPGooglePlacesAutocompletePlace *)mapItem {
    NSString *parsedAddress = [self parseAddress:mapItem.name];
    if (self.isSearchingForPickup) {
        [mapItem resolveToPlacemark:^(CLPlacemark *placemark,
                                      NSString *addressString, NSError *error) {
            MKPlacemark *mkPlacemark =
                [[MKPlacemark alloc] initWithPlacemark:placemark];
            [[BookingHTTPClient sharedBookingHTTPClient]
                validateAddress:mkPlacemark
                       isOrigin:YES];
        }];
        [self.pickupButton setTitle:parsedAddress
                           forState:UIControlStateNormal];
    } else {
        [self.destinationActivityIndicator startAnimating];
        [mapItem resolveToPlacemark:^(CLPlacemark *placemark,
                                      NSString *addressString, NSError *error) {
            MKPlacemark *mkPlacemark =
                [[MKPlacemark alloc] initWithPlacemark:placemark];
            [[BookingHTTPClient sharedBookingHTTPClient]
                validateAddress:mkPlacemark
                       isOrigin:NO];
        }];
        [self.destinationButton setTitle:parsedAddress
                                forState:UIControlStateNormal];
    }
}

- (NSString *)parseAddress:(NSString *)address {
    NSArray *addressComponents = [address componentsSeparatedByString:@","];
    NSString *parsedAddress =
        [NSString stringWithFormat:@"%@", [addressComponents objectAtIndex:0]];
    return parsedAddress;
}

- (IBAction)didBeginTouchAtPickupButton {
    [self performPopAnimationOnView:self.pickupArrow duration:0.3 delay:0];
}

- (IBAction)didBeginTouchAtDestinationButton {
    [self performPopAnimationOnView:self.destinationArrow duration:0.3 delay:0];
}

- (void)performShakeAnimationOnView:(UIView *)view
                           duration:(NSTimeInterval)duration
                              delay:(NSTimeInterval)delay {
    // Start
    view.transform = CGAffineTransformMakeTranslation(0, 0);
    [UIView animateKeyframesWithDuration:duration / 5
        delay:delay
        options:0
        animations:^{
            // End
            view.transform = CGAffineTransformMakeTranslation(14, 0);
        }
        completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration / 5
                delay:0
                options:0
                animations:^{
                    // End
                    view.transform = CGAffineTransformMakeTranslation(-14, 0);
                }
                completion:^(BOOL finished) {
                    [UIView animateKeyframesWithDuration:duration / 5
                        delay:0
                        options:0
                        animations:^{
                            // End
                            view.transform =
                                CGAffineTransformMakeTranslation(7, 0);
                        }
                        completion:^(BOOL finished) {
                            [UIView animateKeyframesWithDuration:duration / 5
                                delay:0
                                options:0
                                animations:^{
                                    // End
                                    view.transform =
                                        CGAffineTransformMakeTranslation(-7, 0);
                                }
                                completion:^(BOOL finished) {
                                    [UIView
                                        animateKeyframesWithDuration:duration /
                                                                     5
                                        delay:0
                                        options:0
                                        animations:^{
                                            // End
                                            view.transform =
                                                CGAffineTransformMakeTranslation(
                                                    0, 0);
                                        }
                                        completion:^(BOOL finished) {// End
                                                   }];
                                }];
                        }];
                }];
        }];
}

- (void)performSlideRightAnimationOnView:(UIView *)view
                                duration:(NSTimeInterval)duration
                                   delay:(NSTimeInterval)delay {
    // Start
    view.transform = CGAffineTransformMakeTranslation(0, 0);
    [UIView animateKeyframesWithDuration:duration
        delay:delay
        options:0
        animations:^{
            // End
            view.transform = CGAffineTransformMakeTranslation(100, 0);
        }
        completion:^(BOOL finished) {}];
}

- (void)performPopAnimationOnView:(UIView *)view
                         duration:(NSTimeInterval)duration
                            delay:(NSTimeInterval)delay {
    // Start
    view.transform = CGAffineTransformMakeScale(1, 1);
    CGRectApplyAffineTransform(view.frame, CGAffineTransformMakeScale(1, 1));
    [UIView animateKeyframesWithDuration:duration / 3
        delay:delay
        options:0
        animations:^{
            // End
            CGRectApplyAffineTransform(view.frame,
                                       CGAffineTransformMakeScale(1.2, 1.2));
            view.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }
        completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration / 3
                delay:0
                options:0
                animations:^{
                    // End
                    view.transform = CGAffineTransformMakeScale(0.9, 0.9);
                }
                completion:^(BOOL finished) {
                    [UIView animateKeyframesWithDuration:duration / 3
                        delay:0
                        options:0
                        animations:^{
                            // End
                            view.transform = CGAffineTransformMakeScale(1, 1);
                        }
                        completion:^(BOOL finished) {}];
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
    if (![[SettingsHelper sharedSettingsHelper] checkVerifiedUser]) {
        [self showVerificationViewReoccuring:YES];
        return;
    }
    if (!(self.pickupMapItem && self.destinationMapItem)) {
        [self performShakeAnimationOnView:self.destinationStaticLabel
                                 duration:0.3
                                    delay:0];
        return;
    }
    if (!self.haveRecievedPrice) {
        NSLog(@"Incorrect addresses!");
        return;
    } else {
        KLCPopupLayout layout = KLCPopupLayoutMake(
            KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutAboveCenter);
        self.popupViewController =
            (PopupViewController *)self.childViewControllers[5];
        [self.popupViewController
                 setOrigin:self.pickupButton.titleLabel.text
            andDestination:self.destinationButton.titleLabel.text];
        [self.popup showWithLayout:layout];
    }
}

- (NSMutableDictionary *)constructRequestDictionary {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    NSArray *seperatedPickupAddress = [self.pickupButton.titleLabel.text
        componentsSeparatedByCharactersInSet:[NSCharacterSet
                                                     whitespaceCharacterSet]];
    NSString *pickupNumber = [seperatedPickupAddress lastObject];

    for (int i = 0; i < [pickupNumber length]; i++) {
        NSLog(@"%hu", [pickupNumber characterAtIndex:i]);
        if ([pickupNumber characterAtIndex:i] == 8211) {
            pickupNumber = [pickupNumber substringToIndex:i];
        }
    }

    NSString *pickupStreet = [[self.pickupButton.titleLabel.text
        componentsSeparatedByCharactersInSet:
            [[NSCharacterSet letterCharacterSet] invertedSet]] objectAtIndex:0];
    parameters[@"fromStreetName"] = pickupStreet;
    parameters[@"fromStreetNumber"] = pickupNumber;

    NSArray *seperatedDestinationAddress =
        [self.destinationButton.titleLabel.text
            componentsSeparatedByCharactersInSet:
                [NSCharacterSet whitespaceCharacterSet]];
    NSString *destinationNumber = [seperatedDestinationAddress lastObject];

    for (int i = 0; i < [destinationNumber length]; i++) {
        NSLog(@"%hu", [destinationNumber characterAtIndex:i]);
        if ([destinationNumber characterAtIndex:i] == 8211) {
            destinationNumber = [destinationNumber substringToIndex:i];
        }
    }

    NSString *destinationStreet = [[self.destinationButton.titleLabel.text
        componentsSeparatedByCharactersInSet:
            [[NSCharacterSet letterCharacterSet] invertedSet]] objectAtIndex:0];

    parameters[@"toStreetName"] = destinationStreet;
    parameters[@"toStreetNumber"] = destinationNumber;

    parameters[@"fromLatitude"] =
        [NSString stringWithFormat:@"%f", self.pickupMapItem.placemark
                                              .coordinate.latitude];
    parameters[@"fromLongitude"] =
        [NSString stringWithFormat:@"%f", self.pickupMapItem.placemark
                                              .coordinate.longitude];
    parameters[@"toLatitude"] =
        [NSString stringWithFormat:@"%f", self.destinationMapItem.placemark
                                              .coordinate.latitude];
    parameters[@"toLongitude"] =
        [NSString stringWithFormat:@"%f", self.pickupMapItem.placemark
                                              .coordinate.longitude];
    parameters[@"provider"] = @"TAXINET";
    parameters[@"passengerName"] = [NSString
        stringWithFormat:@"%@", [[SettingsHelper sharedSettingsHelper] name]];
    NSString *phone = [NSString
        stringWithFormat:@"%@",
                         [[SettingsHelper sharedSettingsHelper] phoneNumber]];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];

    parameters[@"passengerPhone"] = phone;

    NSDateFormatter *dateformate = [[NSDateFormatter alloc] init];
    [dateformate setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    date = [date dateByAddingTimeInterval:300];
    NSString *date_string = [dateformate stringFromDate:date];
    parameters[@"pickupTime"] = [NSString stringWithFormat:@"%@", date_string];

    if (self.message) {
        parameters[@"message"] = self.message;
    } else {
        parameters[@"message"] = @"";
    }

    return parameters;
}

- (void)animateButtonsToLeft:(int)steps {
    [self.view bringSubviewToFront:self.continueButton];
    [self.view bringSubviewToFront:self.statusView];
    [self.view bringSubviewToFront:self.searchContainer];
    [self.view bringSubviewToFront:self.settingsContainer];
    [self.view bringSubviewToFront:self.connection_loss_container];

    [UIView animateKeyframesWithDuration:0.25
        delay:0
        options:0
        animations:^{
            self.continueButton.transform = CGAffineTransformTranslate(
                self.continueButton.transform, steps * (-320), 0);
            self.statusView.transform = CGAffineTransformTranslate(
                self.statusView.transform, steps * (-320), 0);
        }
        completion:^(BOOL finished) {}];
}

- (void)animateButtonsToRight:(int)steps {
    [self.view bringSubviewToFront:self.continueButton];
    [self.view bringSubviewToFront:self.statusView];
    [self.view bringSubviewToFront:self.searchContainer];
    [self.view bringSubviewToFront:self.settingsContainer];
    [self.view bringSubviewToFront:self.connection_loss_container];

    [UIView animateKeyframesWithDuration:0.25
        delay:0
        options:0
        animations:^{
            self.continueButton.transform = CGAffineTransformTranslate(
                self.continueButton.transform, steps * 320, 0);
            self.statusView.transform = CGAffineTransformTranslate(
                self.statusView.transform, steps * 320, 0);
        }
        completion:^(BOOL finished) {}];
}

- (IBAction)clickedEdit:(id)sender {
    [self animateButtonsToRight:1];

    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
        if (view) {
            [view setDraggable:YES];
        }
    }

    [UIView animateKeyframesWithDuration:0.25
        delay:0
        options:0
        animations:^{
            self.destinationArrow.transform = CGAffineTransformTranslate(
                self.destinationArrow.transform, -100, 0);
            self.pickupArrow.transform =
                CGAffineTransformTranslate(self.pickupArrow.transform, -100, 0);
        }
        completion:^(BOOL finished) {
            self.destinationButton.enabled = YES;
            self.pickupButton.enabled = YES;
        }];
}

- (bool)isFirstRun {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"isFirstRun"]) {
        return NO;
    }

    [defaults setObject:[NSDate date] forKey:@"isFirstRun"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    return YES;
}

- (void)setStatus:(NSString *)status {
    NSLog(@"Setting status to %@", status);
    NSString *statusText = @"";
    UIColor *statusColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    if ([status isEqualToString:@"Pending"]) {
        statusText = @"Letar efter taxibilar i närheten...";
        statusColor = [UIColor colorWithRed:240.0f / 255.0f
                                      green:179.0f / 255.0f
                                       blue:43.0f / 255.0f
                                      alpha:1];
    } else if ([status isEqualToString:@"Confirmed"]) {
        self.updateTimerAfterwards =
            [NSTimer scheduledTimerWithTimeInterval:300.0
                                             target:self
                                           selector:@selector(updateReservation)
                                           userInfo:nil
                                            repeats:YES];
        [self.updateTimer invalidate];
        if (self.vehicleNbr) {
            statusText = [NSString
                stringWithFormat:@"Bil %@ från Taxi Göteborg är på väg "
                                 @"till upphämtningsplatsen.",
                                 self.vehicleNbr];
        } else {
            statusText =
                [NSString stringWithFormat:@"En bil från Taxi Göteborg är på "
                          @"väg till upphämtningsplatsen."];
        }

        statusColor = [UIColor colorWithRed:0.0f / 255.0f
                                      green:181.0f / 255.0f
                                       blue:106.0f / 255.0f
                                      alpha:1];
    } else if ([status isEqualToString:@"Finished"]) {
        [self.updateTimer invalidate];
        [self.updateTimerAfterwards invalidate];
        statusText = @"En bil från Taxi Göteborg är på väg till "
            @"upphämtningsplatsen.";
        statusColor = [UIColor colorWithRed:240.0f / 255.0f
                                      green:179.0f / 255.0f
                                       blue:43.0f / 255.0f
                                      alpha:1];
        [self animateButtonsToRight:1];
        self.pickupButton.titleLabel.text = @"";
        self.destinationButton.titleLabel.text = @"";
        self.priceLabel.text = @"";
        self.travelTimeLabel.text = @"";

        [UIView animateKeyframesWithDuration:0.25
            delay:0
            options:0
            animations:^{
                self.destinationArrow.transform = CGAffineTransformTranslate(
                    self.destinationArrow.transform, -100, 0);
                self.pickupArrow.transform = CGAffineTransformTranslate(
                    self.pickupArrow.transform, -100, 0);
            }
            completion:^(BOOL finished) {
                self.destinationButton.enabled = YES;
                self.pickupButton.enabled = YES;
            }];
    }

    [UIView animateKeyframesWithDuration:0.25
        delay:0
        options:0
        animations:^{
            self.statusView.backgroundColor = statusColor;
            self.statusLabel.alpha = 0.0;
        }
        completion:^(BOOL finished) {
            self.statusLabel.text = statusText;
            [UIView animateKeyframesWithDuration:0.25
                delay:0
                options:0
                animations:^{
                    self.statusView.backgroundColor = statusColor;
                    self.statusLabel.alpha = 1.0;
                }
                completion:^(BOOL finished) {}];
        }];
}

/*
 * Called by Reachability whenever status changes.
 */
- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        [self hideSearchView];
        [self hideSettingsView];
        [self hideTutorialView];
        [self hideVerificationView];
        [self showConnectionLossView];
    }
}

- (void)bookingHTTPClient:(BookingHTTPClient *)client
       didValidateAddress:(MKPlacemark *)address
               withResult:(NSString *)result
                forOrigin:(BOOL)origin {
    if (origin) {
        if ([result isEqualToString:@"1"]) {
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:address];
            [self setPickupMapItem:mapItem];
            [self setPickupLocation:address.location.coordinate];
        } else {
            self.pickupButton.titleLabel.text = @"";
        }
    } else {
        [self.destinationActivityIndicator stopAnimating];
        if ([result isEqualToString:@"1"]) {
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:address];
            [self setDestinationMapItem:mapItem];
            [self setDestination:address.location.coordinate];
        } else {
            self.destinationButton.titleLabel.text = @"";
        }
    }

    if (![result isEqualToString:@"1"]) {
        // Generate content view to present
        UIView *contentView = [[UIView alloc] init];
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.layer.cornerRadius = 12.0;

        UILabel *dismissLabel = [[UILabel alloc] init];
        dismissLabel.translatesAutoresizingMaskIntoConstraints = NO;
        dismissLabel.backgroundColor = [UIColor clearColor];
        dismissLabel.textColor = [UIColor colorWithWhite:0.267 alpha:1.000];
        dismissLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
        dismissLabel.lineBreakMode = NSLineBreakByWordWrapping;
        dismissLabel.numberOfLines = 0;
        if (origin) {
            dismissLabel.text =
                @"Upphämtningsplats stöds tyvärr inte för tillfället.";
        } else {
            dismissLabel.text =
                @"Destinationen stöds tyvärr inte för tillfället.";
        }

        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
        dismissButton.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
        dismissButton.backgroundColor =
            [UIColor colorWithRed:0.043 green:0.565 blue:0.827 alpha:1.000];
        [dismissButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
        [dismissButton
            setTitleColor:[[dismissButton
                              titleColorForState:UIControlStateNormal]
                              colorWithAlphaComponent:0.5]
                 forState:UIControlStateHighlighted];
        dismissButton.titleLabel.font =
            [UIFont fontWithName:@"OpenSans" size:16];
        [dismissButton setTitle:@"OK" forState:UIControlStateNormal];
        dismissButton.layer.cornerRadius = 6.0;
        [dismissButton addTarget:self
                          action:@selector(dismissButtonPressed:)
                forControlEvents:UIControlEventTouchUpInside];

        [contentView addSubview:dismissLabel];
        [contentView addSubview:dismissButton];

        NSDictionary *views = NSDictionaryOfVariableBindings(
            contentView, dismissButton, dismissLabel);

        [contentView
            addConstraints:
                [NSLayoutConstraint
                    constraintsWithVisualFormat:
                        @"V:|-(16)-[dismissLabel]-(10)-[dismissButton]-(24)-|"
                                        options:NSLayoutFormatAlignAllCenterX
                                        metrics:nil
                                          views:views]];

        [contentView addConstraints:[NSLayoutConstraint
                                        constraintsWithVisualFormat:
                                            @"H:|-(36)-[dismissLabel]-(36)-|"
                                                            options:0
                                                            metrics:nil
                                                              views:views]];

        // Show in popup
        KLCPopupLayout layout = KLCPopupLayoutMake(
            KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutCenter);

        KLCPopup *popup =
            [KLCPopup popupWithContentView:contentView
                                  showType:KLCPopupShowTypeGrowIn
                               dismissType:KLCPopupDismissTypeBounceOut
                                  maskType:KLCPopupMaskTypeDimmed
                  dismissOnBackgroundTouch:YES
                     dismissOnContentTouch:NO];
        [popup showWithLayout:layout];
    }
}

- (void)bookingHTTPClient:(BookingHTTPClient *)client
          didReceivePrice:(NSString *)price {
    self.haveRecievedPrice = YES;
    [self.priceLabel
        setAttributedText:[self attributedFontForValue:price andUnit:@"sek"]];
}

- (void)bookingHTTPClient:(BookingHTTPClient *)client
      didBeginReservation:(id)reservation {
    self.reservationId = reservation;
    self.updateTimer =
        [NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(updateReservation)
                                       userInfo:nil
                                        repeats:YES];
}

- (void)bookingHTTPClient:(BookingHTTPClient *)client
          didUpdateStatus:(NSString *)status
              withVehicle:(NSString *)vehicle {
    [self setStatus:status];
    self.vehicleNbr = vehicle;
}

- (void)updateReservation {
    [[BookingHTTPClient sharedBookingHTTPClient]
        getStatusForReservation:self.reservationId];
}

- (void)dismissButtonPressed:(id)sender {
    if ([sender isKindOfClass:[UIView class]]) {
        [(UIView *)sender dismissPresentingPopup];
    }
}

- (void)makeConfirmationWithMessage:(NSString *)message {
    self.message = message;
    [self animateButtonsToLeft:1];
    [self setStatus:@"Pending"];
    [UIView animateKeyframesWithDuration:0.25
        delay:0
        options:0
        animations:^{
            self.destinationArrow.transform = CGAffineTransformTranslate(
                self.destinationArrow.transform, 100, 0);
            self.pickupArrow.transform =
                CGAffineTransformTranslate(self.pickupArrow.transform, 100, 0);
        }
        completion:^(BOOL finished) {
            self.destinationButton.enabled = NO;
            self.pickupButton.enabled = NO;
        }];

    [[BookingHTTPClient sharedBookingHTTPClient]
        requestReservationWithParameters:[self constructRequestDictionary]];

    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
        if (view) {
            [view setDraggable:NO];
        }
    }

    [self zoomToLocation:PICKUP_ANNOTATION];
}

- (void)hidePopupView {
    [self.popup dismiss:YES];
}

@end

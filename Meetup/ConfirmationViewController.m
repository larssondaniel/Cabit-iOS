//
//  ConfirmationViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-01-26.
//  Copyright (c) 2014 Cabit. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "Vehicle.h"
#import "DialController.h"
#import "UIView+Glow.h"
#import "DACircularProgressView.h"
#import "BBCyclingLabel.h"
#import "CAKeyframeAnimation+AHEasing.h"

#import <CoreLocation/CoreLocation.h>

@interface ConfirmationViewController ()

@property (nonatomic, retain) CLLocation *initialLocation;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UILabel *timeStaticLabel;
@property (strong, nonatomic) IBOutlet UILabel *companyStaticLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *staticPriceLabel;
@property (strong, nonatomic) IBOutlet UIView *statusView;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *statusImage;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;

@end

@implementation ConfirmationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mapView setDelegate:self];
    
    
    
    
    BookingHTTPClient *client = [BookingHTTPClient sharedBookingHTTPClient];
    client.delegate = self;
    [client requestReservationWithOrigin:self.mapView.userLocation.location andDestination:self.mapView.userLocation.location];
    
    
    
    
    self.pickupAnnotation = [[PickupAnnotation alloc] initWithCoordinates:self.pickupMapItem.placemark.coordinate];
    self.destinationAnnotation = [[MKPointAnnotation alloc] init];
    [self.destinationAnnotation setCoordinate:self.destinationMapItem.placemark.coordinate];
    
    [self setFontFamily:@"OpenSans-Semibold" forView:self.view andSubViews:YES];
    [self.priceLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:[[self.priceLabel font] pointSize]]];
    [self.staticPriceLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:[[self.staticPriceLabel font] pointSize]]];

    [self.mapView addAnnotation:self.destinationAnnotation];
    [self.mapView addAnnotation:self.pickupAnnotation];
    
    [self generateRoute];
    
    CGRect statusFrame = CGRectMake(76, 29, 224, 40);
    
    BBCyclingLabel* label = [[BBCyclingLabel alloc] initWithFrame:statusFrame];
    [label setNumberOfLines:2];
    [label setFont:[UIFont fontWithName:@"OpenSans" size:14]];
    [label setTextColor:[UIColor whiteColor]];
    [self.statusView addSubview:label];
    label.transitionEffect = BBCyclingLabelTransitionEffectScaleFadeIn;
    label.transitionDuration = 0.3;
    [label setText:@"Söker efter bilar i närheten..." animated:NO];
    
    
    
    //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);

    

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, [self secondsToNanoseconds:1]);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        
        CAAnimation *animation_cancelButton = [CAKeyframeAnimation animationWithKeyPath:@"position" function:ElasticEaseOut fromPoint:CGPointMake(self.cancelButton.center.x, self.cancelButton.center.y) toPoint:CGPointMake(self.cancelButton.center.x, self.cancelButton.center.y - 77)];
        animation_cancelButton.duration = 0.6;
        [self.cancelButton.layer addAnimation:animation_cancelButton forKey:@"easing"];
        [self.cancelButton setCenter:CGPointMake(self.cancelButton.center.x, self.cancelButton.center.y - 77)];
        
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, [self secondsToNanoseconds:0.1]);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            
            CAAnimation *animation_editButton = [CAKeyframeAnimation animationWithKeyPath:@"position" function:ElasticEaseOut fromPoint:CGPointMake(self.editButton.center.x, self.editButton.center.y) toPoint:CGPointMake(self.editButton.center.x, self.editButton.center.y - 77)];
            animation_editButton.duration = 0.6;
            [self.editButton.layer addAnimation:animation_editButton forKey:@"easing"];
            [self.editButton setCenter:CGPointMake(self.editButton.center.x, self.editButton.center.y - 77)];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, [self secondsToNanoseconds:0.1]);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                
                CAAnimation *animation_bottomView = [CAKeyframeAnimation animationWithKeyPath:@"position" function:CubicEaseOut fromPoint:CGPointMake(self.bottomView.center.x, self.bottomView.center.y) toPoint:CGPointMake(self.bottomView.center.x, self.bottomView.center.y - 181)];
                animation_bottomView.duration = 0.5;
                [self.bottomView.layer addAnimation:animation_bottomView forKey:@"easing"];
                [self.bottomView setCenter:CGPointMake(self.bottomView.center.x, self.bottomView.center.y - 181)];
                
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, [self secondsToNanoseconds:0.1]);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    
                    CAAnimation *animation_statusView = [CAKeyframeAnimation animationWithKeyPath:@"position" function:CubicEaseOut fromPoint:CGPointMake(self.statusView.center.x, self.statusView.center.y) toPoint:CGPointMake(self.statusView.center.x, self.statusView.center.y - 262)];
                    animation_statusView.duration = 0.8;
                    [self.statusView.layer addAnimation:animation_statusView forKey:@"easing"];
                    [self.statusView setCenter:CGPointMake(self.statusView.center.x, self.statusView.center.y - 262)];
                    
                    
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, [self secondsToNanoseconds:1]);
                    
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        CAAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:ExponentialEaseOut fromPoint:CGPointMake(self.statusImage.center.x, self.statusImage.center.y) toPoint:CGPointMake(self.statusImage.center.x + 80, self.statusImage.center.y)];
                        animation.duration = 0.5;
                        [self.statusImage.layer addAnimation:animation forKey:@"easing"];
                        [self.statusImage setCenter:CGPointMake(self.statusImage.center.x + 80, self.statusImage.center.y)];
                        
                        int64_t delayInSeconds = 5;
                        dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        
                        dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
                            [self.statusView glowOnce];
                            [label setText:@"En bil från Taxi Göteborg är på väg till upphämnintsplatsen" animated:YES];
                            
                            CAAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:ExponentialEaseOut fromPoint:CGPointMake(self.statusImage.center.x, self.statusImage.center.y) toPoint:CGPointMake(self.statusImage.center.x - 80, self.statusImage.center.y)];
                            animation.duration = 1.0;
                            [self.statusImage.layer addAnimation:animation forKey:@"easing"];
                            [self.statusImage setCenter:CGPointMake(self.statusImage.center.x - 80, self.statusImage.center.y)];
                            
                            int64_t delayInSeconds = 1.0;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                            
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                CAAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position" function:ExponentialEaseOut fromPoint:CGPointMake(self.statusImage.center.x, self.statusImage.center.y) toPoint:CGPointMake(self.statusImage.center.x + 80, self.statusImage.center.y)];
                                animation.duration = 1.0;
                                [self.statusImage.layer addAnimation:animation forKey:@"easing"];
                                [self.statusImage setCenter:CGPointMake(self.statusImage.center.x + 80, self.statusImage.center.y)];
                                
                            });
                        });
                    });
                });
            });

        });

    });
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
    if ([annotation isKindOfClass:[PickupAnnotation class]]) {
        static NSString *identifier = @"PickupAnnotation";
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            [annotationView setImage:[UIImage imageNamed:@"dot-circle"]];
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
    }
    [self beginZoomAnimation];
}

- (void)beginZoomAnimation
{
    [self fitRegionToRoute];
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.pickupAnnotation.coordinate;
    mapRegion.span.latitudeDelta = 0.002;
    mapRegion.span.longitudeDelta = 0.002;
    
    int64_t delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.mapView setRegion:mapRegion animated: YES];
    });
}

- (void)zoomInto:(CLLocationCoordinate2D)zoomLocation distance:(CGFloat)distance animated:(BOOL)animated{
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, distance, distance);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:animated];
}

- (IBAction)cancelReservation:(id)sender {
    [self.statusView glowOnce];
}

- (IBAction)back {
}

- (float)secondsToNanoseconds:(float)second
{
    return second * 1000000000;
}

# pragma networking

-(void)bookingHTTPClient:(BookingHTTPClient *)client didBeginReservation:(id)reservation
{
    NSLog(@"Success! Response: \n\n%@", reservation);
}

- (void)bookingHTTPClient:(BookingHTTPClient *)client didFailWithError:(NSError *)error
{
    NSLog(@"Fail! Error: \n\n%@", error);

    /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                        message:[NSString stringWithFormat:@"%@",error]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
     */
}

@end

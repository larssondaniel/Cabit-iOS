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

#import <CoreLocation/CoreLocation.h>

@interface ViewController ()

@property (nonatomic, strong) MKPointAnnotation *destinationAnnotation;
@property (nonatomic, strong) MKPointAnnotation *pickupAnnotation;
@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (strong, nonatomic) IBOutlet UIButton *searchPickupButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mapView setDelegate:self];
    [self.mapView addSubview:self.searchView];
    [self.mapView addSubview:self.destionationView];
    [self.mapView addOverlay:[[MapTileOverlay alloc] init]];
    
    // Reverse geolocate
    self.geoCoder = [[CLGeocoder alloc] init];

    // Press gesture recognizer for pin drop
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:lpgr];
    self.pickupAnnotation = [[MKPointAnnotation alloc] init];
    
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
        
        NSLog(@"Adress dictionary is %@", placemark.addressDictionary);
        
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
        [self setPickupLocation:self.mapView.userLocation.location.coordinate];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"Trying to add something");
    static NSString *identifier = @"TaxiLocation";
    if ([annotation isKindOfClass:[Vehicle class]]) {
        NSLog(@"Adding vehicle");
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            Company *company = ((Vehicle *)annotation).company;
            if ([company.name isEqualToString:@"Taxi Göteborg"]) {
                annotationView.image = [UIImage imageNamed:@"taxiKurirNy"];
            } else if ([company.name isEqualToString:@"Taxi kurir"])
                annotationView.image = [UIImage imageNamed:@"taxiKurirNy"];
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    } else if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        {
            NSLog(@"Adding something else");
            
            MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (annotationView == nil) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
                annotationView.enabled = YES;
                annotationView.canShowCallout = YES;
                annotationView.draggable = YES;
            } else {
                annotationView.annotation = annotation;
            }
            return annotationView;
        }
    }
    
    return nil;
}

-(MKOverlayView*)mapView:(MKMapView*)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MapTileOverlay class]]) {
        return [[MapTileOverlayView alloc] initWithOverlay:overlay];
    }
    return nil;
}

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"choosePickupLocation"]){
        SearchLocationViewController *controller = (SearchLocationViewController *)segue.destinationViewController;
        controller.delegate = self;
        controller.location = self.mapView.userLocation.location;
    }
}

- (void)addItemViewController:(SearchLocationViewController *)controller didFinishEnteringItem:(MKMapItem *)item {
    [self setPickupLocation:item.placemark.location.coordinate];
}

@end

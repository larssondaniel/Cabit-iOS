//
//  MainViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2013-11-18.
//  Copyright (c) 2013 Cabit. All rights reserved.
//

#import "MainViewController.h"
#import "Vehicle.h"
#import "ConfirmationViewController.h"
#import "TWMessageBarManager.h"
#import "UIView+Glow.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "FXBlurView.h"

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

@property (strong, nonatomic) IBOutlet UIButton *bouncingCone;
@property (strong, nonatomic) IBOutlet UIView *animatedBottomView;
@property (strong, nonatomic) IBOutlet UIButton *pickupLabel;
@property (strong, nonatomic) IBOutlet UILabel *pickupStaticLabel;
@property (strong, nonatomic) IBOutlet UILabel *destinationStaticLabel;
@property (strong, nonatomic) IBOutlet UIButton *destinationLabel;
@property (strong, nonatomic) IBOutlet UIView *pickupView;
@property (strong, nonatomic) IBOutlet UIView *destinationView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewTopConstraint;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) bool isShowingDestinaion;
@property (nonatomic) bool shouldAnimateBottomView;
@property (nonatomic, strong) FXBlurView *blurView;
@property (nonatomic, strong) UIView *tintView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UILabel *searchLabel;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) MKLocalSearchRequest *localSearchRequest;
@property (strong, nonatomic) MKLocalSearch *localSearch;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapView setDelegate:self];
    [self.mapView addSubview:self.searchView];
    
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
    
    //[self.pickupView startGlowingWithColor:[self.searchDestinationButton backgroundColor] intensity:0.7];

    [self setIsShowingDestinaion:NO];
    /*[self.pickupLabel.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    [self.pickupStaticLabel setFont:[UIFont fontWithName:@"OpenSans" size:10]];
    
    [self.destinationLabel.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    [self.destinationStaticLabel setFont:[UIFont fontWithName:@"OpenSans" size:10]];
    
    [self.searchDestinationButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    */
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"OpenSans" size:21],
      NSFontAttributeName, nil]];
    
    // Doing this in the storyboard magically crashes the app somehow.
    [self.destinationView setAlpha:0.85];
    
    [self setFontFamily:@"OpenSans" forView:self.view andSubViews:YES];
    
    
    
    
    // Set up search views
    
    self.data = [[NSMutableArray alloc] init];
    
    
    CGRect topBlurFrame = CGRectMake(0, 0, 320, 64);
    FXBlurView *topBlurView = [[FXBlurView alloc] initWithFrame:topBlurFrame];
    [topBlurView setAlpha:1.0];
    //[self.view addSubview:topBlurView];
    [topBlurView setDynamic:YES];
    [topBlurView setBlurEnabled:YES];
    [topBlurView setBlurRadius:20];
    [topBlurView setTintColor:[UIColor clearColor]];
    
    CGRect topTintFrame = CGRectMake(0, 0, 320, 64);
    UIView *topTintView = [[UIView alloc] initWithFrame:topTintFrame];
    [topTintView setBackgroundColor:[UIColor whiteColor]];
    [topTintView setAlpha:0.9];
    [self.view addSubview:topTintView];
    
    [self.view bringSubviewToFront:self.menuButton];

    
    
    
    CGRect blurFrame = CGRectMake(0, 0, 320, 576);
    self.blurView = [[FXBlurView alloc] initWithFrame:blurFrame];
    [self.blurView setAlpha:0.0];
    [self.view addSubview:self.blurView];
    [self.blurView setDynamic:YES];
    [self.blurView setBlurEnabled:YES];
    [self.blurView setBlurRadius:20];
    [self.blurView setTintColor:[UIColor clearColor]];

    CGRect tintFrame = CGRectMake(0, 0, 320, 576);
    self.tintView = [[UIView alloc] initWithFrame:tintFrame];
    //[self.tintView setBackgroundColor:[UIColor blackColor]];
    [self.tintView setBackgroundColor:[UIColor colorWithRed:0.196 green:0.235 blue:0.313 alpha:1]];
    // In order to animate it later
    [self.tintView setAlpha:0.0];
    [self.view addSubview:self.tintView];
    
    self.searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, 32)];
    self.searchLabel.textColor = [UIColor whiteColor];
    self.searchLabel.text = @"Upphämtningsplats";
    self.searchLabel.textAlignment = NSTextAlignmentCenter;
    self.searchLabel.alpha = 0.0;
    [self.view addSubview:self.searchLabel];
    
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 60.0f, 320.0f, 44.0f)];
    //tableView.tableHeaderView = searchBar;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Sök adress";
    self.searchBar.tintColor = [UIColor whiteColor];
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.barStyle = UIBarStyleDefault;
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    [searchField setTextColor:[UIColor whiteColor]];
    [searchField setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    // create the Search Display Controller with the above Search Bar
    self.searchController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    self.searchController.searchResultsTableView.alpha = 0.0;
    self.searchController.searchResultsTableView.backgroundColor = [UIColor clearColor];
    self.searchController.searchResultsTableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.4];
    self.searchController.searchResultsTableView.rowHeight = 45;
    self.searchController.searchResultsTableView.sectionFooterHeight = 22;
    self.searchController.searchResultsTableView.sectionHeaderHeight = 22;
    self.searchController.searchResultsTableView.scrollEnabled = YES;
    self.searchController.searchResultsTableView.showsVerticalScrollIndicator = YES;
    self.searchController.searchResultsTableView.userInteractionEnabled = YES;
    self.searchController.searchResultsTableView.bounces = YES;
    self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 10.0f)];
    self.searchController.searchResultsTableView.tintColor = [UIColor clearColor];
    
    self.searchBar.alpha = 0.0;
    [self.view addSubview:self.searchBar];

    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self hidePickupSearchView];
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
    [self.activityIndicator startAnimating];
    [self.geoCoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
        // NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        
        [self.pickupLabel setTitle:[placemark.addressDictionary valueForKey:@"Name"] forState:UIControlStateNormal];
        [self.activityIndicator stopAnimating];
        [self setPickupMapItem:[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:placemark]]];
        [self setPickupLocation:placemark.location.coordinate];
        [self animateBottomView];
    }];
}

- (void)setPickupLocation:(CLLocationCoordinate2D)location
{
    self.pickupAnnotation.coordinate = location;
    NSLog(@"Setting pickup location!!!");
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
    if (!self.initialLocation)
    {
        MKCoordinateRegion region;
        region.center = userLocation.coordinate;
        // Region to show when app is loaded
        region.span = MKCoordinateSpanMake(0.04, 0.04);
        region = [mapView regionThatFits:region];
        
        if (!CLLocationCoordinate2DIsValid(userLocation.coordinate)) {
            //do nothing, invalid regions
            NSLog(@"co-ord fail");
        } else if (region.span.latitudeDelta <= 0.0 || region.span.longitudeDelta <= 0.0) {
            NSLog(@"invalid reg");
        } else {
            [self calculateLocationAddress];
            self.initialLocation = userLocation.location;
            [mapView setRegion:region animated:YES];
            // Set initial pickup location to current position
            //[self setPickupLocation:self.mapView.userLocation.location.coordinate];
        }
    }
}

/*
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"WE FUCKING GOT HERE");
    if (![annotation isKindOfClass:[PickupAnnotation class]]) {
        NSLog(@"AND HERE");
        static NSString *identifier = @"Pickup";
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            [annotationView setImage:[UIImage imageNamed:@"dot-circle"]];
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
    } else if([segue.identifier isEqualToString:@"confirmationSegue"]){
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
    [self.continueButton setEnabled:YES];
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

- (void) findTaxi
{
    /*[[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Bokning genomförd!"
                                                   description:@"En taxi är på väg."
                                                          type:TWMessageBarMessageTypeSuccess];
     */
    //[self performSegueWithIdentifier: @"displayConfirmation" sender: self];
}

- (IBAction)clickedChooseDestination:(id)sender {
    if (!self.isShowingDestinaion) {
        [self performSegueWithIdentifier:@"chooseDestination" sender:self];
    } else {
    }
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

- (void)animateBottomView
{
    [self setIsShowingDestinaion:YES];
    
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
    
    [UIView animateWithDuration:0.6 animations:^(void) {
        self.tintView.alpha = 0.6;
        self.blurView.alpha = 1.0;
        self.searchTableView.alpha = 1.0;
        self.searchBar.alpha = 1.0;
        self.searchLabel.alpha = 1.0;
    }];
    [self.searchBar becomeFirstResponder];
}

- (IBAction)hidePickupSearchView {
    
    [UIView animateWithDuration:0.6 animations:^(void) {
        self.tintView.alpha = 0.0;
        self.blurView.alpha = 0.0;
        self.searchTableView.alpha = 0.0;
        self.searchBar.alpha = 0.0;
        self.searchLabel.alpha = 0.0;
    }];
}

#pragma tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (controller.searchBar.text.length > 1)
        [self doSearch:searchString];
    return NO;
}

- (void)doSearch:(NSString *)query
{
    [self.data removeAllObjects];
    [self issueLocalSearchLookup:self.searchBar.text];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    NSLog(@"Making a cell");
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        // cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    // Configure the cell.
    MKMapItem *mapItem = (MKMapItem *)[self.data objectAtIndex:indexPath.row];
    
    NSString *formattedAddress = [mapItem.placemark.addressDictionary valueForKey:@"Name"];
    if ([mapItem.placemark.addressDictionary valueForKey:@"City"]) {
        formattedAddress = [formattedAddress stringByAppendingString:[NSString stringWithFormat:@", %@", [mapItem.placemark.addressDictionary valueForKey:@"City"]]];
    }
    
    cell.textLabel.text = formattedAddress;
    
    return cell;
}

-(void)issueLocalSearchLookup:(NSString *)searchString
{
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    // Tell the search engine to start looking within 30 000 meters from the user
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 30000, 30000);
    
    // Create the search request
    self.localSearchRequest = [[MKLocalSearchRequest alloc] init];
    self.localSearchRequest.region = region;
    self.localSearchRequest.naturalLanguageQuery = searchString;
    
    // Perform the search request...
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:self.localSearchRequest];
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        if(error){
            NSLog(@"LocalSearch failed with error: %@", error);
            return;
        } else {
            NSPredicate *noBusiness = [NSPredicate predicateWithFormat:@"business.uID == 0"];
            NSMutableArray *itemsWithoutBusinesses = [response.mapItems mutableCopy];
            [itemsWithoutBusinesses filterUsingPredicate:noBusiness];
            for(MKMapItem *mapItem in itemsWithoutBusinesses){
                [self.data addObject:mapItem];
            }
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKMapItem *mapItem = (MKMapItem *)[self.data objectAtIndex:indexPath.row];
    [self setPickupMapItem:mapItem];
    [self setPickupLocation:mapItem.placemark.location.coordinate];
    [self.pickupLabel setTitle:mapItem.name forState:UIControlStateNormal];
}

@end

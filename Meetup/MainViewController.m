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
#import "CredentialsViewController.h"

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

@property (nonatomic) bool shouldAnimateBottomView;
@property (nonatomic, strong) UIToolbar *tintView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UILabel *searchLabel;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) MKLocalSearchRequest *localSearchRequest;
@property (strong, nonatomic) MKLocalSearch *localSearch;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIView *credentialsContainer;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapView setDelegate:self];
    [self.mapView addSubview:self.searchView];
    
    self.data = [[NSMutableArray alloc] init];

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
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"OpenSans" size:21],
      NSFontAttributeName, nil]];
    
    // Doing this in the storyboard magically crashes the app somehow.
    [self.destinationView setAlpha:0.85];
    
    [self setFontFamily:@"OpenSans" forView:self.view andSubViews:YES];
    
    // Set up search views
    
    /*
    CGRect topTintFrame = CGRectMake(0, 0, 320, 64);
    UIView *topTintView = [[UIView alloc] initWithFrame:topTintFrame];
    [topTintView setBackgroundColor:[UIColor whiteColor]];
    [topTintView setAlpha:0.9];
    [self.view addSubview:topTintView];
    
    [self.view bringSubviewToFront:self.menuButton];
     */
    
    // In order to animate it later
    self.tintView = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    self.tintView.barTintColor = [UIColor colorWithRed:0.196 green:0.235 blue:0.313 alpha:0.6];
    self.tintView.autoresizingMask = self.view.autoresizingMask;
    self.tintView.alpha = 0.0;
    [self.view addSubview:self.tintView];
    
    self.credentialsContainer.alpha = 0.0;
    //[self.view bringSubviewToFront:self.credentialsContainer];

    self.searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, 32)];
    self.searchLabel.textColor = [UIColor whiteColor];
    self.searchLabel.text = @"Upphämtningsplats";
    self.searchLabel.textAlignment = NSTextAlignmentCenter;
    self.searchLabel.alpha = 0.0;
    [self.view addSubview:self.searchLabel];

    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 60.0f, 320.0f, 44.0f)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Sök adress";
    self.searchBar.tintColor = [UIColor whiteColor];
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.barStyle = UIBarStyleDefault;
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    [searchField setTextColor:[UIColor whiteColor]];
    [searchField setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor clearColor];
    self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.4];
    

    //self.searchDisplayController.searchResultsTableView.hidden = YES;

    self.searchController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
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
    //[self.searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"resultsCell"];
    self.searchController.searchResultsTableView.alpha = 0.0;

    self.searchBar.alpha = 0.0;
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.searchController.searchResultsTableView];
    
    [self showCredentialsView];
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

/*
 *  Not used at the moment. Is needed if there should be a locate button after the user changes to another origin adress.
 */
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
    //[self.mapView addAnnotation:self.pickupAnnotation];
    if (self.destinationMapItem)
        [self generateRoute];
}

- (void)setDestination:(CLLocationCoordinate2D)location
{
    self.destinationAnnotation.coordinate = location;
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
    /*
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
     */
    if([segue.identifier isEqualToString:@"confirmationSegue"]){
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
        // request.source = self.pickupMapItem;
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
        self.tintView.alpha = 0.95;
        self.searchBar.alpha = 1.0;
        self.searchLabel.alpha = 1.0;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    [UIView animateWithDuration:0.6 animations:^(void) {
        [self.searchBar setShowsCancelButton:YES animated:YES];
    }];
    [self.searchBar becomeFirstResponder];
}

- (void)hidePickupSearchView {
    NSLog(@"Hiding");
    [UIView animateWithDuration:0.6 animations:^(void) {
        self.tintView.alpha = 0.0;
        self.searchBar.alpha = 0.0;
        self.searchLabel.alpha = 0.0;
        [self.searchBar setShowsCancelButton:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

#pragma tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    /*
    dispatch_queue_t queue = dispatch_queue_create("com.cabit.Cabit", NULL);
    dispatch_async(queue, ^{
        //code to be executed in the background
        [self doSearch:searchString];

        dispatch_async(dispatch_get_main_queue(), ^{
            //code to be executed on the main thread when background task is finished
            [self.searchDisplayController.searchResultsTableView reloadData];
        });
    });
    */

    //if (controller.searchBar.text.length > 2)
    
    // Completely unclear why this needs to be done, but it does. Without it, the tableview displays only after typing a second query.
    controller.searchResultsTableView.hidden = NO;
    controller.searchResultsTableView.alpha = 1.0;

    [self doSearch:searchString];

    // Apple suggests to return NO here..
    return NO;
}

- (void)doSearch:(NSString *)query
{
    if ([query length] != 0) {
        [self.data removeAllObjects];
        [self issueLocalSearchLookup:self.searchBar.text];
    }
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ResultsCell";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    // NSLog(@"Searching for %@", searchString);
    //if (self.localSearch.searching)
    //{
    //    NSLog(@"Cancelled search for %@", searchString);
    //    [self.localSearch cancel];
    //}

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
            // NSLog(@"Searching for %@ with results: %i", searchString, itemsWithoutBusinesses.count);
            for(MKMapItem *mapItem in itemsWithoutBusinesses){
                [self.data addObject:mapItem];
            }
            [self.searchController.searchResultsTableView reloadData];
            if (self.searchDisplayController.searchResultsTableView.visibleCells.count > 0) {
                NSLog(@"Delegate is %@", self.searchDisplayController.searchResultsTableView.delegate);
            }
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"This just happened");
    MKMapItem *mapItem = (MKMapItem *)[self.data objectAtIndex:indexPath.row];
    [self setPickupMapItem:mapItem];
    [self setPickupLocation:mapItem.placemark.location.coordinate];
    [self.pickupLabel setTitle:mapItem.name forState:UIControlStateNormal];
    [self hidePickupSearchView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
    [self hidePickupSearchView];
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.animatedBottomView.alpha = 1.0;
        [self.credentialsContainer setHidden:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

@end

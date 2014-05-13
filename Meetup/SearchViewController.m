//
//  searchViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-05-10.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "SearchViewController.h"
#import "MainViewController.h"

@interface SearchViewController ()

@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) MKLocalSearchRequest *localSearchRequest;
@property (strong, nonatomic) MKLocalSearch *localSearch;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic) CLLocationCoordinate2D userLocation;
@property (nonatomic, strong) MainViewController *mainViewController;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	[self.locationManager startUpdatingLocation];

    self.geoCoder = [[CLGeocoder alloc] init];
    self.places = [[NSMutableArray alloc] init];
    self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.4];
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    [searchField setTextColor:[UIColor whiteColor]];
    [searchField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [self.searchDisplayController.searchResultsTableView setBackgroundView:nil];
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [_places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    // Configure the cell.
    MKMapItem *mapItem = (MKMapItem *)[self.places objectAtIndex:indexPath.row];
    
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
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.userLocation, 30000, 30000);
    
    // Create the search request
    self.localSearchRequest = [[MKLocalSearchRequest alloc] init];
    self.localSearchRequest.region = region;
    self.localSearchRequest.naturalLanguageQuery = searchString;
    
    // Perform the search request...
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:self.localSearchRequest];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        if(error){
            NSLog(@"LocalSearch failed with error: %@", error);
            return;
        } else {
            NSPredicate *noBusiness = [NSPredicate predicateWithFormat:@"business.uID == 0"];
            NSMutableArray *itemsWithoutBusinesses = [response.mapItems mutableCopy];
            [itemsWithoutBusinesses filterUsingPredicate:noBusiness];
            // NSLog(@"Searching for %@ with results: %i", searchString, itemsWithoutBusinesses.count);
            
            self.places = itemsWithoutBusinesses;

            /*
            for(MKMapItem *mapItem in itemsWithoutBusinesses){
                [self.places addObject:mapItem];
            }
             */
            [self.searchDisplayController.searchResultsTableView reloadData];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.mainViewController hideSearchView];
}

- (void)setActiveWithLabel:(NSString *)label andUserLocation:(CLLocationCoordinate2D)location
{
    self.mainViewController = (MainViewController *)self.parentViewController;
    self.userLocation = location;
    [self.searchBar becomeFirstResponder];
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    // check to see if Location Services is enabled, there are two state possibilities:
    // 1) disabled for entire device, 2) disabled just for this app
    //
    NSString *causeStr = nil;
    
    // check whether location services are enabled on the device
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        causeStr = @"device";
    }
    // check the application’s explicit authorization status:
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        causeStr = @"app";
    }
    else
    {
        // we are good to go, start the search
        [self issueLocalSearchLookup:searchBar.text];
    }
    
    if (causeStr != nil)
    {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
        
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                        message:alertMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self issueLocalSearchLookup:searchString];
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Super is: %@", self.mainViewController);
    // pass the new bounding region to the map destination view controller
    //self.mainViewController.boundingRegion = self.boundingRegion;
    
    // pass the individual place to our map destination view controller
    NSIndexPath *selectedItem = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
    [self.mainViewController didFinishSearchWithAdress:[self.places objectAtIndex:selectedItem.row]];
    [self.mainViewController hideSearchView];
    
    [self.places removeAllObjects];
    [self.searchBar setText:@""];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end

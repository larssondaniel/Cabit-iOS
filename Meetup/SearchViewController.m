//
//  searchViewController.m
//  Cabit
//
//  Created by Daniel Larsson on 2014-05-10.
//  Copyright (c) 2014 Meetup. All rights reserved.
//

#import "SearchViewController.h"
#import "MainViewController.h"
#import "SPGooglePlacesAutocomplete.h"

@interface SearchViewController ()

@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property (nonatomic, strong) CLLocationManager *locationManager;
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
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"blurBackground.jpg"];
    imageView.alpha = 0.25;
    [self.view addSubview:imageView];
    
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

- (void)loadSearchHistory
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentSearches = [NSMutableArray array];
    
    NSArray *dataRepresentingSavedArray = [currentDefaults objectForKey:@"searchHistory"];
    
    if (dataRepresentingSavedArray != nil)
    {
        for (NSData *data in dataRepresentingSavedArray) {
            [recentSearches addObject:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        }
        [self.places addObjectsFromArray:recentSearches];
    }
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

    if (indexPath.row <= self.places.count -1 && self.places.count) {
        SPGooglePlacesAutocompletePlace *place = (SPGooglePlacesAutocompletePlace *)[self.places objectAtIndex:indexPath.row];
        cell.textLabel.text = [self parseAddress:place.name];
        return cell;
    }
    return nil;
}

- (NSString *)parseAddress:(NSString *)address {
    NSArray *addressComponents = [address componentsSeparatedByString:@","];
    NSString *parsedAddress = [NSString stringWithFormat:@"%@, %@", [addressComponents objectAtIndex:0], [addressComponents objectAtIndex:1]];
    return parsedAddress;
}

-(void)issueLocalSearchLookup:(NSString *)searchString
{
    SPGooglePlacesAutocompleteQuery *query = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:@"AIzaSyDxTyIXSAktcdcT8_l9AdjiUem8--zxw2Y"];
    query.input = searchString; // search key word
    query.location = self.userLocation;  // user's current location
    query.radius = 100.0;   // search addresses close to user
    query.language = @"se"; // optional
    query.types = SPPlaceTypeGeocode; // Only return geocoding (address) results.
    
    [query fetchPlaces:^(NSArray *places, NSError *error) {
        [self.places removeAllObjects];
        //NSLog(@"Results for %@: %i", searchString, places.count);
        [self.places addObjectsFromArray:places];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.mainViewController hideSearchView];
    [self resetTableView];
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
    if (searchString != nil && ![searchString isEqual: @""])
        [self issueLocalSearchLookup:searchString];
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // pass the new bounding region to the map destination view controller
    //self.mainViewController.boundingRegion = self.boundingRegion;
    
    // pass the individual place to our map destination view controller
    NSIndexPath *selectedItem = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
    [self.mainViewController didFinishSearchWithAdress:[self.places objectAtIndex:selectedItem.row]];
    [self.mainViewController hideSearchView];
    
    [self saveToRecentSearches:[self.places objectAtIndex:selectedItem.row]];
    [self resetTableView];
}

- (void)resetTableView
{
    [self.places removeAllObjects];
    [self.searchBar setText:@""];
    [self.searchDisplayController.searchResultsTableView reloadData];
    [self.searchDisplayController setActive:NO];
}

- (void)saveToRecentSearches:(SPGooglePlacesAutocompletePlace *)search
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentSearches = [NSMutableArray array];
    
    NSMutableArray *dataRepresentingSavedArray = [currentDefaults objectForKey:@"searchHistory"];
    
    if (dataRepresentingSavedArray != nil)
        recentSearches = [[NSMutableArray alloc] initWithArray:dataRepresentingSavedArray];
    

    for (NSData *data in dataRepresentingSavedArray) {
        SPGooglePlacesAutocompletePlace *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        //NSLog(@"Comparing \n\n%@ \n\n to %@", search, object);
        if ([object.reference isEqualToString:search.reference]) {
            NSLog(@"Removing data");
            [recentSearches removeObject:data];
        }
    }
    
    NSData *encodedSearch = [NSKeyedArchiver archivedDataWithRootObject:search];
    [recentSearches insertObject:encodedSearch atIndex:0];
    
    if (recentSearches.count > 9) {
        [recentSearches removeLastObject];
    }
    [currentDefaults setValue:recentSearches forKey:@"searchHistory"];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    [self loadSearchHistory];
    [self.searchDisplayController.searchResultsTableView reloadData];
    controller.searchResultsTableView.hidden = NO;
    [self removeTableViewOverlay];
}

- (void)removeTableViewOverlay {
    for (UIView *v in [[self.searchDisplayController.searchResultsTableView superview] subviews]) {
        if (v.alpha < 1) {
            [v setHidden:YES];
        }
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"Did hide search view");
    if (self.searchDisplayController.active == YES) {
        NSLog(@"Did hide");
        [self removeTableViewOverlay];
        tableView.hidden = NO;
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end

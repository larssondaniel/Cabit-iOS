//
//  SearchLocationViewController.m
//  Meetup
//
//  Created by Daniel Larsson on 2013-12-04.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import "SearchPickupViewController.h"

@interface SearchPickupViewController ()
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) MKLocalSearchRequest *localSearchRequest;
@property (strong, nonatomic) MKLocalSearch *localSearch;

@end

@implementation SearchPickupViewController

@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.data = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.searchBar becomeFirstResponder];
}

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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doSearch:(NSString *)query
{
    [self.data removeAllObjects];
    [self issueLocalSearchLookup:self.searchBar.text];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger tmp = [self.data count];
    int i = (int)tmp;
    // NSLog(@"numberOfRowsInSection = %i", i);
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell.
    MKMapItem *mapItem = (MKMapItem *)[self.data objectAtIndex:indexPath.row];
    
    NSString *formattedAddress = [mapItem.placemark.addressDictionary valueForKey:@"Name"];
    formattedAddress = [formattedAddress stringByAppendingString:[NSString stringWithFormat:@", %@", [mapItem.placemark.addressDictionary valueForKey:@"City"]]];
    
    cell.textLabel.text = formattedAddress;
    return cell;
}

-(void)issueLocalSearchLookup:(NSString *)searchString
{
    // Tell the search engine to start looking within 30 000 meters from the user
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, 30000, 30000);
    
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
            //for(MKMapItem *mapItem in itemsWithoutBusinesses.mapItems)){
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
    [self.delegate addItemViewController:self didFinishEnteringPickupLocation:mapItem];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
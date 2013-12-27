//
//  SearchLocationViewController.m
//  Meetup
//
//  Created by Daniel Larsson on 2013-12-04.
//  Copyright (c) 2013 Meetup. All rights reserved.
//

#import "SearchLocationViewController.h"

@interface SearchLocationViewController ()
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) MKLocalSearchRequest *localSearchRequest;
@property (strong, nonatomic) MKLocalSearch *localSearch;

@end

@implementation SearchLocationViewController

@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.data = [[NSMutableArray alloc] init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self doSearch:searchString];
    return NO;
}

- (void)doSearch:(NSString *)query
{
    NSLog(@"doSearch");
    [self.data removeAllObjects];
    [self issueLocalSearchLookup:self.searchBar.text];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger tmp = [self.data count];
    int i = (int)tmp;
    NSLog(@"numberOfRowsInSection = %i", i);
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@", mapItem.name];
    return cell;
}

-(void)issueLocalSearchLookup:(NSString *)searchString
{
    // Tell the search engine to start looking within 10 000 meters from the user
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, 10000, 10000);
    
    // Create the search request
    self.localSearchRequest = [[MKLocalSearchRequest alloc] init];
    self.localSearchRequest.region = region;
    self.localSearchRequest.naturalLanguageQuery = searchString;
    
    // Perform the search request...
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:self.localSearchRequest];
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        if(error){
            NSLog(@"localSearch startWithCompletionHandlerFailed! Error: %@", error);
            return;
        } else {
            for(MKMapItem *mapItem in response.mapItems){
                [self.data addObject:mapItem];
                NSLog(@"Name for result: = %@", mapItem.name);
            }
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKMapItem *mapItem = (MKMapItem *)[self.data objectAtIndex:indexPath.row];
    [self.delegate addItemViewController:self didFinishEnteringItem:mapItem];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

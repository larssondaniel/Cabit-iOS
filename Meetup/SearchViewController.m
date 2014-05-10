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

@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) MKLocalSearchRequest *localSearchRequest;
@property (strong, nonatomic) MKLocalSearch *localSearch;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _data = [[NSMutableArray alloc] init];
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
    return [_data count];
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
    cell.textLabel.text = [NSString stringWithFormat:@"Row %d: %@", indexPath.row, [_data objectAtIndex:indexPath.row]];
    return cell;
}

- (void)mockSearch
{
    [_data removeAllObjects];
    int count = 1 + random() % 20;
    for (int i = 0; i < count; i++) {
        [_data addObject:@"Test"];
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //[controller.searchResultsTableView setBackgroundView:nil];
    //[controller.searchResultsTableView setBackgroundColor:[UIColor clearColor]];

    [self mockSearch];
    return NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    MainViewController *mainViewController = (MainViewController *)self.parentViewController;
    [mainViewController hideSearchView];
}

- (void)setActiveWithLabel:(NSString *)label
{
    [self.searchBar becomeFirstResponder];
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

@end

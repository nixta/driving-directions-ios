//
//  MapViewController+Search.m
//  Map
//
//  Created by Scott Sirowy on 10/14/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "MapViewController+Search.h"
#import "MapViewController+MapTapping.h"
#import "Location.h"
#import "LocationGraphic.h"
#import "Search.h"
#import "MapAppSettings.h"
#import "UserSearchResults.h"
#import "DrawableResultsTableView.h"
#import "ExtendableToolbar.h"
#import "UIBarButtonItem+AppAdditions.h"
#import "ArcGISAppDelegate.h"
#import "ArcGISMobileConfig.h"

#define kPointTargetScale 10000.0


@implementation MapViewController (Search)

@dynamic locator;

-(void)searchFinishedExecuting
{
    @synchronized(self)
	{
		_searchesInProgress--;
	}
    
    if(_searchesInProgress == 0)
    {
        [self showActivityIndicator:NO]; 
        
        [self.searchResults addResultsToLayer:self.searchLayer];
        [self.mapView zoomToEnvelope:[self.searchResults envelopeInMapView:self.mapView] 
                            animated:NO];
        
        //show a callout for the first result if one exists
        if([self.searchResults totalNumberOfItems] > 0)
        {
            _currentSearchResultIndex = 0;
            [self showCurrentSearchResultWithZoom:NO];
        }
    }
}

-(void)dropPinForSearchLocation:(Location *)location
{
    [self dropPinForSearchLocation:location zoomToLocation:NO showCallout:NO];
}

-(void)dropPinForSearchLocation:(Location *)location zoomToLocation:(BOOL)zoom
{
    [self dropPinForSearchLocation:location zoomToLocation:zoom showCallout:NO];
}

-(void)dropPinForSearchLocation:(Location *)location zoomToLocation:(BOOL)zoom showCallout:(BOOL)showCallout
{
    //only add if not on the screen.
    if (![self.searchLayer.graphics containsObject:location.graphic]) {
        [self.searchLayer addGraphic:location.graphic];
        [self.searchLayer dataChanged];
    }
    
    if (zoom) {
        if ([location respondsToSelector:@selector(envelope)] && location.envelope) {
            [self.mapView zoomToEnvelope:location.envelope animated:YES];
        }
        else
        {
            [self.mapView zoomToGeometry:location.geometry withPadding:3 animated:YES];
        }
    }
    
    if(showCallout)
    {
        [self showCalloutForLocation:location];
    }
}

-(void)showCurrentSearchResultWithZoom:(BOOL)zoom
{
    Location *loc = (Location *)[self.searchResults itemAtIndex:_currentSearchResultIndex];
    [self dropPinForSearchLocation:loc zoomToLocation:zoom showCallout:YES];
}

#pragma mark -
#pragma mark ResultsContainer Delegate
-(void)viewController:(id)viewController didClickOnResult:(id<TableViewDrawable>)result
{
    if([result isKindOfClass:[Search class]])
    {
        self.searchBar.text = result.name;
        [self searchBarSearchButtonClicked:self.searchBar];
    }
    
    //if we are looking at filtered results, set up a new search results list with only
    //the item they chose
    else if(self.resultsTableView.resultsDataSource == self.localFilteredResults)
    {
        [self initalizeSearchResultsWithLocation:(Location *)result];
        [self setSearchState:MapSearchStateMap withKeyboard:NO animated:YES];
    }
    else
    {
        [self setSearchState:MapSearchStateMap withKeyboard:NO animated:YES];
        
        NSUInteger indexOfResult = [self.searchResults indexOfItem:result];
        _currentSearchResultIndex = indexOfResult;
        [self showCurrentSearchResultWithZoom:YES];
    }
}

//helper method for results container delegate. Will wipe away all old search results, create a new
//list for the passed in location, and add to a new set of search results
-(void)initalizeSearchResultsWithLocation:(Location *)location
{
    //show name of result in search bar
    self.searchBar.text = location.name;
    
    self.searchResults = [[UserSearchResults alloc] initWithRecents:nil localCollection:nil];
    
    DrawableList *dl = [[DrawableList alloc] initWithName:@"Location" withItems:[NSMutableArray arrayWithObject:location]];
    [self.searchResults addList:dl];
    [self.searchResults addResultsToLayer:self.searchLayer];
    
    self.resultsTableView.resultsDataSource = self.searchResults;
    
    if ([location hasValidPoint]) {
        [self dropPinForSearchLocation:location zoomToLocation:YES showCallout:YES];
    }
    else
    {
        [self showActivityIndicator:YES];
        location.delegate = self;
        [location updatePoint];
    }
}


#pragma mark -
#pragma mark Search Buttons Menu Interaction
-(void)mapListButtonPressed:(id)sender
{
    //assume in list mode... Set state based on number of results in search results
    MapSearchState newState = ([self.searchResults totalNumberOfItems] > 0) ? MapSearchStateMap : MapSearchStateDefault;
    
    //if we are on map, then show list
    if (_searchState == MapSearchStateDefault || _searchState == MapSearchStateMap) {
        newState = MapSearchStateList;
    }
    
    [self setSearchState:newState withKeyboard:NO animated:YES];
}

#pragma mark -
#pragma mark UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

/*-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{      
    [self setSearchState:MapSearchStateList withKeyboard:YES animated:YES];
}  */

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"Did end editing");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    
    //only show bookmarks button if there is nothing to show
    //self.searchBar.showsBookmarkButton = (self.searchBar.text.length == 0);
    
    Search *newSearch = [[Search alloc] initWithName:searchBar.text];
    [self.mapAppSettings addRecentSearch:newSearch onlyUniqueEntries:YES];
    
    [self showActivityIndicator:YES];
    
    [self.resultsTableView maximize];
    
    //initialize
    _searchesInProgress = 0; 
        
    if (self.geocodeService == nil)
    {
        self.geocodeService = [[GeocodeService alloc] init];
        self.geocodeService.delegate = self;
        self.geocodeService.addressLocatorString = self.mapAppSettings.organization.locatorUrlString;
        self.geocodeService.useSingleLine = (self.mapAppSettings.organization.locatorUrlString == nil);
    }
    
    [self removeOldResults];
    self.searchResults = [[UserSearchResults alloc] initWithRecents:nil localCollection:nil];
    self.resultsTableView.resultsDataSource = self.searchResults;
    [self.resultsTableView reloadData];
    
    [self.geocodeService findAddressCandidates:self.searchBar.text 
                          withSpatialReference:self.mapView.spatialReference];
    _searchesInProgress++;
    
    
    [self.geocodeService findPlace:self.searchBar.text 
              withSpatialReference:self.mapView.spatialReference];
    _searchesInProgress++;
    
//    // pass the extent as well
//    if ( self.locator == nil) {
//        self.locator = [AGSLocator locatorWithURL: [[NSURL alloc] initWithString:self.mapAppSettings.organization.locatorUrlString]];
//        self.locator lo
//    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.searchBar.text.length == 0) 
    {
        [self removeOldResults];
        
        //did begin editing will be called as well, putting search back into list state
    }
    else
    {
        //if we are showing search results, blow them away and only show local search results
        if (self.searchResults != nil) {
            [self removeOldResults];
        }
        
        self.resultsTableView.resultsDataSource = self.localFilteredResults;
        [self.localFilteredResults refineResultsUsingSearchFilter:searchText];
        [self.resultsTableView reloadData];
    }
}




#pragma mark -
#pragma mark Search Bar Misc.
-(void)setSearchState:(MapSearchState)state withKeyboard:(BOOL)keyboard animated:(BOOL)animated
{
    _searchState = state;
    
    switch (state) {
        case MapSearchStateDefault:
            [self endSearchProcessAnimated:animated];
            break;
        case MapSearchStateList:
            [self setupSearchForListAnimated:animated];
            break;
        case MapSearchStateMap:
            [self setupSearchForMapAnimated:animated];
            break;
        default:
            break;
    }
    
    //depending on whether keyboard is up or not, make sure tableview fits properly
    SEL tableViewSel = (keyboard) ? @selector(minimize) : @selector(maximize);
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.resultsTableView performSelector:tableViewSel];
}

-(void)endSearchProcessAnimated:(BOOL)animated
{
    //should be set to no search before being called
    if(_searchState != MapSearchStateDefault)
        return;
    
    [self.searchLayer removeAllGraphics];
    [self.searchLayer dataChanged];
    
    //reset back to old imaget
    [self.mapListButton setImage:[UIImage imageNamed:@"Map.png"]];
    
    // Al Delete
//    //don't show buttons anumore
//    [self showMapListButton:NO withPlanningButton:YES animated:animated];
    
    //Kill keyboard if up
    [self.searchBar resignFirstResponder];
    
    //remove any text in keyboard
    self.searchBar.text = nil;
    
    //self.searchBar.showsBookmarkButton = YES;

    [self setCalloutShown:NO];
    
    [self showResultsList:NO];
    self.resultsTableView = nil;
    
    //dont' need anymore
    self.geocodeService = nil;
    
    //kill all search results
    self.localFilteredResults = nil;
}

-(void)setupSearchForListAnimated:(BOOL)animated
{    
    [self.extendableToolbar showTools:NO fromRect:CGRectZero animated:YES];
    
    //Al Delete
//    //make room for button by moving search bar over
//    [self showMapListButton:YES withPlanningButton:NO animated:animated];
    
    //if we already have search items, show them in list
    if ([self.searchResults totalNumberOfItems] > 0) {
        self.resultsTableView.resultsDataSource = self.searchResults;
    }
    //show experience for filtering through list of items
   
    
    //only show bookmarks button if there is nothing to show
    //self.searchBar.showsBookmarkButton = (self.searchBar.text.length == 0);
    
    [self showResultsList:YES];
    [self.mapListButton setImage:[UIImage imageNamed:@"Map.png"]];
}

-(void)setupSearchForMapAnimated:(BOOL)animated
{
    [self.searchBar resignFirstResponder];
    [self showResultsList:NO];
    
    // Al Delete
    //[self showMapListButton:YES withPlanningButton:YES animated:YES];
    [self.mapListButton setImage:[UIImage imageNamed:@"list.png"]];
    
    //self.searchBar.showsBookmarkButton = YES;
}

-(void)showResultsList:(BOOL)show
{
    if(!show)
    {
        [self.resultsTableView removeFromSuperview];
    }
    else
    {
        if(self.resultsTableView.superview == nil)
        {
            //[self.view insertSubview:self.resultsTableView belowSubview:self.extendableToolbar];
            [self.view addSubview:self.resultsTableView];
        }
        
        [self.resultsTableView reloadData];
    }
}

//Add the Search Ux onto the screen
-(void)setupSearchUx
{    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                   target:nil 
                                                                                   action:nil];
    NSArray *items = [NSArray arrayWithObjects:self.planningButton, flexibleSpace, self.mapListButton, nil];
    self.extendableToolbar.items = items;
    
    if(self.searchBar.superview == nil)
        [self.extendableToolbar.toolsView addSubview:self.searchBar];
}

//AL Delete
//-(void)showMapListButton:(BOOL)show withPlanningButton:(BOOL)showPlanningButton animated:(BOOL)animated
//{
//    CGFloat widthOfButton = [UIBarButtonItem width];
//    
//    //don't animate the width as it looks weird
//    CGRect sbRect = self.searchBar.frame;
//    sbRect.size.width = self.view.frame.size.width - (show*widthOfButton + showPlanningButton*widthOfButton);
//    self.searchBar.frame = sbRect;
//    
//    sbRect.origin.x = (showPlanningButton) ? widthOfButton : 0;
//    
//    if(animated)
//    {
//        [UIView animateWithDuration:.1 animations:^
//        {
//            self.searchBar.frame = sbRect;
//        }
//         ];
//    }
//    else
//    {
//        self.searchBar.frame = sbRect;
//    }
//}

-(void)removeOldResults
{
    //Remove old graphics from map
    [self.searchLayer removeAllGraphics];
    [self.searchLayer dataChanged];
    
    //Remove old results from model results object
    [self.searchResults clear];
    
    self.searchResults = nil;
}

#pragma mark -
#pragma mark Location Delegate
-(void)location:(Location *)loc updatedPoint:(AGSPoint *)point
{    
    [self showActivityIndicator:NO];
    [self dropPinForSearchLocation:loc zoomToLocation:YES showCallout:YES];       
}

-(void)locationFailedToAttainNewPoint:(Location *)location
{
    [self showActivityIndicator:NO];
}

-(NSUInteger)transitIndexForLocation:(Location *)location
{
    return [self.planningRoute.stops indexOfItem:location];
}

#pragma mark -
#pragma mark Geocode Service Delegate
- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFindLocationsForAddress:(NSArray *)places
{
    if (places != nil && places.count > 0) {
        
        DrawableList *addrList = [[DrawableList alloc] initWithName:NSLocalizedString(@"Addresses", nil) 
                                                          withItems:nil];
        
        for(AGSAddressCandidate *addr in places)
        {
            LocationBookmark *newLoc = [[LocationBookmark alloc] initWithName:addr.addressString
                                                                       anIcon:[UIImage imageNamed:@"AddressPin.png"]
                                                                   locatorURL:[NSURL URLWithString:_app.config.locatorServiceUrl]];
            newLoc.addressCandidate = addr;
            newLoc.geometry = [addr.location copy];
            
            [addrList addItem:newLoc];
        }
        
        [self.searchResults addList:addrList];
        
        [self.resultsTableView reloadData];
    }
    
    [self searchFinishedExecuting];
}

- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFailLocationsForAddress:(NSError *)error
{
    //Failed to find any addresses... just continue executing
    [self searchFinishedExecuting];
}

- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFindPlace:(NSArray *)places
{
    if (places != nil && places.count > 0) {
        
        DrawableList *placeList = [[DrawableList alloc] initWithName:NSLocalizedString(@"Places", nil) 
                                                          withItems:nil];
        
        [self.searchResults addList:placeList];
        
        [self.resultsTableView reloadData];
    }
    
    [self searchFinishedExecuting];
}
- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFailFindPlace:(NSError *)error
{
    //Couldn't find any places... just continue executing
    [self searchFinishedExecuting];
}


- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFindPOI:(NSArray *)places
{
    if (places != nil && places.count > 0) {
        
        DrawableList *addrList = [[DrawableList alloc] initWithName:NSLocalizedString(@"NearBy", nil)
                                                          withItems:nil];
        
        for(FindPOI *addr in places)
        {
            LocationBookmark *newLoc = [[LocationBookmark alloc] initWithName:addr.name
                                                                       anIcon:[UIImage imageNamed:@"AddressPin.png"]
                                                                   locatorURL:[NSURL URLWithString:_app.config.locatorServiceUrl]];
            newLoc.addressCandidate = nil;
            newLoc.geometry = addr.location;
            
            [addrList addItem:newLoc];
        }
        
        [self.searchResults addList:addrList];
        
        [self.resultsTableView reloadData];
    }
    
    [self searchFinishedExecuting];
}

- (void)geocodeService:(GeocodeService *)geocodeService operation:(NSOperation*)op didFailFindPOI:(NSError *)error
{
    //Couldn't find any places... just continue executing
    [self searchFinishedExecuting];
}
@end

//
//  MapViewController.m
//  Map
//
//  Created by Scott Sirowy on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "MapViewController+MapTapping.h"
#import "MapViewController+Search.h"
#import "MapViewController+PlanningRouting.h"

#import "MapSettings.h"
#import "MapAppDelegate.h"
#import "MapAppSettings.h"
#import "UIToolbar+MapAdditions.h"
#import "UIColor+Additions.h"
#import "DrawableResultsTableView.h"
#import "MapContentViewController.h"
#import "Organization.h"
#import "CurrentLocation.h"
#import "ArcGISMobileConfig.h"
#import "StopsList.h"
#import "DirectionsList.h"
#import "Direction.h"
#import "OverviewDirection.h"
#import "DirectionsPrintRenderer.h"
#import "TabbedResultsViewController.h"
#import "Bookmarks.h"
#import "Route.h"
#import "ContactsManager+ContactsManager_DrawableList.h"
#import "MapShareUtility.h"
#import "Legend.h"
#import "Route.h"
#import "RouteSolver.h"
#import "SignsView.h"
#import "LocationGraphic.h"
#import "AGSGeometry+AppAdditions.h"
#import "ExtendableToolbar.h"
#import "UIBarButtonItem+AppAdditions.h"

#import "OrganizationChooserViewController.h"

#import "ContactLocationBookmark.h"
#import "Location.h"

#import "Search.h"
#import "UserSearchResults.h"

#import "BookmarksViewController-Iphone.h"

#define gpsAutoPanKey          @"autoPanMode"
#define gpsEnabledKey          @"enabled"
#define kHeightOfToolbar       44

#define kPrintWithIcons        1

@interface MapViewController () 

-(void)toggleLocateMeAutoPan;
-(void)enableGpsAutoPan;

-(void)endRouteModeToState:(MapAppState)state animated:(BOOL)animated;
-(void)showSearchLayer:(BOOL)show;

-(void)routeActionButtonPressed:(id)sender;
-(void)routeFinishedButtonPressed:(id)sender;
-(void)modifyRouteButtonPressed:(id)sender;
-(void)routeRefreshButtonPressed:(id)sender;
-(void)routeSettingsButtonPressed:(id)sender;
-(void)routeButtonPressed:(id)sender;
-(void)clearRouteButtonPressed:(id)sender;

-(void)planningButtonPressed:(id)sender event:(UIEvent *)event;

-(void)setupRoutingUx;

-(AGSMutableEnvelope *)refactoredEnvelopeFromEnvelope:(AGSEnvelope *)envelope;

-(void)shareDirectionsViaEmail;
-(void)displayComposerSheetForSharingDirections;
-(void)shareLocationViaEmail:(Location *)location;
-(void)displayComposerSheetForSharingLocation:(Location *)location;
-(void)printDirections;

-(NSUInteger)getAdjustedIndexForMapTapIndex:(NSUInteger)buttonIndex;

@property (nonatomic, unsafe_unretained) ArcGISAppDelegate                     *app;
@property (nonatomic, strong) AGSWebMap                             *customBasemap;

/*Other pages we can see from the map page */
@property (nonatomic, strong) UINavigationController                *mapContentVC;

/*Routing properties */
@property (nonatomic, strong) RouteSolver                           *routeSolver;

//Temporary!!
@property (nonatomic, strong) OrganizationChooserViewController     *orgChooserVC;

@end

@implementation MapViewController

@synthesize mapView                     = _mapView;
@synthesize mapContainerView            = _mapContainerView;
@synthesize gpsButton                   = _gpsButton;
@synthesize layersButton                = _layersButton;

@synthesize extendableToolbar           = _extendableToolbar;
@synthesize searchBar                   = _searchBar;
@synthesize toolbarImageView            = _toolbarImageView;
@synthesize mapListButton               = _mapListButton;
@synthesize planningButton              = _planningButton;
@synthesize routeButton                 = _routeButton;
@synthesize clearRouteButton            = _clearRouteButton;
@synthesize routeSettingsButton         = _routeSettingsButton;
@synthesize routeRefreshButton          = _routeRefreshButton;
@synthesize routeActionButton           = _routeActionButton;
@synthesize routeFinishedButton         = _routeFinishedButton;
@synthesize locationCallout             = _locationCallout;
@synthesize routeOverviewLabel          = _routeOverviewLabel;
@synthesize activityIndicator           = _activityIndicator;
@synthesize activityIndicatorView       = _activityIndicatorView;
@synthesize planningToolsView           = _planningToolsView;

@synthesize identifyLayer               = _identifyLayer;
@synthesize searchLayer                 = _searchLayer;
@synthesize routeLayer                  = _routeLayer;
@synthesize planningLayer               = _planningLayer;

@synthesize identifyLocation            = _identifyLocation;

@synthesize mapContentVC                = _mapContentVC;
@synthesize resultsTableView            = _resultsTableView;
@synthesize directionsView              = _directionsView;
@synthesize stopsView                   = _stopsView;

@synthesize localFilteredResults        = _userSearchResults;
@synthesize searchResults               = _searchResults;
@synthesize geocodeService              = _geocodeService;

@synthesize selectedFeaturePopupInfos   = _selectedFeaturePopupInfos;
@synthesize popupsViewController        = _popupsViewController;
@synthesize queryOperations             = _queryOperations;

@synthesize mapAppSettings              = _mapAppSettings;

@synthesize currentDirectionSymbol      = _currentDirectionSymbol;
@synthesize currentDirectionGraphic     = _currentDirectionGraphic;
@synthesize turnHighlightGraphic        = _turnHighlightGraphic;
@synthesize turnHighlightSymbol         = _turnHighlightSymbol;
@synthesize routeSymbol                 = _routeSymbol;
@synthesize routeSolver                 = _routeSolver;
@synthesize currentRoute                = _currentRoute;
@synthesize planningRoute               = _planningRoute;

@synthesize app                         = _app;
@synthesize customBasemap               = _customBasemap;
@synthesize mapLoaded                   = _mapLoaded;
@synthesize shareWithMapUrl             = _shareWithMapUrl;
@synthesize callbackString              = _callbackString;

@synthesize orgChooserVC                = _orgChooserVC;

#pragma mark -
#pragma mark End of View Lifetime

- (void)dealloc
{
    if (_observingGPS) {
        [self.mapView.gps removeObserver:self forKeyPath:gpsAutoPanKey];
        [self.mapView.gps removeObserver:self forKeyPath:gpsEnabledKey];
        _observingGPS = NO;
    }
    
    
    
    
    
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
    //map content view controller can be rederived
    self.mapContentVC = nil;
    
    if (self.resultsTableView.superview == nil) {
        self.resultsTableView = nil;
    }
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.mapView.wrapAround = YES;
	self.mapView.showMagnifierOnTapAndHold = YES;
	self.mapView.layerDelegate = self;
	self.mapView.touchDelegate = self;
	self.mapView.calloutDelegate = self;
	self.mapView.gps.infoTemplateDelegate = self;
	self.mapView.backgroundColor = [UIColor darkBackgroundColor];
    
    if(self.extendableToolbar.superview == nil)
        [self.view addSubview:self.extendableToolbar];
    
    [self setupSearchUx];
    
    [self showActivityIndicator:YES];
}


- (void)viewDidUnload
{
    if (_observingGPS) {
        [self.mapView.gps removeObserver:self forKeyPath:gpsAutoPanKey];
        [self.mapView.gps removeObserver:self forKeyPath:gpsEnabledKey];
        _observingGPS = NO;
    }
    
    self.mapView                = nil;
    self.mapContainerView       = nil;
    self.extendableToolbar      = nil;
    self.gpsButton              = nil;
    self.layersButton           = nil;
    self.searchBar              = nil;
    self.toolbarImageView       = nil;
    self.mapListButton          = nil;
    self.planningButton         = nil;
    self.routeButton            = nil;
    self.clearRouteButton       = nil;
    self.routeSettingsButton    = nil;
    self.routeActionButton      = nil;
    self.routeFinishedButton    = nil;
    self.routeRefreshButton     = nil;
    self.routeOverviewLabel     = nil;
    self.activityIndicator      = nil;
    self.activityIndicatorView  = nil;
    self.planningToolsView      = nil;
    
    self.mapContentVC = nil;
    self.resultsTableView = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.app shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark -
#pragma mark Lazy Loads
-(ArcGISAppDelegate *)app
{
    if(_app == nil)
        self.app = (ArcGISAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    return _app;
}

///View to disable everything
-(UIView *)activityIndicatorView
{
    if (_activityIndicatorView == nil) {
        UIView *aView = [[UIView alloc]initWithFrame:self.view.bounds];
        aView.hidden = YES;
        aView.userInteractionEnabled = YES;
        aView.opaque = NO;
        aView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.65];
        aView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //build an animated activity indicator into view
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.center = CGPointMake(aView.bounds.size.width/2, aView.bounds.size.height/2);
        self.activityIndicator.userInteractionEnabled = NO;
        self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.activityIndicator stopAnimating];
        
        [aView addSubview:self.activityIndicator];
        
        self.activityIndicatorView = aView;
    }
    
    return _activityIndicatorView;
}

-(UIView *)planningToolsView
{
    if(_planningToolsView == nil)
    {        
        UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [ExtendableToolbar heightOfSupplementalToolsView])];
        tb.barStyle = UIBarStyleBlackTranslucent;
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                       target:nil action:nil];
        
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil action:nil];
        fixedSpace.width = 10;
        
        tb.items = [NSArray arrayWithObjects:self.routeSettingsButton, fixedSpace, self.clearRouteButton, flexibleSpace, self.routeButton, nil];
                                
        self.planningToolsView = tb;
    }
    
    return _planningToolsView;
}

 -(UINavigationController *)mapContentVC
 {
     if (_mapContentVC == nil) {
         
         
         MapContentViewController *mcvc = [[MapContentViewController alloc] initWithMapLayerViews:self.mapView.mapLayerViews];
         mcvc.changeBasemapDelegate = self;
         
         UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:mcvc];
         nvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
         nvc.navigationBar.barStyle = UIBarStyleBlackOpaque;
         self.mapContentVC = nvc;
     }
     
     return _mapContentVC;
 }  

-(ExtendableToolbar *)extendableToolbar
{
    if(_extendableToolbar == nil)
    {
        CGFloat sizeOfToolbar = 44;
        ExtendableToolbar *etb = [[ExtendableToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, sizeOfToolbar) showToolsBelowToolbar:NO];
        
        etb.supplementalToolsView = self.planningToolsView;
        
        self.extendableToolbar = etb;
    }
    
    return _extendableToolbar;
}

-(UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        CGFloat widthOfBarButton = [UIBarButtonItem width];
        
        UISearchBar *sb = [[UISearchBar alloc]initWithFrame:CGRectMake(widthOfBarButton, 1, self.view.frame.size.width - widthOfBarButton, 40)];
        sb.tintColor = [UIColor blackColor];
        sb.placeholder = NSLocalizedString(@"Enter address, place name, etc", nil);
        sb.delegate = self;
        sb.showsBookmarkButton = YES;
        self.searchBar = sb;
    }
    
    return _searchBar;
}

-(DrawableResultsTableView *)resultsTableView
{
    if(_resultsTableView == nil)
    {
        CGFloat heightOfToolbar = 44;
        CGRect tvFrame = CGRectMake(0, heightOfToolbar, self.mapView.frame.size.width, self.mapView.frame.size.height -heightOfToolbar);
        DrawableResultsTableView *tv = [[DrawableResultsTableView alloc] initWithFrame:tvFrame style:UITableViewStylePlain];
        self.resultsTableView = tv;
        self.resultsTableView.resultsDelegate = self;
    }
    
    return _resultsTableView;
}

-(UIBarButtonItem *)planningButton
{
    if(_planningButton == nil)
    {
        //Using a custom signature for the selector so we can pass important information to the extendable
        //toolbar about the location of the button on the toolbar itself
        UIBarButtonItem *pb = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                          target:self 
                                                                          action:@selector(planningButtonPressed:event:)];
        self.planningButton = pb;
    }
    
    return _planningButton;
}

-(UIBarButtonItem *)routeSettingsButton
{
    if(_routeSettingsButton == nil)
    {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] 
                                                                style:UIBarButtonItemStylePlain 
                                                               target:self action:@selector(routeSettingsButtonPressed:)];
        
        self.routeSettingsButton = bbi;
    }
    
    return _routeSettingsButton;
}

-(UIBarButtonItem *)routeButton
{
    if(_routeButton == nil)
    {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Route" , nil)
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(routeButtonPressed:)];
        
        bbi.enabled = NO;
        self.routeButton = bbi;
    }
    
    return _routeButton;
}

-(UIBarButtonItem *)clearRouteButton
{
    if(_clearRouteButton == nil)
    {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                                                             target:self 
                                                                             action:@selector(clearRouteButtonPressed:)];
        self.clearRouteButton = bbi;
    }
    
    return _clearRouteButton;
}

-(UIBarButtonItem *)mapListButton
{
    if(_mapListButton == nil)
    {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Map.png"] 
                                                                style:UIBarButtonItemStylePlain 
                                                               target:self 
                                                               action:@selector(mapListButtonPressed:)];
        self.mapListButton = bbi;
        
    }
    
    return _mapListButton;
}

-(UIBarButtonItem *)routeActionButton
{
    if(_routeActionButton == nil)
    {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                             target:self 
                                                                             action:@selector(routeActionButtonPressed:)];
        self.routeActionButton = bbi;
        
    }
    
    return _routeActionButton;
}

-(UIBarButtonItem *)routeFinishedButton
{
    if(_routeFinishedButton == nil)
    {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(routeFinishedButtonPressed:)];
        self.routeFinishedButton = bbi;
        
    }
    
    return _routeFinishedButton;
}

-(UIBarButtonItem *)routeRefreshButton
{
    if(_routeRefreshButton == nil)
    {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                             target:self 
                                                                             action:@selector(routeRefreshButtonPressed:)];
        self.routeRefreshButton = bbi;
        
    }
    return _routeRefreshButton;
}

-(UILabel *)routeOverviewLabel
{
    if(_routeOverviewLabel == nil)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kHeightOfToolbar)];
        label.font = [UIFont boldSystemFontOfSize:19.0];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        
        self.routeOverviewLabel = label;
    }
    
    return _routeOverviewLabel;
}

/*Layer that allows user to tap on map and see a pin indicating he's identifying */
-(AGSGraphicsLayer *)identifyLayer
{
    if(_identifyLayer == nil)
    {
        self.identifyLayer = [AGSGraphicsLayer graphicsLayer];
    }
    return _identifyLayer;
}

/*Layer that shows all search results */
-(AGSGraphicsLayer *)searchLayer
{
    if(_searchLayer == nil)
    {
        self.searchLayer = [AGSGraphicsLayer graphicsLayer];
    }
    return _searchLayer;
}

/* Layer that shows all route info (not including the actual stops on the route) */
-(AGSGraphicsLayer *)routeLayer
{
    if(_routeLayer == nil)
    {
        self.routeLayer = [AGSGraphicsLayer graphicsLayer];
    }
    return _routeLayer;
}

/* Layer that shows all stops for a route */
-(AGSGraphicsLayer *)planningLayer
{
    if(_planningLayer == nil)
    {
        self.planningLayer = [AGSGraphicsLayer graphicsLayer];
    }
    
    return _planningLayer;
}

-(AGSCompositeSymbol*)routeSymbol
{
    if (_routeSymbol == nil) {
        self.routeSymbol = [AGSCompositeSymbol compositeSymbol];
        [self.routeSymbol.symbols addObject:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:(100.0)/255 green:(100.0)/255 blue:(100.0)/255 alpha:1.0]
                                                                                     width:8.0f]];
        
        [self.routeSymbol.symbols addObject:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:(107.0)/255 green:(107.0)/255 blue:(107.0)/255 alpha:1.0]
                                                                                     width:7.5f]];
        
        [self.routeSymbol.symbols addObject:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:(115.0)/255 green:(115.0)/255 blue:(115.0)/255 alpha:1.0]
                                                                                     width:7.0f]];
        
        [self.routeSymbol.symbols addObject:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:(130.0)/255 green:(130.0)/255 blue:(130.0)/255 alpha:1.0]
                                                                                     width:5.0f]];
        
        [self.routeSymbol.symbols addObject:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:(145.0)/255 green:(145.0)/255 blue:(145.0)/255 alpha:1.0]
                                                                                     width:2.5f]]; 
    
        
        [self.routeSymbol.symbols addObject:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:(170.0)/255 green:(170.0)/255 blue:(170.0)/255 alpha:1.0]
                                                                                     width:1.0f]];  
    }
    
    return _routeSymbol;
}

-(AGSCompositeSymbol*)turnHighlightSymbol
{
    if (_turnHighlightSymbol == nil) {
        self.turnHighlightSymbol = [AGSCompositeSymbol compositeSymbol];
        
        AGSSimpleMarkerSymbol *cms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[[UIColor blackColor] colorWithAlphaComponent:.3]];
        cms.style = AGSSimpleMarkerSymbolStyleCircle;
        cms.size = 55;
        
        AGSSimpleLineSymbol *blackLine = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor darkGrayColor]];
        blackLine.width = 2;
                
        cms.outline = blackLine;
        
        [self.turnHighlightSymbol.symbols addObject:cms];
    }
    
    return _turnHighlightSymbol;
}

- (AGSGraphic*)turnHighlightGraphic 
{
    
    if(_turnHighlightGraphic == nil)
    {
        self.turnHighlightGraphic = [AGSGraphic graphicWithGeometry:nil 
                                                                symbol:self.turnHighlightSymbol 
                                                            attributes:nil 
                                                  infoTemplateDelegate:nil];
    }
    
    return _turnHighlightGraphic;
}


-(AGSCompositeSymbol*)currentDirectionSymbol
{
    if (_currentDirectionSymbol == nil) {
        self.currentDirectionSymbol = [AGSCompositeSymbol compositeSymbol];
        
        [self.currentDirectionSymbol.symbols addObject:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:(57.0)/255 green:(121.0)/255 blue:(215.0)/255 alpha:1.0]
                                                                                     width:9.0f]];
        
        [self.currentDirectionSymbol.symbols addObject:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:(77.0)/255 green:(139.0)/255 blue:(219.0)/255 alpha:1.0]
                                                                                     width:7.0f]];
        
        [self.currentDirectionSymbol.symbols addObject:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:(117.0)/255 green:(173.0)/255 blue:(227.0)/255 alpha:1.0]
                                                                                     width:6.0f]];
        
        [self.currentDirectionSymbol.symbols addObject:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:(154.0)/255 green:(205.0)/255 blue:(235.0)/255 alpha:1.0]
                                                                                     width:5.0f]];
        
        [self.currentDirectionSymbol.symbols addObject:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:(176.0)/255 green:(221.0)/255 blue:(239.0)/255 alpha:1.0]
                                                                                     width:2.5f]];  
    }
    
    return _currentDirectionSymbol;
}

- (AGSGraphic*)currentDirectionGraphic {
    
    if(_currentDirectionGraphic == nil)
    {
        self.currentDirectionGraphic = [AGSGraphic graphicWithGeometry:nil 
                                                                symbol:self.currentDirectionSymbol 
                                                            attributes:nil 
                                                  infoTemplateDelegate:nil];
    }
    
    return _currentDirectionGraphic;
}

#pragma mark -
#pragma mark Toolbar Setup
-(void)setupRoutingUx
{
    [self.searchBar removeFromSuperview];
    
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity:3];
    
    [toolbarItems addObject:self.routeActionButton];
    
    UIBarButtonItem *flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                          target:nil 
                                                                                          action:nil];
    
    [toolbarItems addObject:flexibleSpaceButton];
    
    //only show refresh button if they are routing using current location
    if (_usingCurrentLocation) {
        
        UIBarButtonItem *fixedSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
                                                                                           target:nil 
                                                                                           action:nil];
        fixedSpaceButton.width = 5;
        
        
        [toolbarItems addObject:self.routeRefreshButton];
        [toolbarItems addObject:fixedSpaceButton];
    }
    
    [toolbarItems addObject:self.routeFinishedButton];
    
    self.extendableToolbar.items = toolbarItems;
    
    [self.extendableToolbar showTools:NO fromRect:CGRectZero animated:YES];
    
    if (self.routeOverviewLabel.superview == nil) {
        [self.view addSubview:self.routeOverviewLabel];
        self.routeOverviewLabel.text = NSLocalizedString(@"Overview", nil);
    } 
    
    //hide the search and identify layers until we are done
    [self showSearchLayer:NO];
}
            
#pragma mark -
#pragma mark Button Interaction
-(void)planningButtonPressed:(id)sender event:(UIEvent *)event
{
    //get rect from touched view
    CGRect rect = [[event.allTouches anyObject] view].frame;
    
    BOOL showPlanning = (_appState != MapAppStatePlanning);
    [self.extendableToolbar showTools:showPlanning fromRect:rect animated:YES];
    _appState = showPlanning ? MapAppStatePlanning : MapAppStateSimple;
    
    //add/remove graphics as necessary
    if(showPlanning)
    {
        //add graphics to map
        [self.planningRoute.stops addStopsToLayer:self.planningLayer showCurrentLocation:NO];
        
        AGSEnvelope *planningEnv = [self.planningRoute envelopeInMapView:self.mapView];
        if (planningEnv) {
            [self.mapView zoomToEnvelope:planningEnv animated:YES];
        }
    }
    else
    {
        [self.planningLayer removeAllGraphics];
    }
    
    [self showStopSigns:showPlanning];
    
    [self.planningLayer dataChanged];
}

-(void)layersButtonPressed:(id)sender
{
    [self presentModalViewController:self.mapContentVC animated:YES];
}

-(void)routeFinishedButtonPressed:(id)sender
{
    [self endRouteModeToState:MapAppStateSimple animated:YES];
    
    //Route was shared by an app and wants to be called back
    if (self.callbackString != nil) {
    
        self.callbackString = [NSString stringWithFormat:@"%@://", self.callbackString];
        NSURL *urlToOpen = [NSURL URLWithString:self.callbackString];
        
        if ([[UIApplication sharedApplication] canOpenURL:urlToOpen]) {
            [[UIApplication sharedApplication] openURL:urlToOpen];
        }
        
        self.callbackString = nil;
    }
}

-(void)modifyRouteButtonPressed:(id)sender
{
    [self endRouteModeToState:MapAppStatePlanning animated:YES];
}

-(void)routeActionButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:NSLocalizedString(@"Modify Route", nil),
                                                                      NSLocalizedString(@"Share Directions via Email", nil), 
                                                                      NSLocalizedString(@"Print Directions", nil), nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = kRouteActionSheetTag;
    
    [actionSheet showInView:self.view];
}

-(void)routeRefreshButtonPressed:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Refresh" 
                                                 message:@"Need to refresh route" 
                                                delegate:nil 
                                       cancelButtonTitle:@"OK" 
                                       otherButtonTitles:nil];
    [av show];
}

-(void)routeSettingsButtonPressed:(id)sender
{
    NSLog(@"Route Settings button pressed!");
}

-(void)clearRouteButtonPressed:(id)sender
{
    [self showStopSigns:NO];
    
    //Clear model object
    [self.planningRoute removeAllStops];
    
    //Clear view of all stops
    [self.planningLayer removeAllGraphics];
    [self.planningLayer dataChanged];
    
    self.routeButton.enabled = NO;
}

-(void)routeButtonPressed:(id)sender
{
    _appState = MapAppStateRoute;
    [self showActivityIndicator:YES];
    
    self.currentRoute = self.planningRoute;
    [self.routeSolver solveRoute:self.currentRoute];
    [self showStopSigns:NO];
}

-(IBAction)locateMeButtonPressed:(id)sender
{
    [self toggleLocateMeAutoPan];
}

-(void)toggleLocateMeAutoPan
{
    //The gps state will change based on the current state.  There are two states we'll switch
    //to and three states we'll switch from:
    //
    //If the gps is On (autopan either on or off), set the state to Off
    //if the gps is Off, set the state to On with autopan
    //
    //if the map isn't loaded yet, then we're trying to turn on the GPS because the
    //gps won't have been enabled yet
    
    AGSGPS *gps = self.mapView.gps;
#warning Check for maploaded?!
    if (!gps.enabled)
    {
        [self enableGpsAutoPan];
    }
    else //gps is enabled
    {
        //disable gps
        [gps stop];
    }
}

-(void)enableGpsAutoPan
{    
    AGSGPS *gps = self.mapView.gps;
    if (!gps.enabled)
    {
        //start GPS
        [gps start];
        gps.autoPanMode = AGSGPSAutoPanModeDefault;
        
        //return because we're starting the gps and it might take a while
        return;
    }
	
	// all other times
    [self.mapView centerAtPoint:gps.currentPoint animated:YES];
    
    //this needs to be done after centerAtPoint so that call doesn't
    //reset the autopan property.
    gps.autoPanMode = AGSGPSAutoPanModeDefault;
}

#pragma mark -
#pragma mark Misc. Public Methods
-(void)shareInformationWithMap:(MapShareUtility *)msi
{
    //Need to account for if user is already in route/plan mode here...
    
    if (msi.shareType == MapShareInterfaceShareRoute) {
        
        //remove all graphics from planning layer if there are some
        [self.planningLayer removeAllGraphics];
        self.planningRoute = nil;
        
        //set up new plan
        self.planningRoute = msi.route;
        
        //shortcut planning if user has only sent a destination...
        if (self.planningRoute.stops.numberOfStops == 2 && [self.planningRoute routesFromCurrentLocation]) {
            [self routeButtonPressed:nil];
        }
        //go into planning mode
        else
        {
            [self.extendableToolbar showTools:YES fromRect:CGRectZero animated:YES];
            [self.planningRoute.stops addStopsToLayer:self.planningLayer showCurrentLocation:NO];
            
            [self.planningLayer dataChanged];
            
            _appState = MapAppStatePlanning;
            self.routeButton.enabled = [self.planningRoute canRoute];
            
            [self showStopSigns:YES];
            
            [self.mapView zoomToEnvelope:[self.planningRoute envelopeInMapView:self.mapView] animated:YES];
        }
    }
    //sharing a location
    else
    {
        if (msi.shareLocation) {
            [self dropPinForSearchLocation:msi.shareLocation zoomToLocation:YES showCallout:YES];
        }
    }
    
    self.callbackString = msi.callbackString;
}
-(MapAppSettings *)mapAppSettings
{
    return (MapAppSettings *)self.app.appSettings;
}

-(void)showActivityIndicator:(BOOL)show
{
    if (self.activityIndicatorView.superview == nil) {
        [self.view addSubview:self.activityIndicatorView];
    }
    
	if (!show){
		[self.activityIndicator stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
	}
	else {
		[self.activityIndicator startAnimating];
	}
	self.activityIndicatorView.hidden = !show;
}

#pragma mark -
#pragma mark Key Value Observing Stuff
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //highlight/select GPS button as necessary
    if ([keyPath isEqualToString:gpsAutoPanKey] || [keyPath isEqualToString:gpsEnabledKey]){
        BOOL bSelected = self.mapView.gps.enabled && (self.mapView.gps.autoPanMode == AGSGPSAutoPanModeDefault);
        BOOL bHighlighted = self.mapView.gps.enabled && (self.mapView.gps.autoPanMode != AGSGPSAutoPanModeDefault);
                
		self.gpsButton.selected = bSelected;
        self.gpsButton.highlighted = bHighlighted;
	}
}

#pragma mark -
#pragma mark MapViewLayerDelegate
- (void)mapViewDidLoad:(AGSMapView *)mapView
{
    //Setup GPS observing stuff
    if (_observingGPS)
    {
        //remove our observers only if we've already loaded the web map...
        [self.mapView.gps removeObserver:self forKeyPath:gpsAutoPanKey];
        [self.mapView.gps removeObserver:self forKeyPath:gpsEnabledKey];
        _observingGPS = NO;
    }
    
    if (!_observingGPS) {
        [self.mapView.gps addObserver:self forKeyPath:gpsAutoPanKey options:NSKeyValueObservingOptionNew context:nil];
        [self.mapView.gps addObserver:self forKeyPath:gpsEnabledKey options:NSKeyValueObservingOptionNew context:nil];
        _observingGPS = YES;
    }
}

#pragma mark -
#pragma mark ChangeBasemapDelegate
-(void)basemapsViewController:(BasemapsViewController *)bmvc wantsToChangeToNewBasemap:(BasemapInfo *)basemap
{
    _changingBasemap = YES;
    
    self.mapAppSettings.savedExtent = self.mapView.visibleArea.envelope;
    
    if (basemap.isDefaultBasemap) {
        self.mapAppSettings.customBasemap = nil;
        [self.mapAppSettings.organization.webmap openIntoMapView:self.mapView];
    }
    else
    {
        self.mapAppSettings.customBasemap = basemap;
        self.customBasemap = [AGSWebMap webMapWithURL:[NSURL URLWithString:basemap.urlString] credential:nil];
        self.customBasemap.delegate = self;
    }
}

#pragma mark -
#pragma mark Organization Delegate

-(void)organization:(Organization *)org didDownloadWebmap:(AGSWebMap *)webmap
{    
    //make map controller the delegate now
    webmap.delegate = self;
    [webmap openIntoMapView:self.mapView];
    
    //clear out...
    self.mapContentVC = nil;
    self.mapAppSettings.savedExtent = nil;
    self.routeSolver = nil;
    
    self.planningRoute = self.currentRoute = nil;
    
    [self.planningLayer removeAllGraphics];
    [self.planningLayer dataChanged];
    
    [self.routeLayer removeAllGraphics];
    [self.routeLayer dataChanged];
    
    [self endRouteModeToState:MapAppStateSimple animated:YES];
    [self setSearchState:MapSearchStateDefault withKeyboard:NO animated:NO];
}

#pragma mark -
#pragma mark AGSWebMapDelegate Methods

/*
 Using web map delegate load method here to load new basemap.  The actual
 webmap for the organization is loaded somewhere else
 */
- (void)webMapDidLoad:(AGSWebMap *)webMap
{
    //load current map (the organization web map) with the new basemap
    [self.mapAppSettings.organization.webmap openIntoMapView:self.mapView withAlternateBaseMap:webMap.baseMap];
}

-(void)didOpenWebMap:(AGSWebMap*)webMap intoMapView:(AGSMapView*)mapView
{
    if(_routeSolver == nil)
    {
        //by intializing, we are automatically going out to get defaults
        self.routeSolver = [[RouteSolver alloc] initWithSpatialReference:self.mapView.spatialReference 
                                                        routingServiceUrl:self.mapAppSettings.organization.routeUrl];
        self.routeSolver.delegate = self;
    }
    
    [self showActivityIndicator:NO];
    
    [self.mapView addMapLayer:self.identifyLayer withName:@"Identify Layer"];
    [self.mapView addMapLayer:self.searchLayer withName:@"Search Layer"];
    [self.mapView addMapLayer:self.routeLayer withName:@"Route Layer"];
    [self.mapView addMapLayer:self.planningLayer withName:@"Planning Layer"];
    
    if (self.mapAppSettings.savedExtent) {
        [self.mapView zoomToEnvelope:self.mapAppSettings.savedExtent animated:NO];
    }
    #warning Remove once portal API is implemented
    else if(self.mapAppSettings.organization.defaultEnvelope)
    {
        [self.mapView zoomToEnvelope:self.mapAppSettings.organization.defaultEnvelope animated:NO];
    }
    //if we are changing the basemap, we need to inform the basemap controller
    //the basemap has been successfully changed
    if(_changingBasemap)
    {
        //map content controller is housed inside of the nav controller. Get it out quickly
        MapContentViewController *mcvc = (MapContentViewController *)[[self.mapContentVC viewControllers] objectAtIndex:0];
        [mcvc successfullyChangedBasemap];
        
        _changingBasemap = NO;
    }
    
    self.mapLoaded = YES;
    
    //app was called with a URL when not open... We need to start the routing process!
    if(self.shareWithMapUrl)
    {
        MapShareUtility *msi = [[MapShareUtility alloc] initWithUrl:self.shareWithMapUrl 
                                                          withSpatialReference:self.mapView.spatialReference 
                                                                    locatorURL:[NSURL URLWithString:_app.config.locatorServiceUrl]];
        
        [self shareInformationWithMap:msi];
        
        //nil out string since we don't anymore
        self.shareWithMapUrl = nil;
    }
    
    self.mapAppSettings.legend = [[Legend alloc] initWithMapLayerInfos:webMap.operationalLayers 
                                                            withMapView:self.mapView];
    [self.mapAppSettings.legend buildLegend];
}

- (void)webMap:(AGSWebMap *)webMap didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Fail!");
}

-(void)didFailToLoadLayer:(NSString*)layerTitle withError:(NSError*)error
{
    //NSLog(@"Layer failed to load: %@", layerTitle);
}

/** Called when a layer loads.
 @since 1.8
 */
-(void)didLoadLayer:(AGSLayer*)layer
{
    //NSLog(@"Layer loaded: %@!", layer.name);
}


#pragma mark -
#pragma mark UIActionSheetDelegate
-(NSUInteger)getAdjustedIndexForMapTapIndex:(NSUInteger)buttonIndex
{
    NSUInteger adjusted = buttonIndex;
    
    ContactLocationBookmark *cl = (ContactLocationBookmark *)self.locationCallout.location;
    
    //adjust index if we can't make a call out
    if (![self canMakePhoneCalls] || 
        ![self.locationCallout.location isKindOfClass:[ContactLocationBookmark class]] || 
        ![cl canMakeCall]) 
    {
        adjusted++;
    }
    
    return adjusted;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet.tag == kMapTapActionSheetTag) {
        Location *tappedLocation = self.locationCallout.location;
        
        NSInteger adjustedIndex = [self getAdjustedIndexForMapTapIndex:buttonIndex];
        
        switch (adjustedIndex) {
            case 0:    //Call!
                [self makePhoneCallForContactLocation:(ContactLocationBookmark *)tappedLocation];
                break;
            case 1:    //Bookmarks!
                [self wantBookmarkForLocation:tappedLocation];
                break;
            case 2:    //Share Location via email
                [self shareLocationViaEmail:tappedLocation];
                break;
            default:
                break;
        }
    }
    else if(actionSheet.tag == kRouteActionSheetTag)
    {
        switch (buttonIndex) {
            case 0:     //wants to modify route by going into planning mode
                [self modifyRouteButtonPressed:nil];
                break;
            case 1:    //Share Directions Via Email
                [self shareDirectionsViaEmail];
                break;
            case 2:    //Print Directions
                [self printDirections];
                break;
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark Routing Methods
-(void)directToLocationFromCurrentLocation:(Location *)location
{
    _appState = MapAppStateRoute;
        
    [self showActivityIndicator:YES];
    
    SimpleRoute *simpleABRoute = [[SimpleRoute alloc] initWithDestination:location];
    
    [self.routeSolver solveRoute:simpleABRoute];
    
    //Route solver retains... we can get rid of here
}

-(void)endRouteModeToState:(MapAppState)state animated:(BOOL)animated
{
    if (_appState != MapAppStateRoute)
        return;

    //if caller passes in bogus state, just revert back to the Simple state
    _appState = (state == MapAppStateRoute) ? MapAppStateSimple : state;
    
    [self.routeOverviewLabel removeFromSuperview];
    [self setupSearchUx];
    
    //remove all graphics from the route layer
    [self.routeLayer removeAllGraphics];
    [self.routeLayer dataChanged];
    
    //show/hide planning tools as appropriate
    BOOL isPlanning =  (_appState == MapAppStatePlanning);
    [self.extendableToolbar showTools:isPlanning fromRect:CGRectZero animated:animated];
    
    //unconditionally remove all graphics from planning layer
    [self.planningLayer removeAllGraphics];
    [self.planningLayer dataChanged];

    //user wants to modify route... Make current route equal to the planning route...
    //This will blow away old planned route if there was one (i.e if user planned route,
    //got out of planning, simple routed, then wanted to modify simple route)
    if(isPlanning)
    {
        self.planningRoute = self.currentRoute;
        
        //zoom to route
        AGSEnvelope *planningEnv = [self.planningRoute envelopeInMapView:self.mapView];
        if (planningEnv) {
            [self.mapView zoomToEnvelope:planningEnv animated:YES];
        }
        
        //add stops back to layer... removing current location if exists
        [self.planningRoute.stops addStopsToLayer:self.planningLayer showCurrentLocation:NO];
        
        [self showStopSigns:YES];
        
        self.routeButton.enabled = [self.planningRoute canRoute];
    }

    self.currentRoute = nil;
    [self showSearchLayer:YES];
    
    [self showDirectionsSigns:NO directions:nil];
}

//shows/hides the identify and search graphics layers
-(void)showSearchLayer:(BOOL)show
{
    UIView *searchLayerView = [self.mapView.mapLayerViews objectForKey:self.searchLayer.name];
    searchLayerView.hidden = !show;
}

//Returns an envelope that will fit in the screen, taking into account the various control elements
//already on screen when in route mode
-(AGSMutableEnvelope *)refactoredEnvelopeFromEnvelope:(AGSEnvelope *)envelope
{
    AGSMutableEnvelope *mutEnv = [envelope mutableCopy];
    
    CGFloat sizeOfDirectionsOverlay = 85.0;
    CGFloat sizeOfToolbar = 44.0;
    CGFloat overlaySizeAndOffset = sizeOfDirectionsOverlay + self.mapContainerView.frame.size.height;
    [mutEnv expandByFactor:1.2];
    [mutEnv reaspect:CGSizeMake(self.mapView.frame.size.width, self.mapView.frame.size.height-overlaySizeAndOffset-sizeOfToolbar)];
    [mutEnv updateWithXmin:mutEnv.xmin 
                      ymin:(mutEnv.ymin - (overlaySizeAndOffset*self.mapView.resolution)) 
                      xmax:mutEnv.xmax 
                      ymax:mutEnv.ymax + (sizeOfToolbar *self.mapView.resolution)];
    
    return mutEnv;
}

#pragma mark -
#pragma mark RouteSolverDelegate
-(void)routeSolverNotReadyToRoute:(RouteSolver *)rs
{
    NSLog(@"Tried to route too early");
}

-(void)routeSolverDidFailToInitialize:(RouteSolver *)rs
{
    NSLog(@"Couldn't get routing info!"); 
}

-(void)routeSolver:(RouteSolver *)rs didSolveRoute:(Route *)route
{
#if !(TARGET_IPHONE_SIMULATOR)
    if ([self.currentRoute routesFromCurrentLocation]) {
        [self enableGpsAutoPan];
    }
#endif
    
    [self setupRoutingUx];
    
    [self showActivityIndicator:NO];
    [self setCalloutShown:NO];
    
    self.currentRoute = route;
        
    AGSGraphic *routeGraphic = [AGSGraphic graphicWithGeometry:route.directions.mergedGeometry 
                                                        symbol:self.routeSymbol 
                                                    attributes:nil 
                                          infoTemplateDelegate:nil];
        
    AGSEnvelope *routeEnvelope = [self refactoredEnvelopeFromEnvelope:routeGraphic.geometry.envelope];
    
    [self performSelectorOnMainThread:@selector(zoomToResult:) withObject:routeEnvelope waitUntilDone:NO];
        
    self.currentDirectionGraphic.geometry = routeGraphic.geometry;
    
    //Add graphics to map
    [self.routeLayer addGraphic:routeGraphic];
    [self.routeLayer addGraphic:self.currentDirectionGraphic];
        
    [self.routeLayer dataChanged];
    
    //Add all stops into route layer if not already there
    [route.stops addStopsToLayer:self.planningLayer showCurrentLocation:YES];
    
    //remove all displaced stops
    for (Location *displacedStop in route.stops.displacedStops)
    {
        [self.planningLayer removeGraphic:displacedStop.graphic];
    }
    [route.stops removeDisplacedStops];
    
    [self.planningLayer dataChanged];
    
    [self showDirectionsSigns:YES directions:route.directions];
}

-(void)routeSolver:(RouteSolver *)rs didFailToSolveRoute:(Route *)route error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) 
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Ok", nil) 
                                          otherButtonTitles:nil];
    
    [alert show];
    
    [self showActivityIndicator:NO];
    
    //[self endRouteModeToState:MapAppStatePlanning animated:YES];
}

-(void)zoomToResult:(AGSMutableEnvelope*)env {
    [self.mapView zoomToEnvelope:env animated:YES];
}


#pragma mark -
#pragma mark Sharing

-(void)shareDirectionsViaEmail
{    
    // This sample can run on devices running iPhone OS 2.0 or later  
    // The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
    // So, we must verify the existence of the above class and provide a workaround for devices running 
    // earlier versions of the iPhone OS. 
    // We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
    // We launch the Mail application on the device, otherwise.
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheetForSharingDirections];
        }
    }
}

-(void)shareLocationViaEmail:(Location *)location
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheetForSharingLocation:location];
        }
    }
}

-(void)printDirections
{
    if(![UIPrintInteractionController isPrintingAvailable])
        return;
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    
    if(pic)
    {
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = @"Directions";
        pic.printInfo = printInfo;
        
        if (kPrintWithIcons) {
            // Create an instance of our PrintPhotoPageRenderer class for use as the
            // printPageRenderer for the print job.
            DirectionsPrintRenderer *dpr = [[DirectionsPrintRenderer alloc] initWithDirections:self.currentRoute.directions];
            dpr.footerHeight = 20;
            pic.printPageRenderer = dpr;
        }
        else
        {
            UIMarkupTextPrintFormatter *textFormatter = [[UIMarkupTextPrintFormatter alloc]
                                                         initWithMarkupText:self.currentRoute.directions.directionsString];
            textFormatter.startPage = 0;
            textFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1 inch margins
            textFormatter.maximumContentWidth = 6 * 72.0;
            pic.printFormatter = textFormatter;
            pic.showsPageRange = YES;
        }
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                NSLog(@"Printing could not complete because of error: %@", error);
            }
        };
        
        [pic presentAnimated:YES completionHandler:completionHandler];
    }
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheetForSharingDirections 
{
	MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
	composer.mailComposeDelegate = self;
	
    //Add picture of overview
    UIImage *mapImage = [[self.currentRoute.directions directionAtIndex:0] mapImage];
    
    if(mapImage)
    {
        NSData *data = UIImagePNGRepresentation (mapImage);
        [composer addAttachmentData:data mimeType:@"image/png" fileName:@"RouteOverview"]; 
    }
    
    //Fill out the message subject
    [composer setSubject:NSLocalizedString(@"You have been shared directions using ArcGIS Navigator", nil)];
    
    NSString *webUrlString = [MapShareUtility urlStringForRoute:self.planningRoute];
    
	NSString *emailBody = [NSString stringWithFormat:@"%@ \n\nYou can also view the route by opening the following link in ArcGIS Navigator: %@", self.currentRoute.directions.directionsString, webUrlString];
    
	[composer setMessageBody:emailBody isHTML:YES];
    
    [self presentModalViewController:composer animated:YES];
    
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheetForSharingLocation:(Location *)location 
{
	MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
	composer.mailComposeDelegate = self;
	
    
    //Fill out the message subject
    [composer setSubject:NSLocalizedString(@"I've shared my location using ArcGIS Navigator", nil)];
    
    NSString *webUrlString = [MapShareUtility urlStringForSharingLocation:location];
    
	NSString *emailBody = [NSString stringWithFormat:@"I have shared my location with you. You can see my location by clicking on the following link: %@",webUrlString];
	[composer setMessageBody:emailBody isHTML:YES];
    
    [self presentModalViewController:composer animated:YES];
    
}

#pragma mark -
#pragma mark Mail Composer Delegate
// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{    
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark SignsViewDelegate
-(void)signsView:(SignsView *)sv didChangeToOrTapOnResult:(id<NamedGeometry>)result
{
    if (_appState == MapAppStateRoute) {
        
        [self.routeLayer removeGraphic:self.turnHighlightGraphic];
        
        AGSMutableEnvelope  *mutEnv;
        if ([result isKindOfClass:[OverviewDirection class]]) {
            self.routeOverviewLabel.text = NSLocalizedString(@"Overview", nil);
            
            mutEnv = [self refactoredEnvelopeFromEnvelope:result.geometry.envelope];
            
            self.turnHighlightGraphic.geometry = nil;
        }
        else
        {
            self.turnHighlightGraphic.geometry = [result.geometry head];
            
            self.routeOverviewLabel.text = [NSString stringWithFormat:@"%d of %d", 
                                            self.currentRoute.directions.currentIndex, 
                                            [self.currentRoute.directions numberOfItems] -1    //take out overview direction
                                            ];
            
            double fRatio = 12000.0 / self.mapView.mapScale;
            mutEnv =[self.mapView.visibleArea.envelope mutableCopy];
            [mutEnv expandByFactor:fRatio];
            [mutEnv centerAtPoint:[result.geometry head]];
            
        }
        
        [self.mapView zoomToEnvelope:mutEnv animated:YES];
        

        [self.routeLayer removeGraphic:self.currentDirectionGraphic];
        self.currentDirectionGraphic.geometry = result.geometry;
        [self.routeLayer addGraphic:self.currentDirectionGraphic]; 
        
        [self.routeLayer addGraphic:self.turnHighlightGraphic];
        
        [self.routeLayer dataChanged];
    }
}

-(void)signsViewDidHide:(SignsView *)sv
{
   [sv removeFromSuperview];
    
    if (sv == self.directionsView) {
        self.directionsView = nil;
    }
    else
    {
        self.planningRoute.stops.delegate = nil;
        self.stopsView = nil;
    }
}

#pragma mark -
#pragma mark Organization Chooser Stuff (Temporary!!)
-(void)chooseFromOrganizations:(NSArray *)organizations
{
    OrganizationChooserViewController *vc = [[OrganizationChooserViewController alloc] initWithOrganizations:organizations];
    vc.delegate = self;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    self.orgChooserVC = vc;
    
    [self presentModalViewController:self.orgChooserVC animated:YES];
}

-(void)organizationChooser:(OrganizationChooserViewController *)orgVC didChooseOrganization:(Organization *)organization
{
    [self dismissModalViewControllerAnimated:YES];
    self.orgChooserVC = nil;
    
    self.mapAppSettings.organization = organization;
    organization.delegate = self;
    [organization retrieveOrganizationWebmap];
}

@end

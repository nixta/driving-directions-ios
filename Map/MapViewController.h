/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <ArcGIS/ArcGIS.h>

//included so compiler doesn't complain about protocol definitions
#import "Organization.h"
#import "OrganizationChooserViewController.h"
#import "DrawableContainerDelegate.h"
#import "LocationCalloutView.h"
#import "BasemapsViewController.h"
#import "TabbedResultsViewController.h"
#import "SignsView.h"
#import "Location.h"
#import "Route.h"
#import "RouteSolver.h"
#import "routingDelegate.h"
#import "Location.h"

@class MapAppDelegate;
@class MapContentViewController;
@class UserSearchResults;
@class DrawableCollection;
@class Organization;
@class AGSPopupsContainerViewController;
@class MapAppSettings;
@class CurrentLocation;
@class DirectionsList;
@class MapShareUtility;
@class Route;
@class DrawableResultsTableView;
@class ExtendableToolbar;

#define kMapTapActionSheetTag 10000
#define kRouteActionSheetTag 20000

/*
 Main view controller and interface for Directions app  
 */

@interface MapViewController : UIViewController     <AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSMapViewCalloutDelegate, AGSWebMapDelegate,
                                                    AGSWebMapDelegate, OrganizationDelegate, LocationCalloutDelegate, 
                                                    UIActionSheetDelegate, ChangeBasemapsDelegate, RouteSolverDelegate,
                                                    AGSGPSInfoTemplateDelegate, SignsViewDelegate, MFMailComposeViewControllerDelegate, 
                                                    OrganizationChooserDelegate, DrawableContainerDelegate, RoutingDelegate, UISearchBarDelegate>
{
    /*Ux IB Elements */
    AGSMapView                          *_mapView;
    UIView                              *_mapContainerView;
    UIButton                            *_gpsButton;
    UIButton                            *_layersButton;
     
    /*Misc. Ux Elements */
    ExtendableToolbar                   *_extendableToolbar;
    UISearchBar                         *_searchBar;
    UIImageView                         *_toolbarImageView;
    UIBarButtonItem                     *_planningButton;
    UIBarButtonItem                     *_routeSettingsButton;
    UIBarButtonItem                     *_clearRouteButton;
    UIBarButtonItem                     *_routeButton;
    UIBarButtonItem                     *_mapListButton;
    UIBarButtonItem                     *_routeRefreshButton;
    UIBarButtonItem                     *_routeActionButton;
    UIBarButtonItem                     *_routeFinishedButton;
    UILabel                             *_routeOverviewLabel;
    LocationCalloutView                 *_locationCallout;
    UIActivityIndicatorView             *_activityIndicator;
    UIView                              *_activityIndicatorView;
    UIView                              *_planningToolsView;
      
    /*Graphics Layers*/
    AGSGraphicsLayer                    *_identifyLayer;
    AGSGraphicsLayer                    *_searchLayer;
    AGSGraphicsLayer                    *_routeLayer;
    AGSGraphicsLayer                    *_planningLayer;
    
    Location                            *_identifyLocation;
    
    /*Associated Graphics/Symbols */
    AGSGraphic                          *_currentDirectionGraphic;
    AGSGraphic                          *_turnHighlightGraphic;
    AGSCompositeSymbol                  *_routeSymbol;
    AGSCompositeSymbol                  *_currentDirectionSymbol;
    AGSCompositeSymbol                  *_turnHighlightSymbol;
    
    /*View Controllers and views accessible off of map page */
    UINavigationController              *_mapContentVC;
    DrawableResultsTableView            *_resultsTableView;
    DirectionsSignsView                 *_directionsView;
    StopsSignsView                      *_stopsView;
    
    /*Search Results Data  */
    UserSearchResults                   *_localFilteredResults;
    UserSearchResults                   *_searchResults;
    GeocodeService                      *_geocodeService;
    
    /*Popups*/
    NSMutableArray                      *_selectedFeaturePopupInfos;
    AGSPopupsContainerViewController    *_popupsViewController;
    NSMutableArray                      *_queryOperations;
    
    /*Routing*/
    RouteSolver                         *_routeSolver;
    Route                               *_currentRoute;
    Route                               *_planningRoute;
                                                     
    BOOL                                _identifyingOnIdentifyLayer;
    
    BOOL                                _mapLoaded;
    NSURL                               *_shareWithMapUrl;
    NSString                            *_callbackString;
    
@private
    MapAppState                         _appState;
    MapSearchState                      _searchState;
    
    ArcGISAppDelegate                   *__unsafe_unretained _app;
    NSUInteger                          _searchesInProgress;
    NSUInteger                          _currentSearchResultIndex;
    
    BOOL                                _observingGPS;
    BOOL                                _calloutShown;
    BOOL                                _isShowingGPSCallout;
    BOOL                                _changingBasemap;
    BOOL                                _usingCurrentLocation;
}

/*Interface Builder Ux Elements */
@property (nonatomic, strong) IBOutlet AGSMapView                   *mapView;
@property (nonatomic, strong) IBOutlet UIView                       *mapContainerView;
@property (nonatomic, strong) IBOutlet UIButton                     *gpsButton;
@property (nonatomic, strong) IBOutlet UIButton                     *layersButton;

/*Misc Ux Elements */
@property (nonatomic, strong) ExtendableToolbar                     *extendableToolbar;
@property (nonatomic, strong) UISearchBar                           *searchBar;
@property (nonatomic, strong) UIImageView                           *toolbarImageView;
@property (nonatomic, strong) UIBarButtonItem                       *mapListButton;
@property (nonatomic, strong) UIBarButtonItem                       *planningButton;
@property (nonatomic, strong) UIBarButtonItem                       *routeSettingsButton;
@property (nonatomic, strong) UIBarButtonItem                       *clearRouteButton;
@property (nonatomic, strong) UIBarButtonItem                       *routeButton;
@property (nonatomic, strong) UIBarButtonItem                       *routeRefreshButton;
@property (nonatomic, strong) UIBarButtonItem                       *routeActionButton;
@property (nonatomic, strong) UIBarButtonItem                       *routeFinishedButton;
@property (nonatomic, strong) UILabel                               *routeOverviewLabel;
@property (nonatomic, strong) LocationCalloutView                   *locationCallout;
@property (nonatomic, strong) UIActivityIndicatorView               *activityIndicator;
@property (nonatomic, strong) UIView                                *activityIndicatorView;
@property (nonatomic, strong) UIView                                *planningToolsView;


/*Graphics Layers and associated graphics symbols on top of web map */
@property (nonatomic, strong) AGSGraphicsLayer                      *identifyLayer;
@property (nonatomic, strong) AGSGraphicsLayer                      *searchLayer;
@property (nonatomic, strong) AGSGraphicsLayer                      *routeLayer;
@property (nonatomic, strong) AGSGraphicsLayer                      *planningLayer;

@property (nonatomic, strong) Location                              *identifyLocation;
@property (nonatomic, strong) Route                                 *currentRoute;
@property (nonatomic, strong) Route                                 *planningRoute;

@property (nonatomic, strong) AGSGraphic                            *currentDirectionGraphic;
@property (nonatomic, strong) AGSGraphic                            *turnHighlightGraphic;
@property (nonatomic, strong) AGSCompositeSymbol                    *routeSymbol;
@property (nonatomic, strong) AGSCompositeSymbol                    *currentDirectionSymbol;
@property (nonatomic, strong) AGSCompositeSymbol                    *turnHighlightSymbol;

@property (unsafe_unretained, readonly) MapAppSettings                                 *mapAppSettings;

@property (nonatomic, strong) DirectionsSignsView                   *directionsView;
@property (nonatomic, strong) StopsSignsView                        *stopsView;
@property (nonatomic, strong) DrawableResultsTableView              *resultsTableView;

/* Local filtered results is an object to filter local results.  */
@property (nonatomic, strong) UserSearchResults                     *localFilteredResults;

/* Search results by explicitly tapping search  */
@property (nonatomic, strong) UserSearchResults                     *searchResults;

@property (nonatomic, strong) GeocodeService                        *geocodeService;

/*Popups Related Info */
@property (nonatomic, strong) NSMutableArray                        *selectedFeaturePopupInfos;
@property (nonatomic, strong) AGSPopupsContainerViewController      *popupsViewController;
@property (nonatomic, strong) NSMutableArray                        *queryOperations;

@property (nonatomic, assign) BOOL                                  mapLoaded;
@property (nonatomic, copy) NSURL                                   *shareWithMapUrl;
@property (nonatomic, copy) NSString                                *callbackString;

@property (nonatomic, strong) UIButton                              *routingCancelButton;

@property (nonatomic,strong) IBOutlet UISearchBar                   *uiSearchBar;
@property (nonatomic,strong) IBOutlet UIToolbar                      *uiTabBar;

@property (nonatomic, unsafe_unretained) id<LocationCalloutDelegate>   delegate;

-(IBAction)locateMeButtonPressed:(id)sender;
-(IBAction)layersButtonPressed:(id)sender;

-(void)shareInformationWithMap:(MapShareUtility *)msi;

-(void)directToLocationFromCurrentLocation:(Location *)location;
-(void)directToLocationFromTwoPoints:(Location *)startLocation andEnd:(Location*)endLocation;

-(void)showActivityIndicator:(BOOL)show;
-(void) setWebMap:(AGSWebMap*)webmap;

//Temporary!!
-(void)chooseFromOrganizations:(NSArray *)organizations;

@end

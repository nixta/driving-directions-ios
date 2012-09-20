//
//  MapViewController.h
//  Map
//
//  Created by Scott Sirowy on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ArcGIS+App.h"

//included so compiler doesn't complain about protocol definitions
#import "Organization.h"
#import "OrganizationChooserViewController.h"
#import "DrawableContainerDelegate.h"
#import "LocationCalloutView.h"
#import "InputAlertViewDelegate.h"
#import "BasemapsViewController.h"
#import "TabbedResultsViewController.h"
#import "SignsView.h"
#import "Location.h"
#import "Route.h"
#import "RouteSolver.h"

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

@interface MapViewController : UIViewController     <AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSMapViewCalloutDelegate,
                                                    AGSWebMapDelegate, OrganizationDelegate, LocationCalloutDelegate, 
                                                    UIActionSheetDelegate, ChangeBasemapsDelegate, RouteSolverDelegate,
                                                    AGSGPSInfoTemplateDelegate, SignsViewDelegate, MFMailComposeViewControllerDelegate, 
                                                    OrganizationChooserDelegate, DrawableContainerDelegate> 
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
    
    ArcGISAppDelegate                   *_app;
    NSUInteger                          _searchesInProgress;
    NSUInteger                          _currentSearchResultIndex;
    
    BOOL                                _observingGPS;
    BOOL                                _calloutShown;
    BOOL                                _isShowingGPSCallout;
    BOOL                                _changingBasemap;
    BOOL                                _usingCurrentLocation;
}

/*Interface Builder Ux Elements */
@property (nonatomic, retain) IBOutlet AGSMapView                   *mapView;
@property (nonatomic, retain) IBOutlet UIView                       *mapContainerView;
@property (nonatomic, retain) IBOutlet UIButton                     *gpsButton;
@property (nonatomic, retain) IBOutlet UIButton                     *layersButton;

/*Misc Ux Elements */
@property (nonatomic, retain) ExtendableToolbar                     *extendableToolbar;
@property (nonatomic, retain) UISearchBar                           *searchBar;
@property (nonatomic, retain) UIImageView                           *toolbarImageView;
@property (nonatomic, retain) UIBarButtonItem                       *mapListButton;
@property (nonatomic, retain) UIBarButtonItem                       *planningButton;
@property (nonatomic, retain) UIBarButtonItem                       *routeSettingsButton;
@property (nonatomic, retain) UIBarButtonItem                       *clearRouteButton;
@property (nonatomic, retain) UIBarButtonItem                       *routeButton;
@property (nonatomic, retain) UIBarButtonItem                       *routeRefreshButton;
@property (nonatomic, retain) UIBarButtonItem                       *routeActionButton;
@property (nonatomic, retain) UIBarButtonItem                       *routeFinishedButton;
@property (nonatomic, retain) UILabel                               *routeOverviewLabel;
@property (nonatomic, retain) LocationCalloutView                   *locationCallout;
@property (nonatomic, retain) UIActivityIndicatorView               *activityIndicator;
@property (nonatomic, retain) UIView                                *activityIndicatorView;
@property (nonatomic, retain) UIView                                *planningToolsView;


/*Graphics Layers and associated graphics symbols on top of web map */
@property (nonatomic, retain) AGSGraphicsLayer                      *identifyLayer;
@property (nonatomic, retain) AGSGraphicsLayer                      *searchLayer;
@property (nonatomic, retain) AGSGraphicsLayer                      *routeLayer;
@property (nonatomic, retain) AGSGraphicsLayer                      *planningLayer;

@property (nonatomic, retain) Location                              *identifyLocation;
@property (nonatomic, retain) Route                                 *currentRoute;
@property (nonatomic, retain) Route                                 *planningRoute;

@property (nonatomic, retain) AGSGraphic                            *currentDirectionGraphic;
@property (nonatomic, retain) AGSGraphic                            *turnHighlightGraphic;
@property (nonatomic, retain) AGSCompositeSymbol                    *routeSymbol;
@property (nonatomic, retain) AGSCompositeSymbol                    *currentDirectionSymbol;
@property (nonatomic, retain) AGSCompositeSymbol                    *turnHighlightSymbol;

@property (readonly) MapAppSettings                                 *mapAppSettings;

@property (nonatomic, retain) DirectionsSignsView                   *directionsView;
@property (nonatomic, retain) StopsSignsView                        *stopsView;
@property (nonatomic, retain) DrawableResultsTableView              *resultsTableView;

/* Local filtered results is an object to filter local results.  */
@property (nonatomic, retain) UserSearchResults                     *localFilteredResults;

/* Search results by explicitly tapping search  */
@property (nonatomic, retain) UserSearchResults                     *searchResults;

@property (nonatomic, retain) GeocodeService                        *geocodeService;

/*Popups Related Info */
@property (nonatomic, retain) NSMutableArray                        *selectedFeaturePopupInfos;
@property (nonatomic, retain) AGSPopupsContainerViewController      *popupsViewController;
@property (nonatomic, retain) NSMutableArray                        *queryOperations;

@property (nonatomic, assign) BOOL                                  mapLoaded;
@property (nonatomic, copy) NSURL                                   *shareWithMapUrl;
@property (nonatomic, copy) NSString                                *callbackString;

-(IBAction)locateMeButtonPressed:(id)sender;
-(IBAction)layersButtonPressed:(id)sender;

-(void)shareInformationWithMap:(MapShareUtility *)msi;

-(void)directToLocationFromCurrentLocation:(Location *)location; 

-(void)showActivityIndicator:(BOOL)show;

//Temporary!!
-(void)chooseFromOrganizations:(NSArray *)organizations;

@end

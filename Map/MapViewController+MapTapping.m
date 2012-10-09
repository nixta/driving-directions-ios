//
//  MapViewController+MapTapping.m
//  Map
//
//  Created by Scott Sirowy on 9/14/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "MapViewController.h"
#import "MapViewController+MapTapping.h"
#import "MapViewController+PlanningRouting.h"
#import "MapAppSettings.h"
#import "MapSettings.h"

#import "UserSearchResults.h"
#import "Location.h"
#import "CurrentLocation.h"
#import "LocationGraphic.h"
#import "StopsList.h"

#import <ArcGIS/ArcGIS.h>
#import "AGSGeometry+AppAdditions.h"
#import "ArcGISMobileConfig.h"
#import "ArcGISAppDelegate.h"



@implementation MapViewController (MapViewController_MapTapping)

#pragma mark -
#pragma mark Callout Showing/Hiding
-(void)setCalloutShown:(BOOL)shown
{
    _calloutShown = shown;
    self.mapView.callout.hidden = !_calloutShown;
    
    //if we explicitly hide callout, call same method map calls when dismissing callout
    //for additional cleanup
    if(!shown)
    {
        [self mapViewDidDismissCallout:self.mapView];
    }
}

#pragma mark -
#pragma mark Location Creation
-(Location *)defaultLocationForPoint:(AGSPoint *)point
{
    return [[Location alloc] initWithPoint:point 
                                      aName:nil  
                                     anIcon:[UIImage imageNamed:@"AddressPin.png"]
                                 locatorURL:[NSURL URLWithString:_app.config.locatorServiceUrl]];
}


-(void)dropPinForLocation:(Location *)location
{
    //only add it if it's not on the map, otherwise we are just moving it!
    if (self.identifyLocation.graphic.layer == nil) {
        [self.identifyLayer addGraphic:self.identifyLocation.graphic];
    }
    
    [self.identifyLayer dataChanged];
    
    [self showCalloutForLocation:location];
    
}

#pragma mark -
#pragma mark MapViewTouchDelegate
- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics{
    
    if(_isShowingGPSCallout)
    {
        //don't need the hide button for the gps
        self.locationCallout.hideButton.hidden = YES;
        _calloutShown = YES;
        _isShowingGPSCallout = NO;
        return;
    }
    
    //cancel any unneeded operations, etc.
	[self resetForNewTap];
    
    if (!_calloutShown) {
        [self populatePopupInfosUsingGraphics:graphics];
        [self startIdentifyOnMapView:mapView screenPoint:screen mapPoint:mappoint graphics:graphics];
    }
    else {
        [self setCalloutShown:NO];
    }
}

-(void)mapView:(AGSMapView *)mapView didEndTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    [self setCalloutShown:NO];
    [self mapView:mapView didClickAtPoint:screen mapPoint:mappoint graphics:graphics];
}

-(void)showCalloutForLocation:(Location *)location
{        
    LocationCalloutView *locationCallout = [[LocationCalloutView alloc] initWithLocation:location calloutType:_appState];
    locationCallout.delegate = self;
    self.locationCallout = locationCallout;
    
    self.mapView.callout.customView = self.locationCallout;
    self.mapView.callout.margin = CGSizeMake(0, 0);
    self.mapView.callout.highlight = nil;
    self.mapView.callout.cornerRadius = [LocationCalloutView radius];
    
    [self.mapView showCalloutAtPoint:(AGSPoint *)location.geometry forGraphic:location.graphic animated:YES];
    
    [self.locationCallout showAccessoryView:(self.selectedFeaturePopupInfos.count > 0)];
    
    //do not show hide button if result is a search result OR if we are in routing mode and pin is a stop point
    BOOL showHide = !([self.searchResults itemExists:location] || ((_appState == MapAppStateRoute) && [self.planningLayer.graphics containsObject:location.graphic]));
    
    [self.locationCallout showHideButton:showHide];
    
    [self setCalloutShown:YES];
}

-(BOOL)mapView:(AGSMapView *)mapView shouldShowCalloutForGPS:(AGSGPS *)gps
{
    //only show callout if we aren't using a tool or a callout isn't already being shown
    BOOL show = !(_calloutShown) && self.mapView.gps.enabled;
        
    return show; 
}

-(UIView *)customViewForGPS:(AGSGPS *)gps screenPoint:(CGPoint)screen
{
    _isShowingGPSCallout = YES;
    
    Location *gpsLocation = [[Location alloc] initWithPoint:gps.currentPoint 
                                                      aName:NSLocalizedString(@"GPS", nil) 
                                                     anIcon:nil 
                                                 locatorURL:[NSURL URLWithString:_app.config.locatorServiceUrl]];
    
    
    LocationCalloutView *locationCallout = [[LocationCalloutView alloc] initWithLocation:gpsLocation];
    locationCallout.delegate = self;
    self.locationCallout = locationCallout;
    
    self.mapView.callout.customView = self.locationCallout;
    self.mapView.callout.margin = CGSizeMake(0, 0);
    self.mapView.callout.highlight = nil;
    self.mapView.callout.cornerRadius = [LocationCalloutView radius];
    
    
    return self.locationCallout;
}

#pragma mark -
#pragma mark Tapping Methods
-(void)resetForNewTap
{
    //just in case we were waiting for the gps, remove the observer for currentPoint
    //since we have a point.  This may be called twice, but it shouldn't hurt.
   // [self removeGPSObserver];
	
    // cancel any identify going on because we will kick off a new one anyway even if the 
	// user clicks on the same identify graphic.
    [self.queryOperations makeObjectsPerformSelector:@selector(cancel)];
    [self.queryOperations removeAllObjects];
}

//Returns a graphic that has a popupInfo to show. If no graphic is returned, nothing has a popup
-(void)populatePopupInfosUsingGraphics:(NSDictionary *)graphics
{
    //populate array with selected popupInfos
    
    //create the array to hold the popupinfos
    self.selectedFeaturePopupInfos = [NSMutableArray array];
    
    int nCount = [self.mapView.mapLayers count];
    for (int i = nCount - 1; i >= 0; i--) {
        //since the 0th element is the bottommost, start at the last element
        //which would be the topmost layer
        
        AGSLayer *layer = [self.mapView.mapLayers objectAtIndex:i];
        
        //See if there are any features that we've tapped for current layer
        NSString *layerName = layer.name;
        NSArray *layerGraphics = [graphics objectForKey:layerName];
        if ([layerGraphics count] > 0)
        {
            if (![layer isKindOfClass:[AGSFeatureLayer class]])
                continue;
            
            AGSPopupInfo *layerPopup =  [[self mapAppSettings].organization.webmap popupInfoForFeatureLayer:(AGSFeatureLayer *)layer];
            
            //only add stuff if there is a popup for the layer
            if (layerPopup) {
                
                //iterate over all the graphics in layergraphics. Create a copy of the
                //popupInfo, set the feature, and add
                for(AGSGraphic *tappedFeature in layerGraphics)
                {
                    AGSPopupInfo *featurePopupInfo = [layerPopup copy];
                    
                    //for this app, user cannot edit or delete features
                    //featurePopupInfo.allowEdit = NO;
                    //featurePopupInfo.allowDelete = NO;
                    
                    AGSPopup *newPopup = [AGSPopup popupWithGraphic:tappedFeature popupInfo:featurePopupInfo];
                    [self.selectedFeaturePopupInfos addObject:newPopup];
                }
            }
        }
    }
}

//start identify process by dropping a pin on the map. Returns YES if we are already identifying. Returns NO otherwise
-(BOOL)startIdentifyOnMapView:(AGSMapView *)mapView screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{    
    //get identify graphic
    NSArray *identifyArray = [graphics valueForKey:self.identifyLayer.name];
    
    //get search graphics
    NSArray *searchArray = [graphics valueForKey:self.searchLayer.name];
    
    //get planning graphics
    NSArray *planningArray = [graphics valueForKey:self.planningLayer.name];
    

    //if hit test on planning layer, show callout for that layer with priority
    if(planningArray && planningArray.count > 0)
    {
        LocationGraphic *plannedStop = (LocationGraphic *)[planningArray objectAtIndex:0];
        [self showCalloutForLocation:plannedStop.location];
    }
    //Search graphics take second priority
    else if (searchArray && searchArray.count > 0){
        LocationGraphic *search = (LocationGraphic *)[searchArray objectAtIndex:0];
        [self showCalloutForLocation:search.location];
    }
    //lastly look for the identify pin the user may have dropped
    else if (identifyArray && identifyArray.count > 0){
        [self showCalloutForLocation:self.identifyLocation];
    }
    //last case. Drop a new identify pin
    else
    {
        if(_identifyLocation == nil)
            self.identifyLocation = [self defaultLocationForPoint:mappoint];
        
        self.identifyLocation.geometry = mappoint;
        [self.identifyLocation invalidateAddress];
        [self dropPinForLocation:self.identifyLocation];
    }
    
    return _identifyingOnIdentifyLayer;
}

#pragma mark -
#pragma mark Callout Delegate
-(void)mapViewDidDismissCallout:(AGSMapView*)mapView
{
    self.locationCallout.location = nil;
    self.locationCallout = nil;     
}

#pragma mark -
#pragma mark LocationCalloutDelegate
-(void)locationCalloutView:(LocationCalloutView *)lv accessoryButtonTappedForLocation:(Location *)location
{
    //only show popups if popups indeed exist
    if (self.selectedFeaturePopupInfos.count > 0) {
        
        self.popupsViewController = [[AGSPopupsContainerViewController alloc] initWithPopups:self.selectedFeaturePopupInfos];
        
        self.popupsViewController.style = AGSPopupsContainerStyleBlack;
        
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Map", nil) 
                                                                       style:UIBarButtonItemStyleBordered 
                                                                      target:self 
                                                                      action:@selector(popupsContainerDidFinishViewingPopups:)];
        self.popupsViewController.doneButton = doneButton;
        
        //make map page the delegate of the popups
        self.popupsViewController.delegate = self;
        
        self.popupsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:self.popupsViewController animated:YES];
    }
}


-(void)locationCalloutView:(LocationCalloutView *)lv hidePinButtonTappedForLocation:(Location *)location
{
    AGSGraphicsLayer *gl = location.graphic.layer;
    
    //remove stop if location is part of a planned route
    if(gl == self.planningLayer)
    {
        [self.planningRoute removeStop:location];
        
        //remove as a displaced stop too!
        [self.planningRoute.stops.displacedStops removeObject:location];
    }
    
    [gl removeGraphic:location.graphic];
    [gl dataChanged];
    
    [self setCalloutShown:NO];
    
    self.routeButton.enabled = [self.planningRoute canRoute];
    
    BOOL show = (self.planningRoute.stops.numberOfValidStops > 0) && (_appState != MapAppStateRoute);
    [self showStopSigns:show];
}

-(void)locationCalloutView:(LocationCalloutView *)lv actionSheetButtonTappedForLocation:(Location *)location
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:nil 
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:nil];
    
    NSInteger nextIndex = 0;
    
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Share Location", nil)]; nextIndex++;
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = nextIndex;
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = kMapTapActionSheetTag;
    
    [actionSheet showInView:self.view];
}



-(void)locationCalloutView:(LocationCalloutView *)lv directToLocation:(Location *)location
{
    [self directToLocationFromCurrentLocation:location];
}

-(void)locationCalloutView:(LocationCalloutView *)lv wouldLikeToChangeLocation:(Location *)location toType:(LocationType)type
{
    //lazy load planning route.  This *could* be populated by an outside configured source
    if(self.planningRoute == nil)
    {
        Route *pr = [[Route alloc] init];
        pr.stops.delegate = self.stopsView;
        self.planningRoute = pr;
    }
    
    //route isn't editable
    if (!self.planningRoute.isEditable) {
        NSLog(@"Cannot edit route!");
        return;
    }
    
    //same type
    if(location.locationType == type)
        return;
    
    //decided to take stop out of commission
    if (type == LocationTypeNone) {
        [self.planningRoute removeStop:location];
    }
    //either added, or changed the type of the location to start, stop, or transit
    else
    {
        Location *updatedStopLocation = location;
        Location *newLocation = nil;
        
        //if location isn't on planning layer, then we need to add a copy of the location
        //to the planning layer
        if (location.graphic.layer != self.planningLayer) {
            
            newLocation = [location copy];
            newLocation.delegate = self.planningRoute;
            newLocation.locationType = type;
            
            //add to planning layer
            [self.planningLayer addGraphic:newLocation.graphic];
            
            //point to new copy instead of passed in point
            updatedStopLocation = newLocation;
            
            //update the callout's location
            self.locationCallout.location = newLocation;
        }
        else
        {
            updatedStopLocation.locationType = type;
        }

        [self.planningRoute addStop:updatedStopLocation];
    }
    
    [self.planningLayer dataChanged];
    self.routeButton.enabled = [self.planningRoute canRoute];
    [self showStopSigns:(self.planningRoute.stops.numberOfValidStops > 0)];
    [self.stopsView reloadData];
}

#pragma mark -
#pragma mark AGSPopupsContainerDelegate
-(void)popupsContainerDidFinishViewingPopups:(id<AGSPopupsContainer>)popupsContainer
{
    [self dismissModalViewControllerAnimated:YES];
}

-(BOOL)popupsContainer:(id<AGSPopupsContainer>)popupsContainer shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation forViewController:(UIViewController*)vc ofType:(AGSPopupViewType)viewType
{
    return [_app shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}



#pragma mark -
#pragma mark Calling Methods
- (BOOL)canMakePhoneCalls
{
    //We only support 3.2+ OS, so we can see if device can make phone calls
    //by seeing if can handle a telephone url
    UIApplication *app = [UIApplication sharedApplication];
    return ([app canOpenURL:[NSURL URLWithString:@"tel:+44-1234-567890"]]);
}






@end

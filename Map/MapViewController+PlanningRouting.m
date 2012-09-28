//
//  MapViewController+PlanningRouting.m
//  Map
//
//  Created by Scott Sirowy on 12/20/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "MapViewController+PlanningRouting.h"
#import "MapViewController+MapTapping.h"
#import "MapViewController.h"

#import "StopsList.h"
#import "Route.h"
#import "Location.h"
#import "CurrentLocation.h"
#import "DirectionsList.h"

@implementation MapViewController (PlanningRouting)

#pragma mark -
#pragma mark DrawableContainerDataSource
/*
 Datasource for a planned route... Doing this here so MapViewController can update all aspects
 of the planning Ux
 */
-(NSUInteger)numberOfResultTypes
{
    return 1;
}

-(NSUInteger)numberOfResultsInSection:(NSUInteger)section
{
    return self.planningRoute.stops.numberOfStops;
}

-(NSString *)titleOfResultTypeForSection:(NSUInteger)section
{
    return nil;
}

-(id<TableViewDrawable>)resultForRowAtIndexPath:(NSIndexPath *)index
{
    return [self.planningRoute.stops stopAtIndex:index.row];
}

-(BOOL)canMoveResultAtIndexPath:(NSIndexPath *)index
{
    //only allow moving if its not a current location
    Location *l = [self.planningRoute.stops stopAtIndex:index.row];
    return (![l isKindOfClass:[CurrentLocation class]]);
}

-(DrawableList *)listForSection:(NSUInteger)section
{
    return self.planningRoute.stops;
}


#pragma mark -
#pragma mark Street Sign Showing
-(void)showDirectionsSigns:(BOOL)show directions:(DirectionsList *)directions
{
    if(!show)
    {
        [self.directionsView setExpanded:NO animated:YES];
        return;
    }
    
    //showing!
    if(_directionsView == nil)
    {
        DirectionsSignsView *dsv = [[DirectionsSignsView alloc] initWithOffset:self.view.frame.size.height 
                                                             withAdjoiningView:self.mapContainerView 
                                                                withDatasource:directions];
        dsv.delegate = self;
        self.directionsView = dsv;
        
        [self.view addSubview:self.directionsView];
    }
    
    [self.directionsView setExpanded:YES animated:YES];
}

#pragma mark -
#pragma mark Edit Signs Delegate
-(void)stopSignsViewDidCommitEdit:(StopsSignsView *)ssv
{
    [self setCalloutShown:NO];
    
    //updates all signs on the map
    [self.planningLayer removeAllGraphics];
    [self.planningRoute.stops addStopsToLayer:self.planningLayer showCurrentLocation:NO];
    [self.planningLayer dataChanged];
    
    //update surrounding Ux based on route
    self.routeButton.enabled = [self.planningRoute canRoute];
    [self showStopSigns:(self.planningRoute.stops.numberOfValidStops > 0)];
}

-(void)showStopSigns:(BOOL)show
{
    if(!show)
    {
        [self.stopsView setExpanded:NO animated:YES];
        return;
    }
    
    if (_appState != MapAppStatePlanning)
        return;
    
    //show stops view below map in sign form
    if(_stopsView == nil)
    {
        StopsSignsView *ssv = [[StopsSignsView alloc] initWithOffset:self.view.frame.size.height 
                                                   withAdjoiningView:self.mapContainerView 
                                                      withDatasource:self];
        ssv.delegate = self;
        ssv.editDelegate = self;
        self.planningRoute.stops.delegate = ssv;
        
        self.stopsView = ssv;
    }
    if (self.stopsView.superview == nil) {
        [self.view addSubview:self.stopsView];
    }
    
    //actually show signs if we have some stops
    [self.stopsView setExpanded:(self.planningRoute.stops.numberOfValidStops > 0) animated:YES];
}


@end

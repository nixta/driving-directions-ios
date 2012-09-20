//
//  RouteStops.h
//  Map
//
//  Created by Scott Sirowy on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 A route is a set of stops (locations) that a user would like to route
 to and the associated directions between those stops.
 */

#import <Foundation/Foundation.h>
#import "Location.h"
#import "DrawableContainerDelegate.h"

@protocol RouteStopsDelegate;
@class DirectionsList;
@class StopsList;
@class CurrentLocation;

@interface Route : NSObject <LocationDelegate>
{
    id<RouteStopsDelegate>  _delegate;
    DirectionsList          *_directions;
    StopsList               *_stops;
    
    @private
    NSMutableArray          *_stopGraphics;
    
    BOOL                    _editable;
    NSUInteger              _numberOfStopsToPrep;
}

@property (nonatomic, retain, readonly) StopsList       *stops;

@property (nonatomic, assign) id<RouteStopsDelegate>    delegate;
@property (nonatomic, retain) DirectionsList            *directions;
@property (nonatomic, assign) BOOL                      isEditable;


-(void)addStop:(Location *)location;
-(void)removeStop:(Location *)location;
-(void)removeAllStops;

-(void)prepareRoute;
-(BOOL)canRoute;
-(BOOL)routesFromCurrentLocation;

-(NSArray *)graphics;

-(AGSEnvelope *)envelopeInMapView:(AGSMapView *)mapView;

@end


/*
 Delegate method called when route is ready to actually be routed
 */
@protocol RouteStopsDelegate <NSObject>

-(void)routeStops:(Route *)rs didFinishWithStopGraphics:(NSArray *)stops;

@end

/*
 A simple route corresponds to the simple mode in the app...  A simple route
 is a user-defined destination from his current location
 */
@interface SimpleRoute : Route

-(id)initWithDestination:(Location *)destination;

@end

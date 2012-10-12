/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

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
    id<RouteStopsDelegate>  __unsafe_unretained _delegate;
    DirectionsList          *_directions;
    StopsList               *_stops;
    
    @private
    NSMutableArray          *_stopGraphics;
   
    NSUInteger              _numberOfStopsToPrep;
}

@property (nonatomic, strong, readonly) StopsList       *stops;

@property (nonatomic, unsafe_unretained) id<RouteStopsDelegate>    delegate;
@property (nonatomic, strong) DirectionsList            *directions;
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

//
//  RouteSolver.h
//  Map
//
//  Created by Scott Sirowy on 11/23/11.
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
 Responsible for getting route parameters, setting them up correctly,
 and solving a route passed in. Uses delegation to pass back information
 about the solved route
 */

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "Route.h"

@class Route;
@protocol RouteSolverDelegate;


@interface RouteSolver : NSObject <AGSRouteTaskDelegate, RouteStopsDelegate>
{
    NSURL                   *_routingServiceUrl;
    AGSSpatialReference     *_spatialReference;
    id<RouteSolverDelegate> __unsafe_unretained _delegate;
    
    @private
    AGSRouteTask            *_routeTask;
    AGSRouteTaskParameters  *_routeTaskParams;
    Route                   *_routeToSolve;
    
    BOOL                    _routeTaskReady;
    BOOL                    _solvingRoute;
}

@property (nonatomic, strong) NSURL                     *routingServiceUrl;
@property (nonatomic, strong) AGSSpatialReference       *spatialReference;
@property (nonatomic, unsafe_unretained) id<RouteSolverDelegate>   delegate;

-(id)initWithSpatialReference:(AGSSpatialReference *)sr routingServiceUrl:(NSURL *)url;

-(void)solveRoute:(Route *)route;

-(BOOL)isRouteTaskReady;

@end

@protocol RouteSolverDelegate <NSObject>

@optional

-(void)routeSolverNotReadyToRoute:(RouteSolver *)rs;
-(void)routeSolverDidFailToInitialize:(RouteSolver *)rs;
-(void)routeSolver:(RouteSolver *)rs didSolveRoute:(Route *)route;
-(void)routeSolver:(RouteSolver *)rs didFailToSolveRoute:(Route *)route error:(NSError *)error;

@end
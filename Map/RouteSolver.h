//
//  RouteSolver.h
//  Map
//
//  Created by Scott Sirowy on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 Responsible for getting route parameters, setting them up correctly,
 and solving a route passed in. Uses delegation to pass back information
 about the solved route
 */

#import <Foundation/Foundation.h>
#import "ArcGIS+App.h"
#import "Route.h"

@class Route;
@protocol RouteSolverDelegate;


@interface RouteSolver : NSObject <AGSRouteTaskDelegate, RouteStopsDelegate>
{
    NSURL                   *_routingServiceUrl;
    AGSSpatialReference     *_spatialReference;
    id<RouteSolverDelegate> _delegate;
    
    @private
    AGSRouteTask            *_routeTask;
    AGSRouteTaskParameters  *_routeTaskParams;
    Route                   *_routeToSolve;
    
    BOOL                    _routeTaskReady;
    BOOL                    _solvingRoute;
}

@property (nonatomic, retain) NSURL                     *routingServiceUrl;
@property (nonatomic, retain) AGSSpatialReference       *spatialReference;
@property (nonatomic, assign) id<RouteSolverDelegate>   delegate;

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
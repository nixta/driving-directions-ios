/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "RouteSolver.h"
#import "Route.h"
#import "DirectionsList.h"
#import "StopsList.h"
#import "Direction.h"
#import "Location.h"

@interface RouteSolver () 

@property (nonatomic, strong) AGSRouteTask              *routeTask;
@property (nonatomic, strong) AGSRouteTaskParameters    *routeTaskParams;
@property (nonatomic, strong) Route                     *routeToSolve;

@end

@implementation RouteSolver

#pragma mark -
#pragma mark AGSRouteTaskDelegate
- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didRetrieveDefaultRouteTaskParameters:(AGSRouteTaskParameters *)routeParams {
    
    NSLog(@"Ready to route");
    
    _routeTaskReady = YES;
    
    self.routeTaskParams = routeParams;
    self.routeTaskParams.directionsLengthUnits = AGSNAUnitMeters;
    self.routeTaskParams.outputGeometryPrecision = 0.0;
    self.routeTaskParams.findBestSequence = NO;
    self.routeTaskParams.outputGeometryPrecisionUnits = AGSUnitsMeters;
    self.routeTaskParams.outSpatialReference = self.spatialReference;
    self.routeTaskParams.directionsStyleName = @"NA Navigation";
    self.routeTaskParams.returnDirections = YES;
    self.routeTaskParams.returnRouteGraphics = YES;
    self.routeTaskParams.ignoreInvalidLocations = NO;
}

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailToRetrieveDefaultRouteTaskParametersWithError:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(routeSolverDidFailToInitialize:)])
    {
        [self.delegate routeSolverDidFailToInitialize:self];
    }
}

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult {
    
    NSLog(@"Solved route!");
    
    //populate route with directions!!
    AGSRouteResult *routeResult = [routeTaskResult.routeResults objectAtIndex:0];
    
    /*  Print out ALL directions
    for (AGSDirectionGraphic *dg in routeResult.directions.graphics)
    {
        NSLog(@"%@",dg.text);
    }  */
    
    DirectionsList *dl = [[DirectionsList alloc] initWithDirectionSet:routeResult.directions 
                                                                 stops:self.routeToSolve.stops];
    self.routeToSolve.directions = dl;
    
    //give new symbols to stops
    int i = 0;
    for (NSNumber *stopDirectionIndex in dl.stopDirections)
    {
        Direction *stopDirection = [dl directionAtIndex:[stopDirectionIndex intValue]];
        stopDirection.icon = ((Location *)[self.routeToSolve.stops stopAtIndex:i++]).icon;
    }
    
    
    if([self.delegate respondsToSelector:@selector(routeSolver:didSolveRoute:)])
    {
        [self.delegate routeSolver:self didSolveRoute:self.routeToSolve];
    }
    
    self.routeToSolve = nil;
    _solvingRoute = NO;
}

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error {
    
    if([self.delegate respondsToSelector:@selector(routeSolver:didFailToSolveRoute:error:)])
    {
        [self.delegate routeSolver:self didFailToSolveRoute:self.routeToSolve error:error];
    }
    
    self.routeToSolve = nil;
    _solvingRoute = NO;
}


#pragma mark -
#pragma mark Route Stops
-(void)routeStops:(Route *)rs didFinishWithStopGraphics:(NSArray *)stops
{    
    [self.routeTaskParams setStopsWithFeatures:stops];
    [self.routeTask solveWithParameters:self.routeTaskParams];
    
    NSLog(@"Let's solve route...");
}

#pragma mark -
#pragma mark Public Interface

-(id)initWithSpatialReference:(AGSSpatialReference *)sr routingServiceUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        
        _routeTaskReady = NO;
        _solvingRoute = NO;
        
        self.spatialReference = sr;
        self.routingServiceUrl = url;
        
        self.routeTask = [AGSRouteTask routeTaskWithURL:url];
        self.routeTask.delegate = self;
        [self.routeTask performSelector:@selector(retrieveDefaultRouteTaskParameters) 
                             withObject:nil 
                             afterDelay:0.0];
    }
    
    return self;
}

-(void)solveRoute:(Route *)route
{
    if (_solvingRoute || !_routeTaskReady)
    {
        if([self.delegate respondsToSelector:@selector(routeSolverNotReadyToRoute:)])
        {
            [self.delegate routeSolverNotReadyToRoute:self];
        }
    }
    else
    {
        self.routeToSolve = route;
        self.routeToSolve.delegate = self;
        [self.routeToSolve prepareRoute];
        _solvingRoute = YES;   
    }
}

-(BOOL)isRouteTaskReady
{
    return _routeTaskReady;
}

@end
/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

/*
 Insert description here
 */

#import "Route.h"
#import "CurrentLocation.h"
#import "Location.h"
#import "CurrentLocation.h"
#import <ArcGIS/ArcGIS.h>
#import "MapAppDelegate.h"
#import "StopsList.h"

@interface Route () 

-(void)finalizeGraphics;

@property (nonatomic, strong, readwrite) StopsList      *stops;
@property (nonatomic, strong) NSMutableArray            *stopGraphics;

@end

@implementation Route

-(id)init
{
    self = [super init];
    if(self)
    {        
        self.stops = [[StopsList alloc] initWithName:NSLocalizedString(@"Stops", nil) 
                                           withItems:nil];
        self.isEditable = YES;
    }
    
    return self;
}


#pragma mark -
#pragma mark Public Interface
-(void)addStop:(Location *)location
{
    if (!self.isEditable)
        return;
    
    if (![location hasAddress]) {
        [location updateAddress];
    }
    
    [self.stops addStop:location];
}

-(void)removeStop:(Location *)location
{
    if (!self.isEditable)
        return;
    
    [self.stops removeStop:location];
}

-(void)prepareRoute
{
    _numberOfStopsToPrep = 0;
    
    for(int i = 0; i < [self.stops numberOfStops]; i++)
    {
        Location *loc = [self.stops stopAtIndex:i];
                
        //if stop doesn't have a valid point, prep it.
        if(![loc hasValidPoint])
        {
            loc.delegate = self;
            [loc updatePoint];
            _numberOfStopsToPrep++;
        }
    }
    
    //can call unconditionally since there is logic in finalize not to finish until
    //all stops have a point
    [self performSelector:@selector(finalizeGraphics) withObject:nil afterDelay:0.0];
}

//Returns YES if we can route. To be able to route there has to be more than two stops (i.e they've 
//specified a transit) or the destination has been specified
-(BOOL)canRoute
{
    return self.stops.numberOfValidStops > 1;
}

-(BOOL)routesFromCurrentLocation
{
    return [self.stops.startLocation isKindOfClass:[CurrentLocation class]];
}

-(NSArray  *)graphics
{
    return self.stopGraphics;
}

#define kPointTargetScale 10000.0
-(AGSMutableEnvelope *)envelopeInMapView:(AGSMapView *)mapView
{
    AGSMutableEnvelope *_envelope = nil;
    
    for(int i = 0; i < self.stops.numberOfStops; i++)
    {
        AGSMutableEnvelope *ftrEnv = nil;
        Location *result = (Location *)[self.stops stopAtIndex:i];
        
        if ([result isKindOfClass:[CurrentLocation class]])
            continue;
                
        if ([result respondsToSelector:@selector(envelope)]) {
            ftrEnv = [result.envelope mutableCopy];
        }
        
        if (ftrEnv == nil){
            
            if ([result.geometry isKindOfClass:[AGSPolygon class]] || [result.geometry isKindOfClass:[AGSPolyline class]] ) {
                ftrEnv = [result.geometry.envelope mutableCopy];
                [ftrEnv expandByFactor:2];
            }
            else
            {
                double fRatio = kPointTargetScale / mapView.mapScale;
                
                //get a mutable copy of the map current extent, expand by ratio and center at zoomPoint
                ftrEnv = [mapView.visibleArea.envelope mutableCopy];
                [ftrEnv expandByFactor:fRatio];
                [ftrEnv centerAtPoint:result.geometry.envelope.center];
            }
        }
        
        
        if (_envelope == nil){
            _envelope = [AGSMutableEnvelope envelopeWithXmin:ftrEnv.xmin 
                                                            ymin:ftrEnv.ymin 
                                                            xmax:ftrEnv.xmax 
                                                            ymax:ftrEnv.ymax 
                                                spatialReference:mapView.spatialReference];
        }
        else {
            [_envelope unionWithEnvelope:ftrEnv];
        }
        
    }
    
    [_envelope expandByFactor:1.4];
    
    return _envelope;
}


#pragma mark -
#pragma mark Private Methods
-(void)finalizeGraphics
{
    if (_numberOfStopsToPrep > 0)
        return;
    
    NSUInteger numberOfStops = [self.stops numberOfStops];
    
    self.stopGraphics = [NSMutableArray arrayWithCapacity:numberOfStops];
    
    for (int i = 0; i < numberOfStops; i++) {
        Location *stopLocation = [self.stops stopAtIndex:i];
                
        AGSStopGraphic *stop = [AGSStopGraphic graphicWithGeometry:stopLocation.geometry 
                                                               symbol:nil 
                                                           attributes:nil 
                                                 infoTemplateDelegate:nil];
        
        stop.name = [stopLocation searchString];
        [self.stopGraphics addObject:stop];
    }

    
    if ([self.delegate respondsToSelector:@selector(routeStops:didFinishWithStopGraphics:)]) 
    {
        [self.delegate routeStops:self didFinishWithStopGraphics:self.stopGraphics];
    }
}

//Removes all stops. Does not remove their associated graphic from the screen, just
//removes the associated location from the data structure
-(void)removeAllStops
{
    [self.stops clear];
}

#pragma mark -
#pragma mark Location Delegate
-(void)location:(Location *)loc updatedPoint:(AGSPoint *)point
{
    _numberOfStopsToPrep--;
    [self finalizeGraphics];
}

-(void)locationFailedToAttainNewPoint:(Location *)location
{
    NSLog(@"Failed to attain point");
}

@end

@implementation SimpleRoute

-(id)initWithDestination:(Location *)destination
{
    self = [super init];
    if(self)
    {        
        Location *destinationLocation = [destination copy];
        destinationLocation.locationType = LocationTypeDestinationLocation;
        
        [self addStop:destinationLocation];
        
    }
    
    return self;
}

@end

/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "StopsList.h"
#import "Location.h"
#import "CurrentLocation.h"
#import "LocationGraphic.h"
#import "NSNull+Additions.h"
#import "MapAppDelegate.h"
#import "ArcGISMobileConfig.h"

@interface StopsList () 

-(NSUInteger)privateRemoveStop:(Location *)stop;
-(void)privateAddStop:(Location *)stop;
-(NSUInteger)removeStop:(Location *)location preserveType:(BOOL)preserveType;
-(void)replaceStartStopWithStop:(Location *)stop;
-(void)updateAllStops;

@property (nonatomic, strong) CurrentLocation           *currentLocation;

@end

@implementation StopsList

@synthesize displacedStops  = _displacedStops;
@synthesize delegate        = _delegate;
@synthesize currentLocation = _currentLocation;


-(id)initWithName:(NSString *)name withItems:(NSMutableArray *)items
{
    self = [super initWithName:name withItems:items];
    if(self)
    {    
        //if user doesn't pass in any items, populate list with a starting location
        if (!items) {
            [self addItem:self.currentLocation];
        }
        
        //Displaced stops is a set of locations that the user at one point
        //had on his route but has since changed their LocationType to None.
        //Once we route, these should be removed
        self.displacedStops = [NSMutableArray arrayWithCapacity:2];
    }
    
    return self;
}

-(void)privateAddStop:(Location *)stop
{
    if(!stop)
        return;
    
    [self.items addObject:stop];
}

-(void)addStop:(Location *)stop
{
    if (!stop)
        return;
    
    stop.routeDelegate = self;
    
    //remove stop from it's current place in the stop list.
    //This would happen if they changed a stop from e.g a start
    //to a transit.  If it exists, we need to tell delegate that
    //the stop has moved...
    NSUInteger indexOfRemovedStop = [self removeStop:stop preserveType:YES];
    
    //if they are adding a stop back that they displaced, remove it
    //from worklist
    [self.displacedStops removeObject:stop];
    
    BOOL replacedStop = NO;
    
    Location *aLocation;
    switch (stop.locationType) {
        case LocationTypeStartLocation:
            aLocation = self.startLocation;
            
            //The first stop is a default current location... replace with manually
            //entered stop
            if ([aLocation isKindOfClass:[CurrentLocation class]]) {
                [self replaceStartStopWithStop:stop];
                replacedStop = YES;
            }
            //there is a starting location already, move it to become 
            //the first transit stop
            else
            {
                [self insertStop:stop atIndex:0];
                aLocation.locationType = LocationTypeTransitLocation;
            }
            
            [self updateAllStops];
            
            break;
            
        case LocationTypeDestinationLocation:
            aLocation = self.destinationLocation;
            
            //if there is already a destination, make it the last transit
            if (aLocation) {
                aLocation.locationType = LocationTypeTransitLocation;
            }
            
            [self privateAddStop:stop];
            [self updateAllStops];
            
            break;
        case LocationTypeTransitLocation:
            [self addTransitStop:stop];
            [stop updateSymbol];  //so it gets new transit point value
            break;
        case LocationTypeNone:
        default:
            break;
    }
    
    NSUInteger newIndexOfStop = [self.items indexOfObject:stop];
    
    //user replaced a stop... call appropriate delegate
    if (replacedStop) {
        //user replaced a stop with completely new stop
        if (indexOfRemovedStop == NSNotFound) {
            if ([self.delegate respondsToSelector:@selector(stopsList:replacedStop:withStop:atIndex:)]) {
                [self.delegate stopsList:self replacedStop:aLocation withStop:stop atIndex:newIndexOfStop];
            }
        }
        //user replaced a stop with a stop already on the screen
        else
        {
            if([self.delegate respondsToSelector:@selector(stopsList:movedStop:fromIndex:toReplaceStop:atIndex:)])
            {
                [self.delegate stopsList:self movedStop:stop fromIndex:indexOfRemovedStop toReplaceStop:aLocation atIndex:newIndexOfStop];
            }
        }
    }
    //user just added a stop
    else if (indexOfRemovedStop == NSNotFound) {
        if ([self.delegate respondsToSelector:@selector(stopsList:addedStop:atIndex:)]) {
            [self.delegate stopsList:self addedStop:stop atIndex:newIndexOfStop];
        }
    }
    //user moved a stop to a different location
    else
    {
        //moving stop to a different location has the potential that we may have to create a new stop (that's why
        //trueMove is set to NO). E.g if user changes the start location to something else, we need to create a new
        //default starting location
        if ([self.delegate respondsToSelector:@selector(stopsList:movedStop:fromIndex:toIndex:trueMove:)]) {
            [self.delegate stopsList:self movedStop:stop fromIndex:indexOfRemovedStop toIndex:newIndexOfStop trueMove:NO];
        }
    }
}

-(void)insertStop:(Location *)stop atIndex:(NSUInteger)index
{
    if (!stop) {
        return;
    }
    
    [self.items insertObject:stop atIndex:index];
}

-(Location *)stopAtIndex:(NSUInteger)index
{
    if (index >= self.items.count)
        return nil;
    
    return (Location *)[self.items objectAtIndex:index];
}

-(Location *)startLocation
{
    //will always be either a current location, or a manually specified
    //start location... i.e there will always be a start location
    return [self.items objectAtIndex:0];
}

-(Location *)destinationLocation
{
    Location *dest = (Location *)[self.items lastObject];
    if (dest.locationType == LocationTypeDestinationLocation) 
        return dest;
    
    return nil;
}

-(void)replaceStartStopWithStop:(Location *)stop
{
    if(!stop)
        return;
    
    [self.items replaceObjectAtIndex:0 withObject:stop];
}

-(void)addTransitStop:(Location *)transit
{
    if (!transit || (transit.locationType != LocationTypeTransitLocation))
        return;
    
    //if a destination is defined, then insert before it
    if (self.destinationLocation) {
        [self.items insertObject:transit atIndex:self.items.count -1];
    }
    //otherwise add to list
    else
    {
        [self.items addObject:transit];
    }
}

//Total number of stops, including placeholders for start and destination
-(NSUInteger)numberOfStops
{
    return self.items.count;
}

//Filtered list of the total number
-(NSUInteger)numberOfValidStops
{
    NSUInteger numValidStops = self.numberOfStops;
    
    //if the only stop is the starting location, and that starting location is the current
    //location, then there are no valid stops
    if (numValidStops == 1) {
        Location *l = [self stopAtIndex:0];
        if ([l isKindOfClass:[CurrentLocation class]]) {
            numValidStops = 0;
        }
    }
    
    return numValidStops;
}

-(BOOL)hasTransits
{
    return (self.items.count > 2);
}

-(void)removeStop:(Location *)stop
{
    [self removeStop:stop preserveType:NO];
}

-(void)removeStopAtIndex:(NSUInteger)index
{
    Location *l = [self stopAtIndex:index];
    [self removeStop:l];
}

-(NSUInteger)removeStop:(Location *)location preserveType:(BOOL)preserveType
{
    NSUInteger indexOfStop = [self privateRemoveStop:location];
    
    //change type and add to displaced stops
    if (!preserveType)
    {
        location.locationType = LocationTypeNone;
        [self.displacedStops addObject:location];
        [self updateAllStops];
        
        if([self.delegate respondsToSelector:@selector(stopsList:removedStop:atIndex:)] && indexOfStop != NSNotFound)
        {
            [self.delegate stopsList:self removedStop:location atIndex:indexOfStop];
        }
    }
    
    
    return indexOfStop;
}

-(NSUInteger)privateRemoveStop:(Location *)stop
{
    //doesn't exist...
    NSUInteger index = [self indexOfItem:stop];
    if (index == NSNotFound) 
        return index;
    
    //removing the start/destination
    if (stop == self.startLocation) {
        [self.items replaceObjectAtIndex:index withObject:self.currentLocation];
    }
    //removing a transit/destination
    else
    {
        [self.items removeObject:stop];
    }
    
    return index;
}

-(void)moveItemAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2
{
    if (index1 >= self.items.count || index2 >= self.items.count)
        return;
    
    if (index1 == index2)
        return;
    
    Location *stopToMove= [self stopAtIndex:index1];
    Location *stopAtToIndex = [self stopAtIndex:index2];
    
    //if we are moving the destination, we need to make the last transit
    //the destination
    if (stopToMove == self.destinationLocation) {
        Location *lastTransit = [self stopAtIndex:index1-1];
        lastTransit.locationType = LocationTypeDestinationLocation;
    }
    //if the stop we are moving to is the destination, make this stop the new destination
    else if (stopAtToIndex == self.destinationLocation) {
        stopToMove.locationType = LocationTypeDestinationLocation;
    }
    
    [self.items removeObjectAtIndex:index1];
    [self.items insertObject:stopToMove atIndex:index2];
    
    [self updateAllStops];
    
    if ([self.delegate respondsToSelector:@selector(stopsList:movedStop:fromIndex:toIndex:trueMove:)]) {
        
        //actually have a true swap here... No new stops will be created
        [self.delegate stopsList:self movedStop:stopToMove fromIndex:index1 toIndex:index2 trueMove:YES];
    }
    
}

-(void)clear
{
    [super clear];
    
    //add default start
    [self.items addObject:self.currentLocation];
}

//Will add all stop graphics to the layer passed in.  If any stops are the current location,
//user can optionally show currentLocation using boolean paramater
-(void)addStopsToLayer:(AGSGraphicsLayer *)graphicsLayer showCurrentLocation:(BOOL)show
{
    for(int i = 0 ; i < self.items.count; i++)
    {
        Location *result = (Location *)[self itemAtIndex:i];
        
        //if we have a current location and user doesn't want to show it,
        //skip
        if ([result isKindOfClass:[CurrentLocation class]] && !show)
            continue;
            
        [graphicsLayer addGraphic:result.graphic];
    }
    
    //add all displaced stops to layer too
    for(Location *l in self.displacedStops)
    {
        [graphicsLayer addGraphic:l.graphic];
    }
}

//After we move stops around, go through and update all stops types and their
//associated symbols
-(void)updateAllStops
{
    Location *start = [self startLocation];
    start.locationType = LocationTypeStartLocation;
    
    Location *destination = [self destinationLocation];
    destination.locationType = LocationTypeDestinationLocation;
    
    //if there is a destination, iterate up to the destination... Otherwise, iterate
    //to end of list
    NSUInteger numberOfStops = destination ? (self.numberOfStops -1) : self.numberOfStops;
    
    for(int i = 1; i < numberOfStops; i++)
    {
        Location *l = [self stopAtIndex:i];
        l.locationType = LocationTypeTransitLocation;
    }
}

//Displaced stops are all locations that were at one point part of the route... The misfits
//of the group you might say
-(void)removeDisplacedStops
{
    [self.displacedStops removeAllObjects];
}

#pragma mark -
#pragma mark Lazy Loads
#pragma mark -
#pragma mark Lazy Loads
-(CurrentLocation *)currentLocation
{
    if(_currentLocation == nil)
    {
        //get a current location as default stop
        MapAppDelegate *app = (MapAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSURL *locatorUrl = [NSURL URLWithString:app.config.locatorServiceUrl];
        
        self.currentLocation = [CurrentLocation aCurrentLocationWithLocatorURL:locatorUrl];
        self.currentLocation.locationType = LocationTypeStartLocation;
    }
    
    return _currentLocation;
}

#pragma mark -
#pragma mark LocationRouteDelegate

-(NSUInteger)transitIndexForLocation:(Location *)location
{
    return [self indexOfItem:location];
}

@end

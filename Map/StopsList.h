//
//  StopsList.h
//  Map
//
//  Created by Scott Sirowy on 12/19/11.
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
 A concrete implementation of 'DrawableList' that maintains a set 
 of stops (locations). 
 
 Maintains where a new location should be added based on its 
 type (start, transit, destination)
 */

#import "DrawableList.h"
#import "Location.h"

@class Location;
@class CurrentLocation;
@protocol StopsDelegate;

@interface StopsList : DrawableList <LocationRouteDelegate>
{
    NSMutableArray      *_displacedStops;
    CurrentLocation     *_currentLocation;
    
    id<StopsDelegate>   __unsafe_unretained _delegate;
}

@property (nonatomic, strong) NSMutableArray    *displacedStops;
@property (nonatomic, unsafe_unretained) id<StopsDelegate> delegate;

-(void)addStop:(Location *)location;
-(void)insertStop:(Location *)stop atIndex:(NSUInteger)index;
-(void)addTransitStop:(Location *)transit;

-(Location *)stopAtIndex:(NSUInteger)index;
-(Location *)startLocation;
-(Location *)destinationLocation;

-(void)removeStop:(Location *)stop;
-(void)removeStopAtIndex:(NSUInteger)index;
-(void)removeDisplacedStops;

//Total number of stops, including placeholders for start and destination
-(NSUInteger)numberOfStops;

//Filtered list of the total number
-(NSUInteger)numberOfValidStops;

-(BOOL)hasTransits;

-(void)addStopsToLayer:(AGSGraphicsLayer *)graphicsLayer showCurrentLocation:(BOOL)show;

@end

/*
 Used to alert different views that the number of stops, the ordering of stops, etc.
 has changed
 */
@protocol StopsDelegate <NSObject>

@optional

//Adding a new stop into the list at defined index
-(void)stopsList:(StopsList *)sl addedStop:(Location *)location atIndex:(NSUInteger)index;

//Removing a stop at defined index
-(void)stopsList:(StopsList *)sl removedStop:(Location *)location atIndex:(NSUInteger)index;

//Moving a stop from one index to another. If true move is not defined, then there is potential that moving 
//a stop will also create a new stop
-(void)stopsList:(StopsList *)sl movedStop:(Location *)location fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex trueMove:(BOOL)trueMove;

//Replacing a stop with a stop already in the list.  The net effect is that the list will have one less stop
-(void)stopsList:(StopsList *)sl movedStop:(Location *)location fromIndex:(NSUInteger)fromIndex toReplaceStop:(Location *)loc atIndex:(NSUInteger)index;

//Replace a stop with another stop *not* already in list. The net effect is the list have same number of stops
-(void)stopsList:(StopsList *)sl replacedStop:(Location *)stop1 withStop:(Location *)stop2 atIndex:(NSUInteger)index;

@end

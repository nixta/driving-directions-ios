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
 Wrapper for a list of directions. Builds a reorganized data structure
 for the set of AGSDirections that are passed in. Derived from the drawable
 list data structure
 */

#import <Foundation/Foundation.h>
#import "DrawableList.h"

@class Direction;
@class AGSDirectionSet;
@class StopsList;

@interface DirectionsList : DrawableList
{
    Direction       *_currentDirection;
    AGSGeometry     *_mergedGeometry;
    NSMutableArray  *_stopDirections;
    
    StopsList       *_stopsList;
}

/*Direction user is currently on */
@property (nonatomic, strong, readonly) Direction       *currentDirection;

/*Geometry of the entire route */
@property (nonatomic, strong, readonly) AGSGeometry     *mergedGeometry;

/*Directions that correspond to a stop on the route. These can be
 start, stops, and transit points. This is an array of numbers indicating
 where stop n indexes into the actual directions
 */
@property (nonatomic, strong, readonly) NSMutableArray  *stopDirections;
 
-(id)initWithDirectionSet:(AGSDirectionSet *)directionSet stops:(StopsList *)stops;

-(Direction *)directionAtIndex:(NSUInteger)index;

-(NSString *)directionsString;

@end

//
//  DirectionsList.h
//  Map
//
//  Created by Scott Sirowy on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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

//
//  OverviewDirection.h
//  Map
//
//  Created by Scott Sirowy on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ArcGIS+App.h"
#import "Direction.h"

/*
 Specical type of direction that shows the whole route on
 screen
 */

@class StopsList;

@interface OverviewDirection : Direction
{
    StopsList *_stops;
}

@property (nonatomic, retain) StopsList *stops;

-(id)initWithDirectionSet:(AGSDirectionSet *)directionSet stops:(StopsList *)stops;

@end

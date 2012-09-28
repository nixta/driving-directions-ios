//
//  OverviewDirection.h
//  Map
//
//  Created by Scott Sirowy on 10/20/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <ArcGIS/ArcGIS.h>
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

@property (nonatomic, strong) StopsList *stops;

-(id)initWithDirectionSet:(AGSDirectionSet *)directionSet stops:(StopsList *)stops;

@end

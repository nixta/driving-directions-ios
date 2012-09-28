//
//  DirectionsList.m
//  Map
//
//  Created by Scott Sirowy on 9/23/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "DirectionsList.h"
#import "Direction.h"
#import "OverviewDirection.h"
#import <ArcGIS/ArcGIS.h>
#import "NSString+NSString_Additions.h"
#import "StopsList.h"

@interface DirectionsList () 

@property (nonatomic, strong, readwrite) Direction      *currentDirection;
@property (nonatomic, strong, readwrite) AGSGeometry    *mergedGeometry;
@property (nonatomic, strong, readwrite) NSMutableArray *stopDirections;

@property (nonatomic, strong) StopsList                 *stopsList;

@end

@implementation DirectionsList

@synthesize currentDirection    = _currentDirection;
@synthesize mergedGeometry      = _mergedGeometry;
@synthesize stopDirections      = _stopDirections;

@synthesize stopsList           = _stopsList;


- (id)init
{
    return [self initWithDirectionSet:nil stops:nil];
}

-(id)initWithDirectionSet:(AGSDirectionSet *)directionSet stops:(StopsList *)stops
{
    self = [super initWithName:NSLocalizedString(@"Directions", nil) 
                     withItems:nil];
    
    if(self)
    {
        self.mergedGeometry = directionSet.mergedGeometry;
        
        self.stopDirections = [NSMutableArray arrayWithCapacity:3];
        
        self.stopsList = stops;
        
        //Create an "Overview" direction
        OverviewDirection *overviewDirection = [[OverviewDirection alloc] initWithDirectionSet:directionSet stops:self.stopsList];        
        overviewDirection.geometry = directionSet.mergedGeometry;
        
        [overviewDirection retrieveMapImageOfSize:CGSizeMake(640, 480)];
        [self addItem:overviewDirection];
        
        //Create the first depart direction here. If there are subsequent departs, we are going
        //to strip them out of the list of directions since they are redundant with the Arrive direction
        AGSDirectionGraphic *departGraphic = [directionSet.graphics objectAtIndex:0];
        Direction *departDirection = [[Direction alloc] initWithDirectionGraphic:departGraphic];
        [self addItem:departDirection];
        
        //add depart stop into stopDirections. It's actually indexed as 1 since OverviewDirection is direction 0
        [self.stopDirections addObject:[NSNumber numberWithInt:1]];
        
        
        //Index of current stop in list. Start at 1 because stop 0 is the starting point
        NSUInteger currentStop = 1;   
        
        //Start at the second direction (indexed at 1). If we find a depart direction, remove it from
        //the list we are creating.
        for (int i = 1; i < directionSet.graphics.count; i++) {
            AGSDirectionGraphic *currentGraphic = [directionSet.graphics objectAtIndex:i];
            
            if (currentGraphic.maneuverType != AGSNADirectionsManeuverDepart)
            {
                Direction *newDirection = [[Direction alloc] initWithDirectionGraphic:currentGraphic];
                [self addItem:newDirection];
                
                if(currentGraphic.maneuverType == AGSNADirectionsManeuverStop)
                {
                    //add stop... Indexed by +1 because of overview directions
                    [self.stopDirections addObject:[NSNumber numberWithInt:[self indexOfItem:newDirection]]];
                    
                    newDirection.abbreviatedName = [[self.stopsList stopAtIndex:currentStop++] searchString];
                }
                
            }
        }
        
        _currentDirection = 0;
    }
    return self;
}


-(Direction *)currentDirection
{
    if (self.currentIndex >= [self numberOfItems])
        return nil;
    
    return (Direction *)[self itemAtIndex:self.currentIndex];
} 

-(Direction *)directionAtIndex:(NSUInteger)index
{
    if (index >= [self numberOfItems])
        return nil;
    
    return (Direction *)[self itemAtIndex:index];
}

-(NSString *)directionsString
{
    NSString *directionString = @"";
    
    for(int i = 0; i < [self numberOfItems]; i++)
    {
        Direction *dir = [self directionAtIndex:i];
        
        if ([dir isKindOfClass:[OverviewDirection class]]) {
            directionString = [NSString stringWithFormat:@"<p>Overview: %@ <br\\> <ol>", dir.name];
        }
        else
        {
            directionString = [directionString stringByAppendingFormat:@"<li>%@</li>", dir.name];
        }
    }
    
    directionString = [directionString stringByAppendingString:@"</ol>"];
    return directionString; 
}

@end

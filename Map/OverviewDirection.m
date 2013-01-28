/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "OverviewDirection.h"
#import "Location.h"
#import "LocationGraphic.h"
#import "StopsList.h"

@interface Direction () 

@property (nonatomic, retain) AGSGraphicsLayer *graphicsLayer;

@end

@implementation OverviewDirection


-(id)initWithDirectionSet:(AGSDirectionSet *)directionSet stops:(StopsList *)stops
{
    self = [super initWithDirectionGraphic:nil];
    if(self)
    {
        self.stops = stops;
        self.icon = [UIImage imageNamed:@"speedometer.png"];
        
        self.distanceString = [Direction stringForDistance:directionSet.totalLength];
        self.etaString = [Direction stringForMinutes:directionSet.totalDriveTime];
        self.abbreviatedName = NSLocalizedString(@"Route Overview", nil);
    }
    
    return self;
}

-(void)retrieveMapImageOfSize:(CGSize)size
{
    for (int i = 0; i < self.stops.numberOfStops; i++) {
        Location *l = [self.stops stopAtIndex:i];

        AGSGraphic *graphicCopy = [l.graphic copy];
        [self.graphicsLayer addGraphic:graphicCopy];
    }    
    [super retrieveMapImageOfSize:size];    
}

-(NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", self.distanceString, self.etaString];
}

@end

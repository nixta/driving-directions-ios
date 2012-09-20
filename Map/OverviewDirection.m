//
//  OverviewDirection.m
//  Map
//
//  Created by Scott Sirowy on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OverviewDirection.h"
#import "Location.h"
#import "LocationGraphic.h"
#import "StopsList.h"

@interface Direction () 

@property (nonatomic, retain) AGSGraphicsLayer *graphicsLayer;

@end

@implementation OverviewDirection

@synthesize stops = _stops;

-(void)dealloc
{
    self.stops = nil;
    
    [super dealloc];
}

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
        [graphicCopy release];
    }    
    [super retrieveMapImageOfSize:size];    
}

-(NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", self.distanceString, self.etaString];
}

@end

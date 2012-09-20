//
//  LocationGraphic.m
//  Map
//
//  Created by Scott Sirowy on 10/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationGraphic.h"
#import "Location.h"

@implementation LocationGraphic

@synthesize location = _location;

-(id)initWithGeometry:(AGSGeometry *)geometry symbol:(AGSSymbol *)symbol attributes:(NSMutableDictionary *)attributes infoTemplateDelegate:(id<AGSInfoTemplateDelegate>)infoTemplateDelegate
{
    return [super initWithGeometry:geometry symbol:symbol attributes:attributes infoTemplateDelegate:infoTemplateDelegate];
}

-(void)clearLocation
{
    self.location = nil;
}

@end

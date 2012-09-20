//
//  LocationGraphic.h
//  Map
//
//  Created by Scott Sirowy on 10/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ArcGIS+App.h"

@class Location;

/*
 Subclass of graphic that includes the graphic's location.
 */

@interface LocationGraphic : AGSGraphic
{
    Location *_location;
}

@property (nonatomic, assign) Location *location;

-(void)clearLocation;

@end

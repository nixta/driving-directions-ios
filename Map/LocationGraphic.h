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
    Location *__unsafe_unretained _location;
}

@property (nonatomic, unsafe_unretained) Location *location;

-(void)clearLocation;

@end

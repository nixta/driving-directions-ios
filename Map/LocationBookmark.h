//
//  LocationBookmark.h
//  Map
//
//  Created by Scott Sirowy on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Location.h"
#import "LocationBookmark.h"
#import "ArcGIS+App.h"
#import "NamedGeometry.h"

@interface LocationBookmark : Location <AGSCoding>
{
    AGSEnvelope *_envelope;
}

@property (nonatomic, retain) AGSEnvelope *envelope;

-(id)initWithLocation:(Location *)location extent:(AGSEnvelope *)extent;

@end

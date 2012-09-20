//
//  CurrentLocation.h
//  Map
//
//  Created by Scott Sirowy on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Location.h"
#import <CoreLocation/CoreLocation.h>

/*
 A Current Location object subclasses Location but always returns the
 the current GPS point. The user should manually update the point
 when they want to access the AGSPoint representation of the location
 */

@interface CurrentLocation : Location <CLLocationManagerDelegate>
{
    CLLocationManager   *_locationManager;
    BOOL                _updatingPoint;
}

-(id)initWithIcon:(UIImage *)icon locatorURL:(NSURL *)url;

+(CurrentLocation *)aCurrentLocationWithLocatorURL:(NSURL *)url;

@end


/*
 Only for use in simulator... Of no use on device.
 */
@interface SimulatedCurrentLocation : CurrentLocation

@end

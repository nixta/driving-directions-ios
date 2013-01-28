/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

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

/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <Foundation/Foundation.h>

/*
 App has several different modes
 */
typedef enum {
    MapAppStateSimple = 0,     //Simple   State:  User can search, and get routed to a location via their current location
    MapAppStateRoute,          //In routing mode... likely showing a route on the screen
} MapAppState;

typedef enum {
    MapSearchStateDefault =  0,   //Showing map with nothing
    MapSearchStateMap,            //showing results on map
    MapSearchStateList            //Results in list
} MapSearchState;

//global defines for Notifications
#define kLocationUpdatedAddress @"LocationUpdatedAddress"
#define kLocationFailedToUpdateAddress @"LocationFailedToUpdateAddress"

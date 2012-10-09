//
//  MapStates.h
//  Map
//
//  Created by Al Pascual on 9/28/12.
//
//

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

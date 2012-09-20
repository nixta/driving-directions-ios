//
//  ArcGIS+App.h
//  Map
//
//  Created by Scott Sirowy on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 Enter description here
 */

#import <Foundation/Foundation.h>
//#import <ArcGIS/ArcGIS.h>
#import <ArcGIS/ArcGIS.h>
#import "ArcGISAppDelegate.h"
#import "AppSettings.h"
#import "OnlineApplication.h"
#import "ArcGISMobileConfig.h"

//private Web Map API
//#import "AGSWebMapBaseMapInfo.h"
//#import "AGSWebMapLayerInfo.h"
//#import "AGSWebMapSubLayerInfo.h"
//#import "AGSWebMapFeatureCollection.h"
//#import "AGSWebMapInfo.h"

//global defines for Notifications
#define kLocationUpdatedAddress @"LocationUpdatedAddress"
#define kLocationFailedToUpdateAddress @"LocationFailedToUpdateAddress"

/*
 App has several different modes 
 */
typedef enum {
    MapAppStateSimple = 0,     //Simple   State:  User can search, and get routed to a location via their current location
    MapAppStatePlanning,       //Planning State:  User can search, but also create/edit custom routes with multiple stops, optimizatinons, etc
    MapAppStateRoute,          //In routing mode... likely showing a route on the screen
} MapAppState;

typedef enum {
    MapSearchStateDefault =  0,   //Showing map with nothing
    MapSearchStateMap,            //showing results on map
    MapSearchStateList            //Results in list
} MapSearchState;

@interface AGSCredential (AGSAppInternal)

+(NSString *)ags_sanitizeString:(NSString *)stringToSanitize;

@end

//private API properties/methods/etc
#pragma mark -
@interface AGSWebMap (AGSAppInternal)

@property (nonatomic,retain) NSArray *operationalLayers;
@property (nonatomic, retain, readwrite) NSArray *bookmarks;
@property (nonatomic, retain, readwrite) NSArray *queries;
@property (nonatomic, retain) AGSWebMapBaseMap *baseMap;
@property (nonatomic, copy, readwrite) NSURL *URL;

@end

#pragma mark -
@interface AGSWebMapLayerInfo (AGSAppInternal)

@property (nonatomic, readwrite) BOOL visibility;
@property (nonatomic, retain, readwrite) NSString *title;
@property (nonatomic, retain, readwrite) NSURL *URL;
@property (nonatomic, retain, readwrite) NSString *layerType;
@property (nonatomic, readwrite) float opacity;

@end





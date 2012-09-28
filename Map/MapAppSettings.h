//
//  MapAppSettings.h
//  Map
//
//  Created by Scott Sirowy on 9/13/11.
/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */
#import "AppSettings.h"
#import <ArcGIS/ArcGIS.h>
#import "DrawableContainerDelegate.h"

@class AGSWebMapPlus;
@class Location;
@class BasemapInfo;
@class Bookmarks;
@class DrawableList;
@class Route;
@class RecentRoutes;
@class Search;
@class RecentSearches;
@class ContactsList;
@class Legend;
@class Organization;
@class RouteSolverSettings;

/*
 Settings specific to the Map Navigator app
 */

@interface MapAppSettings : AppSettings <AGSCoding, DrawableContainerDataSource>
{
    DrawableList        *_recentSearches;
    Bookmarks           *_bookmarks;
    ContactsList        *_contacts;
    
    BasemapInfo         *_customBasemap;
    AGSEnvelope         *_savedExtent;
    Legend              *_legend;
    
    RouteSolverSettings *_routeSolverSettings;
    
    Organization        *_organization;
}

@property (nonatomic, strong) DrawableList          *recentSearches;
@property (nonatomic, strong) Bookmarks             *bookmarks;
@property (nonatomic, strong) ContactsList          *contacts;
@property (nonatomic, strong) BasemapInfo           *customBasemap;
@property (nonatomic, strong) AGSEnvelope           *savedExtent;
@property (nonatomic, strong) Legend                *legend;
@property (nonatomic, strong) RouteSolverSettings   *routeSolverSettings;
@property (nonatomic, strong) Organization          *organization;

-(void)addBookmark:(Location *)bookmark withCustomName:(NSString *)name withExtent:(AGSEnvelope *)envelope;
-(void)addRecentSearch:(Search *)recentSearch onlyUniqueEntries:(BOOL)unique;
-(void)clearRecentSearches;

@end

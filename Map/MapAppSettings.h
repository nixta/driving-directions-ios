//
//  MapAppSettings.h
//  Map
//
//  Created by Scott Sirowy on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppSettings.h"
#import "ArcGIS+App.h"
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

@property (nonatomic, retain) DrawableList          *recentSearches;
@property (nonatomic, retain) Bookmarks             *bookmarks;
@property (nonatomic, retain) ContactsList          *contacts;
@property (nonatomic, retain) BasemapInfo           *customBasemap;
@property (nonatomic, retain) AGSEnvelope           *savedExtent;
@property (nonatomic, retain) Legend                *legend;
@property (nonatomic, retain) RouteSolverSettings   *routeSolverSettings;
@property (nonatomic, retain) Organization          *organization;

-(void)addBookmark:(Location *)bookmark withCustomName:(NSString *)name withExtent:(AGSEnvelope *)envelope;
-(void)addRecentSearch:(Search *)recentSearch onlyUniqueEntries:(BOOL)unique;
-(void)clearRecentSearches;

@end

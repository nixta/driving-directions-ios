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

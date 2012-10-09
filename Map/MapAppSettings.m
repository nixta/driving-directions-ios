//
//  MapAppSettings.m
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

#import "MapAppSettings.h"
#import "MapSettings.h"
#import "NSDictionary+Additions.h"
#import "Location.h"
#import "Route.h"
#import "Search.h"
#import "RecentSearches.h"
#import "Organization.h"
#import "RouteSolverSettings.h"

@implementation MapAppSettings

@synthesize recentSearches = _recentSearches;
@synthesize bookmarks = _bookmarks;
@synthesize contacts = _contacts;
@synthesize customBasemap = _customBasemap;
@synthesize savedExtent = _savedExtent;
@synthesize legend = _legend;
@synthesize routeSolverSettings = _routeSolverSettings;
@synthesize organization = _organization;

- (id)init
{
    self = [super init];
    if (self) {
        self.recentSearches = [[RecentSearches alloc] initWithName:NSLocalizedString(@"Recent Searches", nil) 
                                                        withItems:nil];
        
        self.routeSolverSettings = [[RouteSolverSettings alloc] init];
        
        self.customBasemap = nil;
        
        self.savedExtent = nil;
    }
    
    return self;
}

#pragma mark -
#pragma mark AGSCoding
- (void)decodeWithJSON:(NSDictionary *)json 
{
    [super decodeWithJSON:json];
    
    self.recentSearches = [[RecentSearches alloc] initWithJSON:[json objectForKey:@"recentSearches"]];
    
    NSDictionary *solverJSON = [json objectForKey:@"routeSolverSettings"];
    if (solverJSON) {
        self.routeSolverSettings = [[RouteSolverSettings alloc] initWithJSON:solverJSON];
    }
    else
    {
        self.routeSolverSettings = [[RouteSolverSettings alloc] init];
    }

}

- (id)initWithJSON:(NSDictionary *)json {
    self = [self init];
    
    if (self) {
        [self decodeWithJSON:json];
    }
    return self;
}

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *json = (NSMutableDictionary *)[super encodeToJSON];
    
    [json setObject:[self.recentSearches encodeToJSON] forKey:@"recentSearches"];

    /*if (self.currentMap) {
        [json setObject:[self.currentMap encodeToJSON] forKey:@"currentMap"];
    }  */
    
    if (self.savedExtent) {
        [json setObject:[self.savedExtent encodeToJSON] forKey:@"savedExtent"];
    }
    
    
	return json;
}




 
-(void)addRecentSearch:(Search *)recentSearch onlyUniqueEntries:(BOOL)unique;
{
    if(!recentSearch)
        return;
    
    //if we're not constraining to unique entries, go ahead an immediately add
    if(!unique)
        [self.recentSearches addItem:recentSearch];
    
    else
    {
        //else check descriptions to make sure it doesn't exist
        for(int i  = 0; i < [self.recentSearches numberOfItems]; i++)
        {
            Search* search = (Search *)[self.recentSearches itemAtIndex:i];
            if ([search.name isEqualToString:recentSearch.name]) {
                return;
            }
        }
        
        //not in list, go ahead and add
        [self.recentSearches addItem:recentSearch];
    }
}


-(void)clearRecentSearches
{
    [self.recentSearches clear];
}

#pragma mark -
#pragma mark DrawableContainerDatasource
-(NSUInteger)numberOfResultTypes
{    
    return [self.recentSearches numberOfItems] > 0;
}
-(NSUInteger)numberOfResultsInSection:(NSUInteger)section
{
    return [self.recentSearches numberOfItems];
}

-(NSString *)titleOfResultTypeForSection:(NSUInteger)section
{
    return self.recentSearches.name;
}

-(id<TableViewDrawable>)resultForRowAtIndexPath:(NSIndexPath *)index
{
    return [self.recentSearches itemAtIndex:index.row];
}

-(BOOL)canMoveResultAtIndexPath:(NSIndexPath *)index
{
    return NO;
}

-(DrawableList *)listForSection:(NSUInteger)section
{
    return self.recentSearches;
}

-(void)addBookmark:(Location *)bookmark withCustomName:(NSString *)name withExtent:(AGSEnvelope *)envelope
{
    return;
}

@end

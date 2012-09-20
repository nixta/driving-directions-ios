//
//  MapSettings.m
//  ArcGISMobile
//
//  Created by ryan3374 on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapSettings.h"
#import "BaseMapSettings.h"
#import "ArcGIS.h"
#import "ArcGISOnlineConnection.h"
#import "NSString+html.h"
#import "NSDictionary+Additions.h"
#import "ContentItem.h"

NSInteger const MAX_SAVED_SEARCHES = 15;

@implementation MapSettings

@synthesize savedExtent = _savedExtent;
@synthesize taskOrder = _taskOrder;
@synthesize recentSearches = _recentSearches;
@synthesize customBaseMap = _customBaseMap;
@synthesize isSwitchBaseMapsEnabled = _switchBaseMapsEnabled;
@synthesize legend = _legend;

-(id)init{
	if (self = [super init]){
		self.taskOrder = [[[NSMutableArray alloc]init]autorelease];
		self.recentSearches = [[[NSMutableArray alloc]init]autorelease];
		
		//by default, switch basesmap enabled
		self.isSwitchBaseMapsEnabled = YES;
	}
	return self;
}

-(id) initWithUrl:(NSString *)sUrl
{
    if (self = [super initWithUrl:sUrl])
    {
        self.taskOrder = [[[NSMutableArray alloc]init]autorelease];
        self.recentSearches = [[[NSMutableArray alloc]init]autorelease];
		
        //by default, switch basesmap enabled
        self.isSwitchBaseMapsEnabled = YES;
    }
    
    return self;
}

-(id)initWithName:(NSString *)n
			  url: (NSString *)u
	  contentItem: (ContentItem *)c
{
    if (self = [super initWithName:n url:u contentItem:c])
    {
        self.taskOrder = [[[NSMutableArray alloc]init]autorelease];
        self.recentSearches = [[[NSMutableArray alloc]init]autorelease];
		
        //by default, switch basesmap enabled
        self.isSwitchBaseMapsEnabled = YES;
    }
    return self;
}

#pragma mark -
#pragma mark AGSCoding

- (void)decodeWithJSON:(NSDictionary *)json {
	
	[super decodeWithJSON:json];

	self.taskOrder = [NSDictionary safeGetObjectFromDictionary:json withKey:@"taskOrder"];	
	if (!self.taskOrder)
		self.taskOrder = [[[NSMutableArray alloc]init]autorelease];

	self.recentSearches = [NSDictionary safeGetObjectFromDictionary:json withKey:@"recentSearches"];
	if (!self.recentSearches)
		self.recentSearches = [[[NSMutableArray alloc]init]autorelease];
	
	NSDictionary *savedExtentJson = [NSDictionary safeGetObjectFromDictionary:json withKey:@"savedExtent"];
	if (savedExtentJson)
		self.savedExtent = [[[AGSEnvelope alloc]initWithJSON:savedExtentJson]autorelease];
	
	
	id aCustomBaseMap = [NSDictionary safeGetObjectFromDictionary:json withKey:@"customBaseMap"];
     if (aCustomBaseMap)
    {
        self.customBaseMap = [[[BaseMapSettings alloc] initWithJSON:aCustomBaseMap] autorelease];
    }
	
	self.isSwitchBaseMapsEnabled = [[json valueForKey:@"isSwitchBaseMapsEnabled"] boolValue];
}

- (id)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        [self decodeWithJSON:json];
    }
    return self;
}

+(MapSettings *) mapSettingsFromWebMapJSON:(NSDictionary *)json withExtent:(AGSEnvelope *)extent
{
    MapSettings *ms= [[MapSettings alloc]init];
	ms.title = NSLocalizedString(@"Default Map", nil);
    ms.savedExtent = extent;
	ms.url = @"defaultMap";
    ms.mapIconName = @"WorldTerrainMapThumbnail.png";
	ms.contentItem = [[[ContentItem alloc]init]autorelease];
    ms.contentItem.itemId = @"c61ad8ab017d49e1a82f580ee1298931";
    ms.contentItem.title = ms.title;
    ms.contentItem.owner = @"";
    ms.contentItem.access = @"Public";
    ms.contentItem.thumbnail = @"thumbnail/Terrain.png";
    ms.contentItem.snippet = @"";
    ms.contentItem.uploaded = 0;
    ms.contentItem.tags = [NSMutableArray array];
    ms.contentItem.avgRating = 5.0;
    ms.contentItem.numRatings = 1;
    ms.contentItem.numViews = 1;
	
    ms.isSwitchBaseMapsEnabled = NO;
    
    AGSWebMap *webMap = [[AGSWebMap alloc]initWithJSON:json];
    ms.webmap = webMap;
    [webMap release];
	
	[ms autorelease];
	return ms;
}

- (NSDictionary *)encodeToJSON;
{
	//NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:1];
	NSDictionary *superJson = [super encodeToJSON];
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:superJson];
	
	[json setObject:self.title forKey:@"title"];
	[json setObject:self.url forKey:@"url"];
	[NSDictionary safeSetObjectInDictionary:json object:[self.contentItem encodeToJSON] withKey:@"contentItem"];
	[json setObject:self.taskOrder forKey:@"taskOrder"];
	[json setObject:self.recentSearches forKey:@"recentSearches"];
	[NSDictionary safeSetObjectInDictionary:json object:self.mapIconName withKey:@"mapIconName"];
	
	[NSDictionary safeSetObjectInDictionary:json object:[self.customBaseMap encodeToJSON] withKey:@"customBaseMap"];
	[json setValue:[NSNumber numberWithBool:self.isSwitchBaseMapsEnabled] forKey:@"isSwitchBaseMapsEnabled"];
	
	[NSDictionary safeSetObjectInDictionary:json object:[self.savedExtent encodeToJSON] withKey:@"savedExtent"];
	
	return json;
}

#pragma mark _
-(void)addRecentSearch:(NSString *)search{
	// remove last one if reached max
	while (self.recentSearches.count >= MAX_SAVED_SEARCHES){
		[self.recentSearches removeLastObject];
	}
	// remove dups
	for (int i=0; i<self.recentSearches.count; i++){
		if ([[self.recentSearches objectAtIndex:i] isEqualToString:search] ){
			[self.recentSearches removeObjectAtIndex:i];
		}
	}
	
	// Add latest
	[self.recentSearches insertObject:search atIndex:0];
}

-(AGSWebMap *) webmap{
	if (_webmap == nil){
		AGSWebMap *wm = [self downloadMobileWebMap];
		self.webmap = wm;
	}
	return _webmap;
}

#pragma mark _
#pragma mark dealloc

-(void)dealloc
{
	self.title = nil;
	self.url = nil;
	self.savedExtent = nil;
	self.taskOrder = nil;
	self.recentSearches = nil;
	self.contentItem = nil;	
	self.webmap = nil;
    self.mapIcon = nil;
    self.mapIconName = nil;
    self.customBaseMap = nil;
    self.legend = nil;
    
	[super dealloc];
}


@end

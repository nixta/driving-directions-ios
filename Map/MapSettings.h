//
//  MapSettings.h
//  ArcGISMobile
//
//  Created by ryan3374 on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//Subclass of MapSettingsBase.m. Adds several properties and functionalities
//specific to a fully-functional web map

#import <Foundation/Foundation.h>
#import "MapSettingsBase.h"

@class BaseMapSettings;
@class Legend;

extern NSString * const DEFAULT_CONFIGURATION_1_URL;
extern NSString * const DEFAULT_CONFIGURATION_2_URL;
extern NSString * const DEFAULT_CONFIGURATION_3_URL;
extern NSString * const DEFAULT_CONFIGURATION_4_URL;
extern NSInteger const MAX_SAVED_SEARCHES;

@interface MapSettings : MapSettingsBase <AGSCoding> {
    AGSEnvelope *_savedExtent;
    NSMutableArray *_taskOrder;
    NSMutableArray *_recentSearches;
	
    BaseMapSettings *_customBaseMap;
    BOOL _switchBaseMapsEnabled;
    
    Legend *_legend;
    
}

@property (nonatomic, retain) AGSEnvelope *savedExtent;
@property (nonatomic, retain) NSMutableArray *taskOrder;
@property (nonatomic, retain) NSMutableArray *recentSearches;
@property (nonatomic, retain) BaseMapSettings *customBaseMap;
@property BOOL isSwitchBaseMapsEnabled;
@property (nonatomic, retain) Legend *legend;

-(id)initWithName:(NSString *)n
			  url: (NSString *)u
	  contentItem: (ContentItem *)c;

-(id) initWithUrl:(NSString *)sUrl;

-(void)addRecentSearch:(NSString *)search;

+(MapSettings *) mapSettingsFromWebMapJSON:(NSDictionary *)json withExtent:(AGSEnvelope *)extent;

@end

//
//  MapSettings.h
//  ArcGISMobile
//
//  Created by Scott Sirowy on 12/22/2010
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//Base class that includes common information about a web map
//Should be subclassed, and not used directly

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@class ContentItem;

@interface MapSettingsBase : NSObject <AGSCoding> {
	NSString *_title;
	NSString *_url;
    UIImage *_mapIcon;
    NSString *_mapIconName;
	
	ContentItem *_contentItem;

    AGSWebMap *_webmap;
    
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, retain) UIImage *mapIcon;
@property (nonatomic, retain) NSString *mapIconName;

@property (nonatomic, retain) ContentItem *contentItem;
@property (nonatomic, retain) AGSWebMap *webmap;

-(id)initWithName:(NSString *)n
			  url: (NSString *)u
	  contentItem: (ContentItem *)c;

-(id) initWithUrl:(NSString *)sUrl;

-(NSString *)mapThumbnailURLString;
-(AGSWebMap *)downloadMobileWebMap;

-(BOOL)isPublic;

@end


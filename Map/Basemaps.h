/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

/*
 Model object for a list of basemaps. Object is responsible for
  accessing/retriveing basemap information over the wire 
 */

@class SearchResponse;
@class ArcGISAppDelegate;
@class ContentItem;
@class BasemapInfo;

@protocol BasemapDelegate;

@interface Basemaps : NSObject
{
    SearchResponse              *_searchResponse;
    NSMutableArray              *_basemapInfos;
	NSString                    *_groupID;
    
    BOOL                        _isDownloading;
    BOOL                        _finishedDownloading;
    
    id<BasemapDelegate>         __unsafe_unretained _delegate;
    
    AGSJSONRequestOperation     *_esriGroupIdOp;
    AGSJSONRequestOperation     *_baseMapsOp;
    
    ArcGISAppDelegate           *__unsafe_unretained _app;
}

/*properties to indicate status of download */
@property (nonatomic, assign) BOOL                  isDownloading;
@property (nonatomic, assign) BOOL                  finishedDownloading;

@property (nonatomic, unsafe_unretained) id<BasemapDelegate>   delegate;


/*default initializer */
-(id)initWithDelegate:(id<BasemapDelegate>)aDelegate;

/*Begin process of downloading basemaps */
-(void)startDownload;

-(NSInteger)numberOfBasemaps;

-(BasemapInfo *)basemapAtIndex:(NSUInteger)index;
-(BOOL) foundSubstring:(NSString*)originalString find:(NSString*)toFind;

@end

@protocol BasemapDelegate <NSObject>

-(void)basemapsFinishedDownloading;
-(void)basemapsFailedDownloading;

@end


@interface BasemapInfo : NSObject {
    ContentItem     *_contentItem;
    NSString        *_title;
    NSString        *_urlString;
    UIImage         *_basemapIcon;
    BOOL            _isDefaultBasemap;
}

@property (nonatomic, strong, readonly) ContentItem     *contentItem;
@property (nonatomic, strong, readonly) NSString        *title;
@property (nonatomic, strong, readonly) NSString        *urlString;
@property (nonatomic, strong) UIImage                   *basemapIcon;
@property (nonatomic, assign) BOOL                      isDefaultBasemap;


-(id)initWithTitle:(NSString *)title urlString:(NSString *)urlString contentItem:(ContentItem *)contentItem;
-(NSString *)mapThumbnailURLString;

@end


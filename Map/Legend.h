/*
 Legend.h
 ArcGISMobile
 COPYRIGHT 2011 ESRI
 
 TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
 Unpublished material - all rights reserved under the
 Copyright Laws of the United States and applicable international
 laws, treaties, and conventions.
 
 For additional information, contact:
 Environmental Systems Research Institute, Inc.
 Attn: Contracts and Legal Services Department
 380 New York Street
 Redlands, California, 92373
 USA
 
 email: contracts@esri.com
 */

#import <Foundation/Foundation.h>
#import "ArcGIS+App.h"


@class LegendElement;
@class LegendLayer;
@protocol LegendDelegate;

/*
 Model object for viewing a legend. The object will retrieve all legend
 information in a more intuitive hierarchical organization than what is 
 given to us by the REST endpoint
 */

@interface Legend : NSObject <AGSMapServiceInfoDelegate>
{
    //only public facing properties
    NSArray *_layerInfos; 
    NSArray *_layers;
    id<LegendDelegate> __unsafe_unretained _delegate;
    BOOL _finishedDownloading;
    BOOL _isDownloading;
    
    @protected
    NSDictionary *_layerNames;
    NSInteger _currentLayerIndex;
    AGSMapServiceInfo *_currentMapServiceInfo;
    AGSMapView *_mapView;
    
    NSMutableArray *_legendLayers;
    
    NSURLConnection *_soapConnection;
    NSString *_responseString;
}

/*Delegate when legend is finished downloading */
@property (nonatomic, unsafe_unretained) id<LegendDelegate> delegate;

/*State of the legend download */
@property (nonatomic, assign) BOOL finishedDownloading;
@property (nonatomic, assign) BOOL isDownloading;


/*default initializer */
-(id)initWithMapLayerInfos:(NSArray *)layerInfos withMapView:(AGSMapView *)mapView;

/*Interface 1: Present elements as one long list. Each element
 has a corresponding 'level' field that can be used as needed */
-(NSUInteger)totalEntriesInLegend;
-(LegendElement *)legendElementAtRow:(NSUInteger)row;
-(NSUInteger)numberOfLayers;
-(LegendLayer *)legendLayerAtIndex:(NSUInteger)index;


/*public method to begin the building of the legend */
-(void)buildLegend;

/*Passes back an array of visible layer URLs */
-(NSArray *)visibleLayerUrls;

@end

/*
 Model object for representing a layer/sublayer/group
 in a legend. The Legend itself consists of of an array
 of LegendLayers. A LegendLayer can itself consist of
 0 or more LegendLayers.
 */

@interface LegendLayer : NSObject
{
    NSMutableArray          *_groups;
    NSMutableArray          *_elements;
    NSMutableArray          *_allVisibleElements;
    
    NSUInteger              _level;
    NSString                * _title;
    
    AGSWebMapLayerInfo      *_mapLayerInfo;
    AGSMapServiceLayerInfo  *_mapServiceLayerInfo;
    BOOL                    _baseLayer;
}

-(void)addGroup:(LegendLayer *)ll;
-(void)addElement:(LegendElement *)element;

/*List of groups withing a layer.  A group is itself a legend
  layer */
@property (nonatomic, strong) NSMutableArray *groups;

/*The elements for the given layer. These are essentially the leaves
  of the hierarchical legend tree */
@property (nonatomic, strong) NSMutableArray *elements;

@property (nonatomic, strong) NSMutableArray *allVisibleElements;

/*Level of layer in hierarchy */
@property (nonatomic, assign) NSUInteger level;

/*Title of layer/sublayer/group */
@property (nonatomic, copy) NSString *title;

/*YES if layer is topmost layer */
@property (nonatomic, assign) BOOL baseLayer;

/*The maplayerInfo this layer is a part of */
@property (nonatomic, strong) AGSWebMapLayerInfo *mapLayerInfo;

/*If layer/sublayer/group is a map service, this will be populated.
  Nil otherwise */
@property (nonatomic, strong) AGSMapServiceLayerInfo *mapServiceLayerInfo;


//YES if layer should be visible in legend. NO otherwise */
-(BOOL)isVisibleinMapView:(AGSMapView *)aMapView;

-(BOOL)showLegend;

@end


/*
 Model object for representing one element in a legend.
 In the hierarchical tree representing the legend, a LegendElement
 is a leaf component and does not contain additional nodes.
 The Title and Swatch are both optional. I have chosen to use a legend element
 with no title AND no swatch to represent a separator between layers
 */
@interface LegendElement : NSObject
{
    NSString *_title;
    UIImage  *_swatch;
    
    NSUInteger _level;
}

/*label associated with legend element */
@property (nonatomic, copy) NSString *title;

/*an image associated with legend element. May be nil if
 only a title is appropriate */
@property (nonatomic, strong) UIImage *swatch;

/*The level at which the legend should be shown in hierarchuy.
  Between 0 -> ... */
@property (nonatomic, assign) NSUInteger level;

-(id)initWithTitle:(NSString *)aTitle withSwatch:(UIImage *)aSwatch;
+(LegendElement *)legendElementWithTitle:(NSString *)aTitle withSwatch:(UIImage *)aSwatch;

@end


/*
 A delegate interested in knowing when legend is finished should subscribe to this
 protocol
 */

@protocol LegendDelegate <NSObject>

-(void)legendFinishedDownloading:(Legend *)legend;

@end




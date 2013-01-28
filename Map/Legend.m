/*
 Copyright © 2013 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "Legend.h"

#import "NSDictionary+Additions.h"
#import "MapLayerInfo+AppAdditions.h"
#import "ArcGISMobileConfig.h"
#import "ArcGISAppDelegate.h"

#pragma mark -
#pragma mark Legend Implementation

// This is a method off of AGSMapServiceLayerInfo that is private. Label it here
//so we don't get a warning
@interface AGSMapServiceLayerInfo (Internal)

-(void)ags_updateLegendInfo:(NSDictionary *)layerInfoJson;

@end

//private property off of tiled layer view we need
@interface AGSTiledLayer ()

@property (nonatomic, retain) AGSLOD *lod;
-(AGSLOD *)findClosestLOD:(double)resolution;

@end

@interface Legend ()

//private methods
-(void)generateLegend;
-(void)generateLegendForLayer:(LegendLayer *)ll visibleElementsArray:(NSMutableArray *)visibleElements;
-(void)finishLegend;

-(void)loadLegendForNextLayer;
-(void)loadLegendForFeatureCollectionWithMapLayerInfo:(AGSWebMapLayerInfo *)mli;
-(void)loadLegendForFeatureLayer:(AGSFeatureLayer *)fl;
-(void)loadLegendForCurrentMapServiceInfo:(AGSMapServiceInfo *)msi;
-(void)loadLegendUsingSOAPforMapServiceInfo:(AGSMapServiceInfo *)msi;
-(LegendLayer *)legendLayerForMapServiceInfo:(AGSMapServiceInfo *)msi;
-(NSUInteger)rootNode:(LegendLayer *)root mapLayerInfo:(AGSWebMapLayerInfo*)mli mapServiceLayerInfos:(NSArray *)mslis currentIndex:(NSUInteger)arrayIndex forLevel:(NSUInteger)currentLevel;

//utility methods for getting correct indentation level
-(AGSMapServiceLayerInfo *)getLayerWithID:(NSInteger)layerID inSubArray:(NSArray *)subLayerArray;
-(NSInteger)getIndentationLevel:(AGSMapServiceLayerInfo *)msli forSubArray:(NSArray *)subLayerArray;

//utility method for getting visible layers
-(NSMutableArray *)visibleLayerUrlsForLayer:(LegendLayer *)ll withCurrentArray:(NSMutableArray *)visibleLayers;

-(NSMutableArray *)legendElementsForFeatureLayer:(AGSFeatureLayer *)fl withSwatchSize:(CGSize)swatchSize;

//private properties

/*Array of map layer infos for the map */
@property (nonatomic, strong) NSArray *layerInfos;


/*Dictionary of layer names to the AGSLayer */
@property (nonatomic, strong) NSDictionary *layerNames;

/*Hierarchical structure that closely models the structure of legend*/
@property (nonatomic, strong) NSMutableArray *legendLayers;

/*For retainment purposes only */
@property (nonatomic, strong) AGSMapServiceInfo *currentMapServiceInfo;

/*If layer doesn't have legend support, then we need to hit a SOAP service
  to get the legend info */
@property (nonatomic, strong) NSURLConnection *soapConnection;

/*Response string from SOAP to JSON connection */
@property (nonatomic, strong) NSString *responseString;

@end

@implementation Legend

static int kNumberOfLayersInFeatureCollection = 4;

#pragma mark -
#pragma mark Initializer
/*default initializer. The legend requires the map layers, their layer infos, and the map view itself. */
-(id)initWithMapLayerInfos:(NSArray *)layerInfos withMapView:(AGSMapView *)mapView
{
    if(self = [super init])
    {
        self.layerInfos = layerInfos;
        
        //need a reference to the map view so we can get dynamic/tiled map service layers
        _mapView = mapView;
    }
    
    return self;
}

#pragma mark -
#pragma mark Lazy Loads
-(NSDictionary *)layerNames
{
    if(_layerNames == nil)
    {
        //only create dictionary if layers already exist. Otherwise,
        //dictionary should stay nil
        if (_mapView.mapLayers != nil) {
            NSMutableDictionary *aDictionary = [NSMutableDictionary dictionaryWithCapacity:_mapView.mapLayers.count];
            for (AGSLayer *layer in _mapView.mapLayers) {
                [aDictionary setObject:layer forKey:layer.name];
            }
            
            self.layerNames = aDictionary;
        }
    }
    
    return _layerNames;
}


#pragma mark -
#pragma mark Legend Data Source Methods
-(NSUInteger)totalEntriesInLegend
{
    if(!_finishedDownloading)
        return 0;
    
    NSUInteger visibleElements = 0;
    for (LegendLayer *ll in self.legendLayers)
    {
        visibleElements += ll.allVisibleElements.count;
    }
    
    return visibleElements;
}

-(LegendElement *)legendElementAtRow:(NSUInteger)row
{
    if(!_finishedDownloading)
        return nil;
    
    //Return something from legend layers
    return nil;
}

-(NSUInteger)numberOfLayers
{
    return self.legendLayers.count;
}

-(LegendLayer *)legendLayerAtIndex:(NSUInteger)index
{
    if (index >= self.legendLayers.count) 
        return nil;
    
    return [self.legendLayers objectAtIndex:index];
}

#pragma mark -
#pragma mark  Legend Building

//Builds up a model of the layers, sub-layers, groups, etc. This model can 
//then be used to generate a flat list that can be displayed in a tableview
-(void)buildLegend
{
    //the legend has already been built, so just regenerate
    if(_finishedDownloading)
    {
        [self generateLegend];
    }
    //only build legend if we haven't finished downloading AND we aren't currently downloading
    else if(!_finishedDownloading && !_isDownloading)
    {
        _isDownloading = YES;
        _finishedDownloading = NO;
        
        //we need to build the legend in reverse
        _currentLayerIndex = self.layerInfos.count -1;
        
        //create a new array for the legend layers
        self.legendLayers = [NSMutableArray array];
        
        //start process of buildinng the legend
        [self loadLegendForNextLayer];
    }
}

//Recursive method for loading layers in the proper order
-(void)loadLegendForNextLayer
{
    //finished loading layers
    if (_currentLayerIndex < 0) {
        
        //generate the legend as a flat list data structure
        [self generateLegend];
    }
    else {
        AGSWebMapLayerInfo *wmli = [self.layerInfos objectAtIndex:_currentLayerIndex];
        
        AGSLayer *currentLayer = [self.layerNames objectForKey:wmli.title];
        
        //Current Layer would be nil since SDK appends a number to each FeatureCollection
        //layer. e.g Map Notes  =>  Map Notes1, Map Notes2, Map Notes3, Map Notes 4
        if (currentLayer == nil && wmli.featureCollection != nil) {
            [self loadLegendForFeatureCollectionWithMapLayerInfo:wmli];
        }
        else if ([currentLayer isKindOfClass:[AGSDynamicMapServiceLayer class]])
        {
            //get the map service info from the layer so we can get the legend
            //information
            AGSMapServiceInfo *msi = ((AGSDynamicMapServiceLayer *)currentLayer).mapServiceInfo;
            
            //retain map service info here
            self.currentMapServiceInfo = msi;
            
            //set its delegate so we can get its information, then retrive its legend info
            msi.delegate = self;
            [msi retrieveLegendInfo];
        }
        else if([currentLayer isKindOfClass:[AGSTiledMapServiceLayer class]])
        {            
            //get the map service info from the layer so we can get the legend
            //information
            AGSMapServiceInfo *msi = ((AGSTiledMapServiceLayer *)currentLayer).mapServiceInfo;
            
            //retain map service info here
            self.currentMapServiceInfo = msi;
            
            //set its delegate so we can get its information, then retrive its legend info
            msi.delegate = self;
            [msi retrieveLegendInfo];
        }
        else if([currentLayer isKindOfClass:[AGSFeatureLayer class]])
        {
            AGSFeatureLayer *fl = (AGSFeatureLayer *)currentLayer;
            
            [self loadLegendForFeatureLayer:fl];
            
        }
        else {
            //decrement index and then load next layer
            _currentLayerIndex--;
            
            [self loadLegendForNextLayer];
            
        }

    }
}

//Called for a feature collection.  The method must create a set of feature layers
//and then use a technique similar to the loadLegendForFeatureLayer to create the legend
//elements
-(void)loadLegendForFeatureCollectionWithMapLayerInfo:(AGSWebMapLayerInfo *)wmli
{
    if (wmli.featureCollection) {
        //create a top level LegendLayer component. We will add this to the high
        //our list of layers once we are done loading the feature layer legend
        LegendLayer *ll = [[LegendLayer alloc] init];
        ll.level = 0;
        ll.mapLayerInfo = [self.layerInfos objectAtIndex:_currentLayerIndex];
        ll.title = ll.mapLayerInfo.title;
        ll.baseLayer = YES;
        ll.mapServiceLayerInfo = nil;
        
        //empty array that we will use to create legend elements for a feature layer
        NSMutableArray *elementArray = [NSMutableArray array];
        
        for (int i = 1; i <= kNumberOfLayersInFeatureCollection; i++) {
            NSString *layerName = [wmli.title stringByAppendingFormat:@"%d", i];
            AGSFeatureLayer *fl = [self.layerNames objectForKey:layerName];
            
            //only add elemts if there is a feature layer to work with
            if (fl)
                [elementArray addObjectsFromArray:[self legendElementsForFeatureLayer:fl withSwatchSize:CGSizeMake(20, 20)]];
            
        }
        
        //add elements to layer, nil out groups since there are no groups on a feature layer
        ll.elements = elementArray;
        ll.groups = nil;
        
        [self.legendLayers addObject:ll];
        
    }
    
    //decrement index and then load next layer
    _currentLayerIndex--;
    [self loadLegendForNextLayer];
}

//called when there is a feature layer legend to load. Loading a legend
//for a feature layer consists of looking at its feature template and its 
//associated types, and then creating LegendElements using those templates
-(void)loadLegendForFeatureLayer:(AGSFeatureLayer *)fl
{
    //create a top level LegendLayer component. We will add this to the high
    //our list of layers once we are done loading the feature layer legend
    LegendLayer *ll = [[LegendLayer alloc] init];
    ll.level = 0;
    ll.mapLayerInfo = [self.layerInfos objectAtIndex:_currentLayerIndex];
    ll.title = ll.mapLayerInfo.title;
    ll.baseLayer = YES;
    ll.mapServiceLayerInfo = nil;
        
    //add elements to layer, nil out groups since there are no groups on a feature layer
    ll.elements = [self legendElementsForFeatureLayer:fl withSwatchSize:CGSizeMake(20, 20)];
    ll.groups = nil;
    
    [self.legendLayers addObject:ll];
    
    //Recursive call for next layer
    _currentLayerIndex--;
    [self loadLegendForNextLayer];
}

//returns the legend elements for a feature layer
-(NSMutableArray *)legendElementsForFeatureLayer:(AGSFeatureLayer *)fl withSwatchSize:(CGSize)swatchSize
{
    NSMutableArray *elementsArray = [NSMutableArray arrayWithCapacity:2];
    
    if ([fl.renderer isKindOfClass:[AGSSimpleRenderer class]]) {
        
        AGSSimpleRenderer *sr = (AGSSimpleRenderer *)fl.renderer;
        UIImage *swatch = [sr.symbol swatchForGeometryType:fl.geometryType size:swatchSize];
        LegendElement *le = [LegendElement legendElementWithTitle:fl.serviceLayerName withSwatch:swatch];
        le.level = 1;
        
        [elementsArray addObject:le];
    }
    else if([fl.renderer isKindOfClass:[AGSClassBreaksRenderer class]])
    {
        AGSClassBreaksRenderer *cbr = (AGSClassBreaksRenderer *)fl.renderer;
        
        for(AGSClassBreak *cb in cbr.classBreaks)
        {
            UIImage *swatch = [cb.symbol swatchForGeometryType:fl.geometryType size:swatchSize];
            LegendElement *le = [LegendElement legendElementWithTitle:cb.label withSwatch:swatch];
            le.level = 1;
            
            [elementsArray addObject:le];
        }
    }
    else if([fl.renderer isKindOfClass:[AGSUniqueValueRenderer class]])
    {
        AGSUniqueValueRenderer *uvr = (AGSUniqueValueRenderer *)fl.renderer;
        for (AGSUniqueValue *uv in uvr.uniqueValues)
        {
            UIImage *swatch = [uv.symbol swatchForGeometryType:fl.geometryType size:swatchSize];
            LegendElement *le = [LegendElement legendElementWithTitle:uv.label withSwatch:swatch];
            le.level = 1;
            
            [elementsArray addObject:le];
        }
    }
    
    return elementsArray;
}

//After the legend for a map service info has been created, this method is called to update our own
//legend data structure
-(void)loadLegendForCurrentMapServiceInfo:(AGSMapServiceInfo *)msi
{   
    //call a utility function to create the legend layer for the map service info
    LegendLayer *ll = [self legendLayerForMapServiceInfo:msi];
    [self.legendLayers addObject:ll];
    
    //finally, update the current layer, and recursively load next layer
    _currentLayerIndex--;
    [self loadLegendForNextLayer];
}

// The SDK legend API has failed because the map service does not support a legend. Must retrieve
// legend through a SOAP to JSON interface 
-(void)loadLegendUsingSOAPforMapServiceInfo:(AGSMapServiceInfo *)msi
{
    //initialize to an empty string
    self.responseString = @"";
        
    ArcGISAppDelegate *_app = (ArcGISAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *legendUrl = _app.config.legend;

    NSString *fullSoapLegendEndpoint = [NSString stringWithFormat:@"%@?soapUrl=%@&returnbytes=true&f=json", legendUrl, msi.URL.relativeString];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:fullSoapLegendEndpoint]];
    self.soapConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}


#pragma mark -
#pragma mark Layer Building for MapServiceInfo
-(LegendLayer *)legendLayerForMapServiceInfo:(AGSMapServiceInfo *)msi
{
    //need to build tree by using the map service layer infos array
    NSArray *mapServiceLayerInfos = msi.layerInfos;
    
    //top level legend layer that we will use to begin the creation of the 
    //mapserviceInfo LegendLayer
    LegendLayer *ll = [[LegendLayer alloc] init];
    ll.level = 0;
    ll.mapLayerInfo = [self.layerInfos objectAtIndex:_currentLayerIndex];
    ll.title = ll.mapLayerInfo.title;
    ll.baseLayer = YES;
    ll.mapServiceLayerInfo = nil;
    
    //kick of recursive process
    [self rootNode:ll 
      mapLayerInfo:ll.mapLayerInfo 
mapServiceLayerInfos:mapServiceLayerInfos 
      currentIndex:0 
          forLevel:0];
    
    //finally return layer
    return ll;
}

//The legend is built by recursively building a tree-like structure consisting of nested LegendLayers, and their associated
//LegendElements. Because the REST endpoint gives us a flat-list of all the sub-layers within a map service, this method
//accepts those map service layer infos and generates the corresponding tree.
-(NSUInteger)rootNode:(LegendLayer *)root  mapLayerInfo:(AGSWebMapLayerInfo*)mli  mapServiceLayerInfos:(NSArray *)mslis currentIndex:(NSUInteger)arrayIndex forLevel:(NSUInteger)currentLevel
{
    LegendLayer *current = root;
    
    while (arrayIndex < mslis.count) {
        
        //get map service layer info we are currently insterested in working with
        AGSMapServiceLayerInfo *msli = [mslis objectAtIndex:arrayIndex];
        
        //gets its level in the hierarchy
        NSUInteger level = [self getIndentationLevel:msli forSubArray:mslis];
        
        //going up the tree, base case for breaking out
        if(level < currentLevel)
            break;
        
        //at same level. Create a new layer/sublayer/group, and add it to root layer
        else if (level == currentLevel) {
            
            LegendLayer *aLegendLayer = [[LegendLayer alloc] init];
            
            aLegendLayer.title = msli.name;
            aLegendLayer.level = root.level + 1;
            aLegendLayer.baseLayer = NO;
            aLegendLayer.mapLayerInfo = mli;
            aLegendLayer.mapServiceLayerInfo = msli;
            
            //add swatches
            //iterate over all the legendLabels, creating a new Legend element with the image and label
            for (int i = 0; i < msli.legendLabels.count; i++) {
                
                UIImage *swatch = [msli.legendImages objectAtIndex:i];
                NSString *label = [msli.legendLabels objectAtIndex:i];
                
                LegendElement *le = [LegendElement legendElementWithTitle:label withSwatch:swatch];
                
                le.level = aLegendLayer.level + 1;
                [aLegendLayer addElement:le];
            }
            
            [root addGroup:aLegendLayer];
            current = aLegendLayer;
            
            //finally, incrememnt array index since we have now handled that layer
            //in the map service layer array
            arrayIndex++;
        }
        
        //diving deeper into tree structure
        else if(level > currentLevel)
        {
            arrayIndex = [self rootNode:current mapLayerInfo:mli mapServiceLayerInfos:mslis currentIndex:arrayIndex forLevel:level];
        }
    }
    
    return arrayIndex;
}

#pragma mark -
#pragma mark Utility Indentation Level Stuff
//returns the AGSMapServiceLayerInfo for the layer with id: layerID
-(AGSMapServiceLayerInfo *)getLayerWithID:(NSInteger)layerID inSubArray:(NSArray *)subLayerArray
{
    AGSMapServiceLayerInfo *retValue = nil;
    for (AGSMapServiceLayerInfo *msli in subLayerArray) {
        if (msli.layerId == layerID)
        {
            retValue = msli;
            break;
        }
    }
    
    return retValue;
}

//returns the indentation level of a map service layer info (i.e its level in the hierarchy)
-(NSInteger)getIndentationLevel:(AGSMapServiceLayerInfo *)msli forSubArray:(NSArray *)subLayerArray
{
    NSInteger indentationlevel = 0;
    
    AGSMapServiceLayerInfo *parentMSLI = msli;
    while (parentMSLI && parentMSLI.parentLayerID >= 0)
    {
        indentationlevel++;
        parentMSLI = [self getLayerWithID:parentMSLI.parentLayerID inSubArray:subLayerArray];
    }
    
    return indentationlevel;
}

#pragma mark -
#pragma mark AGSMapServiceInfoDelegate
-(void)mapServiceInfo:(AGSMapServiceInfo *)mapServiceInfo operationDidRetrieveLegendInfo:(NSOperation *)op{
    [self loadLegendForCurrentMapServiceInfo:mapServiceInfo];
}

-(void)mapServiceInfo:(AGSMapServiceInfo *)mapServiceInfo operation:(NSOperation *)op didFailToRetrieveLegendInfoWithError:(NSError *)error{
    [self loadLegendUsingSOAPforMapServiceInfo:mapServiceInfo];
}

#pragma mark -
#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{   
    NSLog(@"Connection Failed");
}

//Method called after connection has fully finished. This should be called
//twice for this view controller, one for retrieving the group ID, and one for
//retrieving all of the base maps
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *json = [self.responseString ags_JSONValue];
    
    //Update Legend for current map service info
    NSArray *layerInfoArray = [json objectForKey:@"layers"];
	for (int i=0; i<layerInfoArray.count; i++){
		NSDictionary *layerInfoJson = [layerInfoArray objectAtIndex:i];
		int layerId = [[NSDictionary safeGetObjectFromDictionary:layerInfoJson withKey:@"layerId"]intValue];
        
        AGSMapServiceLayerInfo *msli = [self.currentMapServiceInfo.layerInfos objectAtIndex:layerId];
        
        //making a private call here to update the legend information for the sub layer in map service info
		[msli ags_updateLegendInfo:layerInfoJson];
	}
    
    
    //update our own data structure with new data
    [self loadLegendForCurrentMapServiceInfo:self.currentMapServiceInfo];
    
}

//Since we're only going to have once connection active at one time, we don't need
//to check in here for the connection 
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (jsonString != nil)
    {
        self.responseString = [self.responseString stringByAppendingString:jsonString];
    }
    
}

#pragma mark -
#pragma mark Legend Generation

//Generates a flat list data structure (array) that can be used to populate a tableview.
//Only shows those layers/groups which are visible on the map to satisfy the dynamic
//legend requirement
-(void)generateLegend
{
    //traverse the data structure, building up the legendElements flat list data structure
    for (LegendLayer *ll in self.legendLayers)
    {
        ll.allVisibleElements = [NSMutableArray arrayWithCapacity:3];
        
        //only generate legend elements if layer is actually visible
        if([ll showLegend] && [ll isVisibleinMapView:_mapView])
        {
            [self generateLegendForLayer:ll visibleElementsArray:ll.allVisibleElements];
        }
    }
    
    [self finishLegend];
}

//depth first search traversal of the tree, adding elements to the legendElements
//as necessary
-(void)generateLegendForLayer:(LegendLayer *)ll visibleElementsArray:(NSMutableArray *)visibleElements
{    
    //show all groups first
    for(LegendLayer *group in ll.groups)
    {
        if ([group isVisibleinMapView:_mapView]) {
            //depth first search into group
            [self generateLegendForLayer:group visibleElementsArray:visibleElements];
        }
    }
    
    //then show elements
    for (LegendElement *le in ll.elements)
    {
        [visibleElements addObject:le];
    }
    
    //break out
}

-(void)finishLegend
{
    //finished!
    _finishedDownloading = YES;
    _isDownloading = NO;
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LegendFinishedGenerating" object:self];
    
    if([self.delegate respondsToSelector:@selector(legendFinishedDownloading:)])
    {
        [self.delegate legendFinishedDownloading:self];
    }
}

//Public Method that passes back an array of URLs that are visible at the time the method is called.
//That array should be regenerated every time client needs an updated list of visible layers
-(NSArray *)visibleLayerUrls
{
    if (!_finishedDownloading || _isDownloading) {
        return nil;
    }
    
    NSMutableArray *visibleLayers = [NSMutableArray arrayWithCapacity:self.legendLayers.count];
    
    for (LegendLayer *ll in self.legendLayers)
    {
        if([ll isVisibleinMapView:_mapView])
        {
            visibleLayers = [self visibleLayerUrlsForLayer:ll withCurrentArray:visibleLayers];
        }
    }
    
    return visibleLayers;
}

-(NSMutableArray *)visibleLayerUrlsForLayer:(LegendLayer *)ll withCurrentArray:(NSMutableArray *)visibleLayers
{
    for(LegendLayer *group in ll.groups)
    {
        if ([group isVisibleinMapView:_mapView]) {
            visibleLayers = [self visibleLayerUrlsForLayer:group withCurrentArray:visibleLayers];
        }
    }
    
    //add layer
    NSString *layerUrlString = [ll.mapLayerInfo.URL absoluteString];
    if (ll.mapServiceLayerInfo) {
        layerUrlString = [layerUrlString stringByAppendingPathComponent:[NSString stringWithFormat:@"%u", ll.mapServiceLayerInfo.layerId]];
    }
    
    //url may not exist. Likely a map notes layer. Not needed anyways
    if (layerUrlString != nil) {
        [visibleLayers addObject:layerUrlString];
    }
    
    return visibleLayers;
}


@end


#pragma mark -
#pragma mark Legend Layer Implementation

@interface LegendLayer () 

-(BOOL)isVisibleWithScaleOnMapView:(AGSMapView *)mapView;
-(BOOL)featureLayer:(AGSFeatureLayer *)fl isVisibleWithScaleOnMapView:(AGSMapView *)mapView;

@end


@implementation LegendLayer

//utility method to add a new group to the layer
-(void)addGroup:(LegendLayer *)ll
{
    //lazy load groups array
    if (_groups == nil) {
        self.groups = [NSMutableArray array];
    }
    
    [self.groups addObject:ll];
}

//utility method to add a legend element to the array
-(void)addElement:(LegendElement *)element
{
    //lazy load elements array
    if(_elements == nil)
    {
        self.elements = [NSMutableArray array];
    }
    
    [self.elements addObject:element];
}

-(BOOL)showLegend
{
    return (self.mapLayerInfo.featureCollection == nil) || (self.mapLayerInfo.featureCollection && self.mapLayerInfo.featureCollection.showLegend);
}

-(BOOL)isVisibleinMapView:(AGSMapView *)mapView
{
    BOOL isVisible;
    
    //A base layer is the topmost layer. This could be a feature service layer,
    //or the top most layer in a map service.
    if (self.baseLayer)
    {
        if (self.mapLayerInfo.featureCollection) {
            isVisible = NO;
            for (int i = 1; i <= kNumberOfLayersInFeatureCollection; i++) {
                NSString *layerName = [self.mapLayerInfo.title stringByAppendingFormat:@"%d", i];
                
                //UIView<AGSLayerView> *lyrView = (UIView<AGSLayerView> *)[mapView.mapLayerViews objectForKey:layerName];
                AGSLayer *layer = [mapView mapLayerForName:layerName];
                if (layer && !layer.visible) {
                    isVisible = YES;
                    break;
                }
            }
        }
        else {
            //UIView<AGSLayerView> *lyrView = (UIView<AGSLayerView> *)[mapView.mapLayerViews objectForKey:self.mapLayerInfo.title];
            AGSLayer *layer = [mapView mapLayerForName:self.mapLayerInfo.title];
            
            if ([layer isKindOfClass:[AGSFeatureLayer class]]) {
                isVisible = !layer.visible && [self featureLayer:(AGSFeatureLayer *)layer isVisibleWithScaleOnMapView:mapView];
            }
            else
            {
                isVisible = !layer.visible && [self isVisibleWithScaleOnMapView:mapView];
            }
        }
    }
    //a sub-layer in a map service. Need to check here if in a dynamic map service layer that the
    //layer's ID belongs in the visibleLayers array. If the visibleLayers array is nil, then we need to 
    //check the default visibility of the mapservice layer. If its a tiled service, we need to check the default
    //visibility.
    else {
        
        //try and get dynamic map service layer from mapLayerInfo
        AGSDynamicMapServiceLayer *dynamicMSL = [self.mapLayerInfo getDynamicMapServiceLayer:mapView];
        
        //if its nil, means we have a tiled map service
        if (dynamicMSL == nil) {
            //and just use the default visibility
            isVisible = self.mapServiceLayerInfo.defaultVisibility && [self isVisibleWithScaleOnMapView:mapView];
        }
        //we have a dynamic map service
        else {
            
            //if the visible layers array is nil, just use the default visibility
            //of the map service layer info
            if (dynamicMSL.visibleLayers == nil) {
                isVisible = self.mapServiceLayerInfo.defaultVisibility && [self isVisibleWithScaleOnMapView:mapView];
            }
            
            //else, the visibility is YES if the layerID is contained withing the visible layers
            //array AND if the map's scale observes the scale dependency for the layer
            // Al Delete
//            else {
//                //first determine if layer is actually contained AND layer is within visible scales
//                NSArray *visibleLayersInDynamicMSL = [dynamicMSL allVisibleLayersForMapLayerInfo:self.mapLayerInfo inMapView:mapView];
//                isVisible = [visibleLayersInDynamicMSL containsObject:[NSNumber numberWithInt:self.mapServiceLayerInfo.layerId]] &&
//                                                                     [self isVisibleWithScaleOnMapView:mapView];
//            }
        }
    }

    return isVisible;
}

//returns YES if layer observes scale dependency AND mapview is within the visible scale
-(BOOL)isVisibleWithScaleOnMapView:(AGSMapView *)mapView
{
    //if the map scale can't be calculated, just return YES. This should rarely happen, and
    //appears to only happen when the base layer is an image service. Image service isn't providing
    //units, so mapScale can't be calculated
    if (isnan(mapView.mapScale)) {
        return YES;
    } 
    
    double minScale = self.mapServiceLayerInfo.minScale;
    double maxScale = self.mapServiceLayerInfo.maxScale;
    
    double scaleToCompare = mapView.mapScale;
    
    AGSTiledMapServiceLayer *tiledMSL = [self.mapLayerInfo getTiledMapServiceLayer:mapView];
    if (tiledMSL != nil) {
        AGSTiledLayer *tlv = (AGSTiledLayer*)[mapView mapLayerForName:tiledMSL.name];
        scaleToCompare = [tlv findClosestLOD:mapView.resolution].scale; //tlv.lod.scale;
    }
    
    //Check if it observes the minimum scale dependency
    BOOL isVisible = ((minScale == 0) ||            //either the layers min scale is 0
                  (scaleToCompare <= minScale));  //or the mapview's scale is less than or equal to the minScale
    
    //finally check it is observes the max scale dependency
    isVisible = isVisible && ((maxScale == 0) ||                //either the layers min scale is 0
                              (scaleToCompare >= maxScale));  //or the mapview's scale is greater than or equal to the minScale
    
    return isVisible;
}

-(BOOL)featureLayer:(AGSFeatureLayer *)fl isVisibleWithScaleOnMapView:(AGSMapView *)mapView
{
    //if the map scale can't be calculated, just return YES. This should rarely happen, and
    //appears to only happen when the base layer is an image service. Image service isn't providing
    //units, so mapScale can't be calculated
    if (isnan(mapView.mapScale)) {
        return YES;
    } 
    
    //Check if it observes the minimum scale dependency
    BOOL isVisible = ((fl.minScale == 0) ||            //either the layers min scale is 0
                      (mapView.mapScale <= fl.minScale));  //or the mapview's scale is less than or equal to the minScale
    
    //finally check it is observes the max scale dependency
    isVisible = isVisible && ((fl.maxScale == 0) ||                //either the layers min scale is 0
                              (mapView.mapScale >= fl.maxScale));  //or the mapview's scale is greater than or equal to the minScale
    
    return isVisible;
}

-(NSString *)description
{
    return self.title;
}


@end


#pragma mark -
#pragma mark Legend Element Implementation

@implementation LegendElement

-(id)initWithTitle:(NSString *)aTitle withSwatch:(UIImage *)aSwatch
{
    if(self = [super init])
    {
        self.title = aTitle;
        self.swatch = aSwatch;
    }
    
    return self;
}

+(LegendElement *)legendElementWithTitle:(NSString *)aTitle withSwatch:(UIImage *)aSwatch
{
    LegendElement *le = [[LegendElement alloc] initWithTitle:aTitle withSwatch:aSwatch];
    return le;
}


@end






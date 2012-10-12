/*
 Copyright © 2012 Esri
 
 All rights reserved under the copyright laws of the United States
 and applicable international laws, treaties, and conventions.
 
 You may freely redistribute and use this sample code, with or
 without modification, provided you include the original copyright
 notice and use restrictions.
 
 See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
 
 */

#import "AGSDynamicMapServiceLayer+LayerVisibilityAdditions.h"
#import "MapLayerInfo+AppAdditions.h"
#import <ArcGIS/ArcGIS.h>

@implementation AGSDynamicMapServiceLayer (LayerVisibilityAdditions)

-(AGSMapServiceLayerInfo *)getLayerWithID:(NSInteger)layerID inLayers:(NSArray *)layerInfos
{
    AGSMapServiceLayerInfo *msliToReturn = nil;
    
    for (AGSMapServiceLayerInfo *msli in layerInfos) {
        NSInteger subLayerId = msli.layerId;
        if (subLayerId == layerID)
        {
            msliToReturn = msli;
            break;
        }
    }
    
    return msliToReturn;
}

-(NSArray *)allVisibleLayersForMapLayerInfo:(AGSWebMapLayerInfo *)mli inMapView:(AGSMapView *)mapView
{
    if (self.visibleLayers  == nil)
        return nil;

    
    NSMutableSet *layersToAdd = [[NSMutableSet alloc] initWithCapacity:2];
    AGSMapServiceInfo *msi = [mli getMSI:mapView];
    NSArray *subLayers = msi.layerInfos;
    
    NSMutableArray *allVisibleLayers = [NSMutableArray arrayWithArray:self.visibleLayers];
    
    //find all layers to add
    for (NSNumber *layerID in self.visibleLayers)
    {
        AGSMapServiceLayerInfo *msli = [self getLayerWithID:[layerID intValue] inLayers:subLayers];
        while (msli.parentLayerID >= 0) {
            //add to set
            if (![self.visibleLayers containsObject:[NSNumber numberWithInt:msli.parentLayerID]]) {
                 [layersToAdd addObject:[NSNumber numberWithInt:msli.parentLayerID]];
            }
                  
            //update to parent
            msli = [self getLayerWithID:msli.parentLayerID inLayers:subLayers];
        }
    }
    
    //2nd step:  add parent layers
    [allVisibleLayers addObjectsFromArray:[layersToAdd allObjects]];
    
    //sort so its proper order
    NSSortDescriptor *lowToHigh = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [allVisibleLayers sortUsingDescriptors:[NSArray arrayWithObject:lowToHigh]];
    
    return allVisibleLayers;
}

@end
